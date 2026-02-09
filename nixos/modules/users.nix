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
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/rXzI73PlLHyWwQtEPIvqWxXhP0Nllvu2nWJl1chB0 glop102@genserver"
      ];
    };

  };
}
