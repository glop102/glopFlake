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
    users.extraUsers.glop = {
      password = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
    environment.systemPackages = with pkgs; [
      chromium
      firefox
      vim
    ];

  };
}
