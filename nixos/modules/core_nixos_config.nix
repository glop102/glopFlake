{ lib, config, ... }:
{
  options = {
    glopFlake.uefiSystem = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Nixos system config is a typical UEFI system";
    };
  };
  config = lib.mkMerge [
    {
      # Allow unfree packages like steam
      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      # A root shell on the console when boot fails, without a password (most
      # hosts have no root password, and reaching the console already means
      # physical or provider-console access). Replaces the scripted initrd's
      # boot.shell_on_fail, which systemd ignores. Two halves:
      #  - stage 1: the initrd drops into emergency mode on a failed root
      #    mount or similar.
      #  - stage 2: emergency/rescue mode runs sulogin, which refuses to open
      #    a shell for a locked root account unless forced.
      boot.initrd.systemd.emergencyAccess = lib.mkDefault true;
      systemd.services.emergency.environment.SYSTEMD_SULOGIN_FORCE = "1";
      systemd.services.rescue.environment.SYSTEMD_SULOGIN_FORCE = "1";
      # This is essentially required for any major hardware like GPUs
      hardware.enableRedistributableFirmware = lib.mkDefault true;
    }
    (lib.mkIf config.glopFlake.uefiSystem {
      boot.loader = {
        systemd-boot = {
          enable = lib.mkDefault true;
          configurationLimit = 6;
        };
        efi.canTouchEfiVariables = lib.mkDefault true;
      };
    })
    (lib.mkIf (!config.glopFlake.uefiSystem) {
      # Spell out the BIOS/MBR case instead of letting the nixpkgs defaults
      # decide. grub.enable happens to default to true today, but that is a
      # default we do not control
      boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
        grub = {
          enable = true;
          efiSupport = false;
          configurationLimit = 4;
          # No `devices` default on purpose: guessing a disk here would install
          # the MBR onto the wrong one. Each BIOS host sets it (or the platform
          # module does, e.g. digital-ocean-config.nix pins /dev/vda), and grub
          # asserts loudly if nobody did.
        };
      };
    })
  ];
}
