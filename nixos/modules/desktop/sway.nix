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
    # TODO - make this do replaceVars and have some sort of prefered terminal and stuff from the flake
    environment.etc."sway/config".source = pkgs.replaceVars ./sway.config
    (with pkgs; {
      inherit wl-clipboard grim slurp swaynotificationcenter xfce4-terminal wmenu sway;
    });
  };
}
