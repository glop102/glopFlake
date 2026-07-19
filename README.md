# Personal Nix Flake

### Layout

- `nixos/computers/`: Per-host configuration.
- `nixos/modules/`: Reusable NixOS modules.
- `nixos/profiles/`: Optional groups of related configuration.
- `pkgs/`: Local packages.
- `apps.nix`: Runnable flake applications.
- `overlay.nix`: Package overrides and additions.

### TODO

- Configure Sway idle and suspend locking.
- Add flake checks for NixOS and Disko outputs.

### Formatting

```sh
nix fmt
```

### Setting up the playground image in a VM

It is nice to have a VM that I can just try out random configs in and having the ability to start from scratch to keep things clean is great to have. Without going through the nixos handbook to install nixos, I have found some random resources online showing how to use this nixos-anywhere repo to do the install. It seems to be about the easiest solution to just drop an install onto a disk that follows some disko config.

1. Make the ISO to boot in the VM
  * nix build .#nixosConfigurations.playground.config.system.build.images.iso-installer --out-link iso
1. Boot the VM with the iso above
  * nix run .#playground-vm -- --iso iso/iso/*.iso
  * The first run prompts for the maximum size of the persistent virtual disk
  * In the installer image, set a password for the nixos user - the letter 'a' makes a great temporary password
1. From the host, point nixos-anywhere at the forwarded SSH port
  * nix run github:nix-community/nixos-anywhere -- --flake '.#playground' --target-host nixos@localhost --ssh-port 2222 --post-kexec-ssh-port 2222
  * this will reboot the VM and eject the iso automatically
1. First boot, take care of a couple things
  * change the user password

Later boots do not need the installer image:

```sh
nix run .#playground-vm
```
