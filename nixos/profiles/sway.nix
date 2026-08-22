{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.glopFlake.profile.sway;
in
{
  options.glopFlake.profile.sway = {
    enable = lib.mkEnableOption "the glopFlake Sway profile";
    idle = {
      enable = lib.mkEnableOption "powering off the displays after a period of inactivity";
      screentimeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        example = 900;
        description = "Seconds of inactivity before the displays are powered off.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
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
        lxqt-policykit = lxqt.lxqt-policykit;
      }
    );

    # Power the displays off once nothing has touched an input for a while.
    # The inhibit_idle rules cover whatever does not implement the protocol but is fullscreen anyway.
    environment.etc."sway/config.d/idle.conf" = lib.mkIf cfg.idle.enable {
      text = ''
        exec ${pkgs.swayidle}/bin/swayidle \
          timeout ${toString cfg.idle.screentimeout} '${pkgs.sway}/bin/swaymsg "output * power off"' \
          resume '${pkgs.sway}/bin/swaymsg "output * power on"'

        for_window [app_id=".*"] inhibit_idle fullscreen
        for_window [class=".*"] inhibit_idle fullscreen
      '';
    };

    # Turn on the xdg portal support for things like screenshots
    xdg.portal.wlr.enable = true;
    # Also something about workarounds for apps trying to open data in other programs
    xdg.portal.xdgOpenUsePortal = true;

    environment.systemPackages = with pkgs; [
      lxqt.lxqt-policykit
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

  };
}
