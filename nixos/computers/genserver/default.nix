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
    networking.hostId = "7c1826b0";

    system.stateVersion = "26.05";

    glopFlake.desktop.commonEnable = true;
    glopFlake.desktop.games.enable = true;

  };
}
