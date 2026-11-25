{
  config,
  lib,
  pkgs,
  ...
}:
# DigitalOcean does not do DHCP or router advertisements for the public
# interface; cloud-init normally reads the addresses from the metadata service
# and writes them out as static config. This does the same for networkd, so
# one system closure works on any droplet with no per-droplet values.
#
#   1. 90-do-bootstrap.network gives every NIC an IPv4 link-local address,
#      which is enough to reach 169.254.169.254.
#   2. do-network.service fetches /metadata/v1.json, writes the public NIC's
#      config, and replaces /etc/systemd/network/10-do-public.network (and
#      reloads networkd) only when it differs.
#
# The written file is a plain file in /etc, not one of the /etc/static links
# NixOS manages, so later boots come up on the last-known addresses straight
# away even if the metadata service is slow.
#
# Only addressing lives here. Firewall ports belong to whatever service
# listens on them.
let
  target = "/etc/systemd/network/10-do-public.network";

  script = pkgs.writeShellApplication {
    name = "do-network";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      diffutils
      jq
      systemd
    ];
    text = ''
      # For testing:
      #   DO_NETWORK_DRY_RUN=1 do-network   show what would change, change nothing
      #   DO_METADATA_JSON=file             read a saved v1.json instead of curl
      dry_run=''${DO_NETWORK_DRY_RUN:-0}

      if [[ -n "''${DO_METADATA_JSON:-}" ]]; then
        json=$(<"$DO_METADATA_JSON")
      else
        # The link-local address takes a few seconds to pass duplicate
        # address detection on first boot, so retry for a while.
        json=""
        for _ in $(seq 60); do
          json=$(curl -fsS --max-time 3 http://169.254.169.254/metadata/v1.json) && break
          json=""
          sleep 1
        done
        if [[ -z "$json" ]]; then
          echo "metadata service unreachable; keeping existing network config" >&2
          exit 1
        fi
      fi

      field() { jq -r ".interfaces.public[0].$1 // empty" <<<"$json"; }
      prefix_of() { # dotted netmask -> prefix length
        local bits=0 octet
        IFS=. read -ra octets <<<"$1"
        for octet in "''${octets[@]}"; do
          while ((octet > 0)); do
            bits=$((bits + (octet & 1)))
            octet=$((octet >> 1))
          done
        done
        echo "$bits"
      }

      mac=$(field mac)
      ipv4=$(field ipv4.ip_address)
      ipv4_mask=$(field ipv4.netmask)
      ipv4_gw=$(field ipv4.gateway)
      ipv6=$(field ipv6.ip_address)
      ipv6_prefix=$(field ipv6.cidr)
      ipv6_gw=$(field ipv6.gateway)
      anchor=$(field anchor_ipv4.ip_address)
      anchor_mask=$(field anchor_ipv4.netmask)

      if [[ -z "$mac" || -z "$ipv4" || -z "$ipv4_mask" || -z "$ipv4_gw" ]]; then
        echo "metadata is missing the public IPv4 settings; keeping existing config" >&2
        exit 1
      fi

      rendered=$(
        echo "# Written by do-network.service from DigitalOcean metadata."
        echo "# Edits are overwritten whenever the metadata disagrees."
        echo "[Match]"
        echo "MACAddress=$mac"
        echo
        echo "[Link]"
        echo "RequiredForOnline=routable"
        echo
        echo "[Network]"
        # Keeps 169.254.169.254 reachable on-link even if the addresses
        # below are ever stale, so fresh values can always be fetched.
        echo "LinkLocalAddressing=ipv4"
        echo "IPv6AcceptRA=no"
        echo "Address=$ipv4/$(prefix_of "$ipv4_mask")"
        echo "Gateway=$ipv4_gw"
        if [[ -n "$ipv6" && -n "$ipv6_prefix" && -n "$ipv6_gw" ]]; then
          echo "Address=$ipv6/$ipv6_prefix"
          echo "Gateway=$ipv6_gw"
        fi
        # The anchor address is what reserved IPs are routed to.
        if [[ -n "$anchor" && -n "$anchor_mask" ]]; then
          echo "Address=$anchor/$(prefix_of "$anchor_mask")"
        fi
        jq -r '.dns.nameservers[]? | "DNS=" + .' <<<"$json"
      )

      if [[ "$(cat ${target} 2>/dev/null)" == "$rendered" ]]; then
        echo "network config unchanged"
        changed=0
      else
        echo "network config for ${target}:"
        diff -uN --label old --label new ${target} - <<<"$rendered" || true
        changed=1
      fi

      if [[ "$dry_run" == 1 ]]; then
        echo "dry run: not installing or reloading"
        exit 0
      fi

      # reload reconfigures every link whose .network file is new or changed.
      # Waiting for the address is systemd-networkd-wait-online's job.
      if ((changed)); then
        install -m 0644 /dev/stdin ${target} <<<"$rendered"
        networkctl reload
      fi
    '';
  };
in
{
  options.glopFlake.digitalOceanNetwork.enable = lib.mkEnableOption "configuring the public NIC of a DigitalOcean droplet from its metadata service";

  config = lib.mkIf config.glopFlake.digitalOceanNetwork.enable {
    networking = {
      useDHCP = false;
      useNetworkd = true;
    };
    services.resolved.enable = true;

    # Catch-all for any NIC without a better match: link-local only. Sorted
    # after 10-do-public.network, so the public NIC uses that once it exists,
    # and the private VPC NIC just sits here unused.
    systemd.network.networks."90-do-bootstrap" = {
      matchConfig.Type = "ether";
      networkConfig = {
        LinkLocalAddressing = "ipv4";
        IPv6AcceptRA = false;
      };
      linkConfig.RequiredForOnline = "no";
    };

    systemd.services.do-network = {
      description = "Configure the public interface from DigitalOcean metadata";
      wantedBy = [
        "multi-user.target"
        "network-online.target"
      ];
      # wait-online then holds network-online.target until the public NIC is
      # routable (RequiredForOnline in the written file).
      before = [
        "systemd-networkd-wait-online.service"
        "network-online.target"
      ];
      after = [ "systemd-networkd.service" ];
      requires = [ "systemd-networkd.service" ];
      # Not restarted by switch; addresses only change if the droplet's
      # metadata does, and the next boot picks that up.
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe script;
      };
    };
    environment.systemPackages = [ script ];
  };
}
