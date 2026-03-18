{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.glopFlake.desktop.sway = {
    enable = lib.mkEnableOption "Enable the Sway config from the glopFlake";
  };
  config = lib.mkIf config.glopFlake.desktop.sway.enable {
    programs.sway = {
      enable = true;
    };
    # TODO - make this have some sort of prefered terminal and stuff from the flake
    environment.etc."sway/config".source = pkgs.replaceVars ./sway.config (
      with pkgs;
      {
        inherit
          wl-clipboard
          grim
          slurp
          swaynotificationcenter
          xfce4-terminal
          wmenu
          sway
          ;
      }
    );

    # Turn on the xdg portal support for things like screenshots
    xdg.portal.wlr.enable = true;
    # Also something about workarounds for apps trying to open data in other programs
    xdg.portal.xdgOpenUsePortal = true;

    # We need some sort of display manager+greeter to log in with and mainly to stup variables and stuff for the window manager
    services.greetd = {
      enable = true;
    };
    programs.regreet.enable = true;
  };
}
