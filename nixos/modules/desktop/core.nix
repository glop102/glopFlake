{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.desktop = {
    core.enable = lib.mkEnableOption "Enable the glopFlake core desktop style configs";
  };
  config = lib.mkIf config.glopFlake.desktop.core.enable {
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # Even though the gnome keyring is running, we want it to auto-unlock when the login manager starts a session
    #security.pam.services = {
    #  greetd.enableGnomeKeyring = true;
    #  swaylock.enableGnomeKeyring = true;
    #};

    environment.systemPackages = with pkgs; [
      # Wayland utils
      grim
      slurp
      wl-clipboard
    ];
  };
}
