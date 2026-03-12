{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.glopFlake.desktop.users = {
    enable = lib.mkEnableOption "Add the glopFlake default users";
  };
  config = lib.mkIf config.glopFlake.desktop.users.enable {
    nix.settings.trusted-users = [
      "glop102"
      "root"
    ];
    users.users.glop102 = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/rXzI73PlLHyWwQtEPIvqWxXhP0Nllvu2nWJl1chB0 glop102@genserver"
      ];
    };

  };
}
