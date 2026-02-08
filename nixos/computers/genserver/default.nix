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
  ];
  config = {
    nix.settings = {
      trusted-users = [ "glop" "root" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    users.users.glop = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
    environment.systemPackages = with pkgs; [
      chromium
      firefox
      vim
      coreutils
      git
      curl
      wget
    ];

    boot.loader = {
      systemd-boot = {
        enable = true;
	configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    networking.hostName = "genserver";
    services.openssh.enable = true;
    # Use systemd for networking
    services.resolved.enable = true;
    networking.useDHCP = false;
    systemd.network.enable = true;

    #systemd.network.networks."40-e" = {
    #  matchConfig.Name = "e*";  # enp9s0 (10G) or enp8s0 (1G)
    #  networkConfig = {
    #    IPv6AcceptRA = true;
    #    DHCP = "yes";
    #  };
    #};

  };
}
