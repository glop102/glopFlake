{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.glopFlake.profile.regreet;
in
{
  options.glopFlake.profile.regreet.enable = lib.mkEnableOption "the glopFlake ReGreet profile";
  config = lib.mkIf cfg.enable (
    let
      swayConfig = pkgs.writeTextFile {
        name = "regreet_sway_config";
        text = ''
          # Run ReGreet and upon its exit, have sway containing regreet also exit
          exec "${pkgs.regreet}/bin/regreet; swaymsg exit"
          bindsym Mod4+shift+e exec ${pkgs.sway}/bin/swaynag \
          -t warning \
          -m "What do you want to do?" \
          -b "Poweroff" "${pkgs.systemd}/bin/systemctl poweroff" \
          -b "Reboot" "${pkgs.systemd}/bin/systemctl reboot"

          include /etc/sway/config.d/*
        '';
      };
    in
    {
      services.greetd = {
        enable = true;
        settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
      programs.regreet.enable = true;
    }
  );
}
