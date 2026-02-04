{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    #(import "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix")
  ];
  config = {
    boot.loader.grub.enable = false;
    users.extraUsers.glop = {
      password = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
    services.avahi.enable = true;
    environment.systemPackages = with pkgs; [
    ];

    #virtualisation.qemu.networkingOptions = [
    #    "-net nic,netdev=user.0,model=virtio"
    #    "-netdev user,id=user.0,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS},hostfwd=tcp::5353-:5353"
    #];
  };
}
