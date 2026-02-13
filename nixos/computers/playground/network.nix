{ ... }:
{
  config.systemd.network.networks."40-enp1s0" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "yes";
  };
}
