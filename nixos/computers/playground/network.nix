{ ... }:
{
  config = {
    systemd.network.networks."40-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig.DHCP = "yes";
    };
    services.openssh.enable = true;

    # Use systemd for networking
    services.resolved.enable = true;
    networking.useDHCP = false;
    systemd.network.enable = true;
  };
}
