{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.profile.games.enable = lib.mkEnableOption "the glopFlake gaming profile";
  config = lib.mkIf config.glopFlake.profile.games.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      discord
    ];
  };
}
