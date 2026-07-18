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
      random_extras = true;
      users.enable = true;
      profile.programmingTools.enable = true;
      desktop = {
        core.enable = true;
        commonPrograms = true;
        audio.enable = true;
        sway.enable = true;
        greeter.enable = true;
        games.enable = true;
      };
    };

    time.timeZone = "America/New_York";

  };
}
