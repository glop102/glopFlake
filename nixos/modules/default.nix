{
  lib,
  config,
  ...
}:
let
  cfg = config.glopFlake;
in
{
  imports = [
    ./core_nixos_config.nix
    ./fonts.nix
    ./random_extras.nix
    ./desktop/audio.nix
    ./desktop/common_utils.nix
    ./desktop/core.nix
    ./desktop/games.nix
    ./desktop/greeter.nix
    ./desktop/sway.nix
    ./desktop/users.nix
  ];
  options = {
    glopFlake.desktop.commonEnable = lib.mkEnableOption "Enable the common core desktop configs for the glopFlake";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.desktop.commonEnable {
      glopFlake = {
        fonts = true;
        random_extras = true;
      };
      glopFlake.desktop = {
        core.enable = true;
        commonPrograms = true;
        audio.enable = true;
        sway.enable = true;
        users.enable = true;
        greeter.enable = true;
      };
    })
  ];
}
