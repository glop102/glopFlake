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
    # Allow unfree packages like steam
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    services.qemuGuest.enable = true;

    environment.systemPackages = with pkgs; [
    ];
    programs = {
      chromium.enable = true;
      firefox.enable = true;
      sway.enable = true;
      steam.enable = true;
    };

    boot.kernelParams = [ "boot.shell_on_fail" ];
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    system.stateVersion = "26.05";

    networking.hostName = "playground";
    services.openssh.enable = true;
    # Use systemd for networking
    services.resolved.enable = true;
    networking.useDHCP = false;
    systemd.network.enable = true;

  };
}
