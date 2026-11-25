{
  imports = [
    ./core_nixos_config.nix
    ./digitalocean_network.nix
    ./virtio_guest_kernel.nix
    ./fonts.nix
    ./installer.nix
    ./random_extras.nix
    ./users.nix
    ./desktop/audio.nix
    ./desktop/common_utils.nix
    ./desktop/core.nix
  ];
}
