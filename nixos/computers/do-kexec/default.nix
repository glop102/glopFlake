{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
# Small NixOS installer for kexec-ing a DigitalOcean droplet out of whatever
# it is running, for nixos-anywhere to partition and install from. It is a
# slimmed stand-in for nixos-images' kexec installer, which needs ~1.5GB of
# RAM; most of the difference is Python (used there to restore the old OS's
# network config, which do-network.service does here from droplet metadata)
# and perl.
#
#   nix build .#nixosConfigurations.do-kexec.config.system.build.nixosAnywhereKexec
#   nix run github:nix-community/nixos-anywhere -- \
#     --kexec ./result/do-kexec.tar --flake .#erowiki --target-host root@<ip>
#
# The tarball follows nixos-anywhere's contract: it unpacks to kexec/run, run
# prints "machine will boot into nixos", and the booted system reports
# VARIANT_ID=installer in /etc/os-release.
let
  kernelParams = toString config.boot.kernelParams;
  init = "${config.system.build.toplevel}/init";

  runScript = pkgs.writeScript "run" ''
    #!/bin/sh
    # Runs on the droplet's current OS (Ubuntu), so plain POSIX sh only; the
    # kexec binary next to this script is static.
    set -eu

    kexec_extra_flags=""
    while [ $# -gt 0 ]; do
      case "$1" in
      --kexec-extra-flags)
        kexec_extra_flags="$2"
        shift
        ;;
      esac
      shift
    done

    dir=$(dirname "$(readlink -f "$0")")
    "$dir/kexec" --load "$dir/bzImage" \
      --initrd="$dir/initrd" \
      $kexec_extra_flags \
      --command-line "init=${init} ${kernelParams}"

    echo "machine will boot into nixos in 6s..."
    if [ -e /dev/kmsg ]; then
      exec >/dev/kmsg 2>&1
    else
      exec >/dev/null 2>&1
    fi
    # Backgrounded so nixos-anywhere's ssh session can finish cleanly first.
    nohup sh -c "sleep 6 && '$dir/kexec' -e $kexec_extra_flags" &
  '';
in
{
  imports = [
    (modulesPath + "/installer/netboot/netboot.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    networking.hostName = "do-kexec";
    system.stateVersion = "26.05";
    system.nixos.variant_id = "installer";

    glopFlake.digitalOceanNetwork.enable = true;

    # core_nixos_config defaults to systemd-boot for UEFI hosts; the netboot
    # module boots via kexec and has no bootloader at all.
    glopFlake.uefiSystem = false;
    boot.loader.grub.enable = lib.mkForce false;
    hardware.enableRedistributableFirmware = lib.mkForce false;

    # Only what installing onto a virtio disk needs.
    boot.supportedFilesystems = lib.mkForce [
      "ext4"
      "vfat"
    ];
    boot.kernelParams = [
      "console=ttyS0,115200"
      "console=tty0"
    ];
    # Everything written to /nix/store here (the disko script's closure, nix's
    # own working files) lands in a tmpfs. tmpfs pages can be swapped, so zram
    # stretches the RAM; zswap alone would do nothing with no swap device.
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    # nixosSystem from a flake pins nixpkgs' source (~200 MiB) into the
    # registry and NIX_PATH. The installer never evaluates anything.
    nixpkgs.flake = {
      setNixPath = false;
      setFlakeRegistry = false;
    };

    # The full module tree is ~140 MiB of already-compressed .ko.xz that the
    # squashfs cannot shrink. A droplet is a KVM guest with virtio devices, so
    # drop whole hardware classes it can never have. aggregateModules reruns
    # depmod over what is left.
    system.modulesTree = lib.mkForce [
      (pkgs.runCommand "${config.boot.kernelPackages.kernel.name}-modules-droplet" { } ''
        cp -r --no-preserve=mode ${lib.getOutput "modules" config.boot.kernelPackages.kernel} $out
        cd $out/lib/modules/*/kernel
        rm -rf \
          sound \
          drivers/gpu drivers/media drivers/infiniband drivers/iio \
          drivers/staging drivers/video drivers/hwmon drivers/mtd \
          drivers/bluetooth drivers/isdn drivers/net/wireless \
          drivers/net/ethernet drivers/net/can drivers/net/usb \
          net/wireless net/bluetooth net/mac80211
      '')
    ];
    # qemu-guest.nix loads virtio_gpu in stage 1; droplets have plain VGA, and
    # the GPU driver tree was removed above.
    boot.initrd.kernelModules = lib.mkForce [
      "dm_mod"
      "loop"
      "overlay"
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/rXzI73PlLHyWwQtEPIvqWxXhP0Nllvu2nWJl1chB0 glop102@genserver"
    ];

    # Perl only came in through the NixOS activation scripts; these replace
    # them with the non-perl implementations.
    services.userborn.enable = true;
    system.etc.overlay.enable = true;
    system.tools.nixos-generate-config.enable = false;
    # nixos-rebuild-ng is Python. nixos-anywhere only runs nixos-install
    # (shell) on the target, which stays.
    system.tools.nixos-rebuild.enable = false;
    environment.defaultPackages = [ ];
    system.forbiddenDependenciesRegexes = [
      "perl"
      "python3"
    ];

    system.build.nixosAnywhereKexec =
      pkgs.runCommand "do-kexec-tarball"
        {
          nativeBuildInputs = [ pkgs.gnutar ];
        }
        ''
          mkdir -p kexec $out
          cp ${config.system.build.kernel}/${config.system.boot.loader.kernelFile} kexec/bzImage
          cp ${config.system.build.netbootRamdisk}/initrd kexec/initrd
          cp ${pkgs.pkgsStatic.kexec-tools}/bin/kexec kexec/kexec
          cp ${runScript} kexec/run
          tar --owner=0 --group=0 --mtime=@1 -cf $out/do-kexec.tar kexec
        '';
  };
}
