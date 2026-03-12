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
  };
}
