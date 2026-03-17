{
  config,
  lib,
  ...
}:
{
  config = {
    services.openssh.enable = true;
    # Use systemd for networking
    services.resolved.enable = true;
    networking.useDHCP = false;
    systemd.network.enable = true;

    systemd.network.networks."40-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig = {
        IPv6AcceptRA = true;
        DHCP = "yes";
      };
    };
  };
}
