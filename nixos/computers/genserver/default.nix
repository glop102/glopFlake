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
    ./network.nix
  ];
  config = {
    networking.hostName = "genserver";

    system.stateVersion = "26.05";

    glopFlake.desktop.commonEnable = true;

  };
}
