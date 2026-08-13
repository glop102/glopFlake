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

      boot.kernelParams = [ "boot.shell_on_fail" ];
      # This is essentially required for any major hardware like GPUs
      hardware.enableRedistributableFirmware = true;
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
