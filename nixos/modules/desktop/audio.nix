{ config, lib, ... }:
{
  options.glopFlake.desktop = {
    audio.enable = lib.mkEnableOption "Enable the common glopFlake desktop audio config";
  };
  config = lib.mkIf config.glopFlake.desktop.audio.enable {
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
  };
}
