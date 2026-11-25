{
  lib,
  modulesPath,
  ...
}:
# The erowiki DigitalOcean droplet: static landing page, the Foxtato Softworks
# wiki, and the magicalcamp redirect. Nothing in here is specific to one
# droplet, so the same system installs onto a test droplet or production.
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ./disk-config.nix
    ./web.nix
    ./wiki.nix
  ];
  config = {
    # Plain priority on purpose: digital-ocean-config.nix sets "" at mkDefault
    # (meaning "ask the metadata server"), and a fixed name is wanted here.
    networking.hostName = "erowiki";
    system.stateVersion = "26.05";
    time.timeZone = "America/New_York";

    # Addresses come from droplet metadata at boot; see
    # nixos/modules/digitalocean_network.nix.
    glopFlake.digitalOceanNetwork.enable = true;
    networking.firewall.allowedTCPPorts = [
      22
      80
      443
    ];

    # Droplets boot through SeaBIOS (legacy BIOS, GPT disk with a BIOS boot
    # partition), the same as the Ubuntu image did.
    glopFlake.uefiSystem = false;

    # core_nixos_config turns this on for real hardware. It pulls the whole
    # linux-firmware tree into the closure, and a virtio VM needs none of it.
    hardware.enableRedistributableFirmware = lib.mkForce false;

    virtualisation.digitalOcean = {
      # The default rewrites /etc/nixos from droplet user-data on boot and
      # rebuilds from that. This host is only ever deployed from the flake.
      rebuildFromUserData = false;
      # Still let the DO console's SSH keys in as a fallback. The service only
      # writes /root/.ssh/authorized_keys if the file does not exist yet.
      setSshKeys = true;
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/rXzI73PlLHyWwQtEPIvqWxXhP0Nllvu2nWJl1chB0 glop102@genserver"
    ];
    services.openssh.settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
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
