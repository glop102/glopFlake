{config, lib, pkgs, ...}:
{
  imports = [];
  config = {
    boot.loader.grub.enable = false;
    users.extraUsers.glop = {
      password = "password";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
