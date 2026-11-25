{
  flakeInputs,
  lib,
  ...
}:
{
  imports = [
    flakeInputs.disko.nixosModules.disko
  ];
  config = {
    # disko's EF02 handling and digital-ocean-config.nix both add /dev/vda,
    # and the two lists concatenate into a duplicate that grub rejects.
    boot.loader.grub.devices = lib.mkForce [ "/dev/vda" ];

    # GPT with a 1M BIOS boot partition for grub's core image, then one ext4
    # root. No separate /boot: grub reads the kernels straight off ext4.
    disko.devices.disk.main = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          bios = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [
                "-L"
                "nixos"
              ];
            };
          };
        };
      };
    };
  };
}
