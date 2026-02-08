# Personal Nix Flake

### Setting up the playground image in a VM

It is nice to have a VM that I can just try out random configs in and having the ability to start from scratch to keep things clean is great to have. Without going through the nixos handbook to install nixos, I have found some random resources online showing how to use this nixos-anywhere repo to do the install. It seems to be about the easiest solution to just drop an install onto a disk that follows some disko config.

1. Make the ISO to boot in the VM
  * nix build .#nixosConfigurations.playground.config.system.build.images.iso-installer --out-link iso
1. Boot the VM with the iso above
  * The VM should have UEFI as the boot environment set. (OVMF seems to be installed by default with virt-manager+qemu on gentoo)
  * A new harddrive image is fine, or you can interupt systemd-boot and jump into the UEFI to select the disk drive to boot from
  * In the installer image, set a password for the nixos user - the letter 'a' makes a great temporary password
1. From the host, point nixos-anywhere at the VM ip
  * nix run github:nix-community/nixos-anywhere -- --flake '.#playground' --target-host nixos@192.168.122.253
  * this will reboot the VM and eject the iso automatically
1. First boot, take care of a couple things
  * change the user password
