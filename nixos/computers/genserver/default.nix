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

    glopFlake = {
      fonts = true;
      randomExtras = true;
      users.enable = true;
      profile = {
        programmingTools.enable = true;
        games.enable = true;
        sway.enable = true;
        regreet.enable = true;
      };
      desktop = {
        core.enable = true;
        commonPrograms = true;
        audio.enable = true;
      };
    };

    time.timeZone = "America/New_York";

  };
}
