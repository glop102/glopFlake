{ ... }:
{
  config = {
    systemd.network.networks."40-ethernet" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
    services.openssh.enable = true;

    # Use systemd for networking
    services.resolved.enable = true;
    networking.useDHCP = false;
    systemd.network.enable = true;
  };
}
