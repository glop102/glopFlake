{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.glopFlake.desktop.greeter;
in
{
  options.glopFlake.desktop.greeter = {
    enable = lib.mkEnableOption "glopFlake greeter config enable";
    greeterType = lib.mkOption {
      type = lib.types.enum [ "regreet" ];
      default = "regreet";
      description = "Which greeter to use";
    };
    # TODO background image - probably have it default to some glopFlake.desktop.customization.wallpaper?
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.greeterType == "regreet") (
        let
          sway_config = pkgs.writeTextFile {
            name = "regreet_sway_config";
            text = ''
              # Run ReGreet and upon its exit, have sway containing regreet also exit
              exec "${pkgs.regreet}/bin/regreet; swaymsg exit"
              bindsym Mod4+shift+e exec ${pkgs.sway}/bin/swaynag \
              -t warning \
              -m "What do you want to do?" \
              -b "Poweroff" "${pkgs.systemd}/bin/systemdctl poweroff" \
              -b "Reboot" "${pkgs.systemd}/bin/systemdctl reboot"

              include /etc/sway/config.d/*
            '';
          };
        in
        {
          services.greetd = {
            enable = true;
            settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${sway_config}";
          };
          programs.regreet.enable = true;
        }
      )) # regreet config
    ]
  );
}
