{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.fonts = lib.mkEnableOption "glopFlake add extra fonts";
  config = lib.mkIf config.glopFlake.fonts {
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji
        noto-fonts-emoji-blob-bin
        font-awesome
        source-han-sans
        source-han-serif
      ];
      fontconfig.defaultFonts = {
        serif = [
          "Noto Serif"
          "Source Han Serif"
        ];
        sansSerif = [
          "Noto Sans"
          "Source Han Sans"
        ];
      };
    };

  };
}
