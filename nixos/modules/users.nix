{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  config = {
    nix.settings = {
      trusted-users = [ "glop" "root" ];
    };
    users.users.glop = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

  };
}
