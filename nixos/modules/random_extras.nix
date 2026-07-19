{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.randomExtras = lib.mkEnableOption "Enable random extra config of base nixos options from the glopFlake";
  config = lib.mkIf config.glopFlake.randomExtras {
    # Adds the locate command and preiodically updates the database
    services.locate.enable = true;
    environment.systemPackages = with pkgs; [
      usbutils
      vim
    ];
  };
}
