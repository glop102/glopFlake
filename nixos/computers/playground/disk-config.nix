{ flakeInputs, ... }:
{
  imports = [
    flakeInputs.disko.nixosModules.disko
  ];
  config.disko.devices = {
    disk.main-os = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "ESP";
	    label = "ESP";
	    type = "EF00";
            start = "1MiB";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          rootfs = {
            name = "rootfs";
	    label = "nixos-rootfs";
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
}
