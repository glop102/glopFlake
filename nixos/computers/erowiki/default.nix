{
  lib,
  ...
}:
# The erowiki DigitalOcean droplet: static landing page, the Foxtato Softworks
# wiki, and the magicalcamp redirect. Nothing in here is specific to one
# droplet, so the same system installs onto a test droplet or production.
#
# nixpkgs' digital-ocean-config.nix is deliberately not imported. Nearly all
# of it was either overridden here or replaced (initrd modules by the guest
# kernel, addressing by do-network, grub's disk by disko); the few droplet
# settings that were worth having are below.
{
  imports = [
    ./disk-config.nix
    ./web.nix
    ./wiki.nix
  ];
  config = {
    networking.hostName = "erowiki";
    system.stateVersion = "26.05";
    time.timeZone = "America/New_York";

    # Addresses come from droplet metadata at boot; see
    # nixos/modules/digitalocean_network.nix.
    glopFlake.digitalOceanNetwork.enable = true;
    glopFlake.virtioGuestKernel.enable = true;

    # Droplets boot through SeaBIOS (legacy BIOS, GPT disk with a BIOS boot
    # partition), the same as the Ubuntu image did.
    glopFlake.uefiSystem = false;

    # DO's web Recovery Console is the VGA screen. The last console= is
    # /dev/console, where systemd and the emergency shell go, so tty0 comes
    # last; kernel messages still go to both. Reboot on a kernel panic instead
    # of sitting there until someone notices.
    boot.kernelParams = [
      "console=ttyS0"
      "console=tty0"
      "panic=1"
    ];
    # Resizing a droplet grows the disk; take the new space on next boot.
    boot.growPartition = true;
    fileSystems."/".autoResize = true;

    # DO's metrics agent, for the droplet graphs in the control panel.
    services.do-agent.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/rXzI73PlLHyWwQtEPIvqWxXhP0Nllvu2nWJl1chB0 glop102@genserver"
    ];
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    # 1GB of RAM. zram absorbs most pressure; the swapfile is the backstop so
    # the OOM killer does not take out mariadb during a spike.
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };
    swapDevices = [
      {
        device = "/var/swapfile";
        size = 1024;
      }
    ];

    # Systems are built on genserver and pushed here, so the droplet's store
    # only has to hold what is deployed.
    nix = {
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };
    boot.loader.grub.configurationLimit = lib.mkForce 5;

    # Man pages and friends are dead weight on a box nobody logs into much.
    documentation.enable = false;
  };
}
