{ ... }:
{
  imports = [
    ./disk-config.nix
    ./kernel.nix
    ./network.nix
    ./desktop.nix
  ];
  config = {
    services.qemuGuest.enable = true;

    glopFlake = {
      users.enable = true;
      profile.games.enable = true;
      desktop.audio.enable = true;
    };

    system.stateVersion = "26.05";

    networking.hostName = "playground";

  };
}
