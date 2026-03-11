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
    ./kernel.nix
    ./network.nix
    ./desktop.nix
  ];
  config = {
    services.qemuGuest.enable = true;

    environment.systemPackages = with pkgs; [
      discord
    ];

    programs = {
      steam.enable = true;
    };

    system.stateVersion = "26.05";

    networking.hostName = "playground";

    glopFlake.desktop.commonEnable = true;

  };
}
