{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.ssh = {
    enable = lib.mkEnableOption "glopFlake settings for SSH";
  };
  config = lib.mkIf config.glopFlake.ssh.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };

    services.fail2ban.enable = true;

  };
}
