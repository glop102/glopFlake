{ flakeInputs, ... }:
{
  imports = [
    flakeInputs.disko.nixosModules.disko
  ];
  config = {
    disko.devices = {
      disk.main-os = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "ESP";
              start = "1MiB";
              size = "1GiB";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            rootfs = {
              name = "rootfs";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
    boot.zfs.extraPools = [ "RAID" ];
  };
}
