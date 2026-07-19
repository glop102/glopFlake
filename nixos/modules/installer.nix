{ config, ... }:
let
  diskoScript = config.system.build.diskoScript;
  targetSystem = config.system.build.toplevel;
in
{
  image.modules.iso-installer = { config, pkgs, ... }: {
    boot.zfs.forceImportRoot = false;
    system.build.installImage = pkgs.writeShellApplication {
      name = "install-image";
      text = ''
        if (( EUID != 0 )); then
          exec ${pkgs.sudo}/bin/sudo "$0" "$@"
        fi

        printf 'Provisioning disks and installing the configured system.\n'
        ${diskoScript}
        ${pkgs.nixos-install-tools}/bin/nixos-install --system ${targetSystem}
      '';
    };
    environment.systemPackages = [ config.system.build.installImage ];
  };
}
