{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./desktop.nix
    ./extras.nix
  ];
  config = {
    networking.hostName = "genserver";
    services.openssh.enable = true;
    # Use systemd for networking
    services.resolved.enable = true;
    networking.useDHCP = false;
    systemd.network.enable = true;

    #systemd.network.networks."40-e" = {
    #  matchConfig.Name = "e*";  # enp9s0 (10G) or enp8s0 (1G)
    #  networkConfig = {
    #    IPv6AcceptRA = true;
    #    DHCP = "yes";
    #  };
    #};

    glopFlake.desktop.commonEnable = true;

  };
}
