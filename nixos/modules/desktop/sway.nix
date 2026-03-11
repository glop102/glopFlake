{pkgs, lib, config}:
{
  let
    cfg = config.glopFlake.desktop.sway;
  in
  options.glopFlake.desktop.sway ={
    enable = lib.mkEnableOption "Enable the Sway config from the glopFlake ";
  };
  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
    };
  };
}
