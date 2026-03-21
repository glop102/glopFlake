{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.random_extras = lib.mkEnableOption "Enable random extra config of base nixos options from the glopFlake";
  config = lib.mkIf config.glopFlake.random_extras {
    # Adds the locate command and preiodically updates the database
    services.locate.enable = true;
  };
}
