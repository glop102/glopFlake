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
      extraPackages = with pkgs; [
        adwaita-icon-theme # mouse cursor and icons
        gnome-themes-extra # dark adwaita theme
      ];
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

  };
}
