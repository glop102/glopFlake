{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../modules
    ./disk-config.nix
    ./kernel.nix
  ];
  config = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    services.qemuGuest.enable = true;

    environment.systemPackages = with pkgs; [
      chromium
      firefox
      vim
      coreutils
      git
      curl
      wget
    ];

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
