{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.desktop = {
    games.enable = lib.mkEnableOption "glopFlake config to bring in games and related things";
  };
  config = lib.mkIf config.glopFlake.desktop.games.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      discord
    ];
  };
}
