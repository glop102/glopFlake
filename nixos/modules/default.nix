{lib, config}:
{
  imports = [
    ./users.nix
    ./common_utils.nix
    ./audio.nix
    ./core_nixos_config.nix
    ./desktop/sway.nix
  ];
  options = {
    glopFlake.desktop.commonEnable = lib.mkEnableOption "Enable the common core desktop configs for the glopFlake";
  };
  let
    cfg = config.glopFlake;
  in
  config = lib.mkMerge [
    (lib.mkIf cfg.desktop.commonEnable {
      glopFlake.desktop.sway = true;
    })
  ];
}
