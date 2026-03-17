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
              name = "boot";
              label = "boot";
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
              label = "rootfs";
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

    # The local ZFS Array should get auto-imported
    boot.zfs.extraPools = [ "RAID" ];

    # Also we should mount the NFS shares from TerminalDogma
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true; # needed for NFS
    systemd.mounts =
      map
        (td_share: {
          type = "nfs";
          mountConfig = {
            Options = "noatime,nfsvers=4,nosuid,_netdev";
          };
          what = "192.168.1.2:/mnt/ZFS2/${td_share}";
          where = "/media/TerminalDogma/${td_share}";
        })
        [
          "Video"
          "Executables"
          "Documents"
          "Dumping\\040Ground"
        ];

    systemd.automounts =
      map
        (td_share: {
          wantedBy = [ "multi-user.target" ];
          automountConfig = {
            TimeoutIdleSec = "600";
          };
          where = "/media/TerminalDogma/${td_share}";
        })
        [
          "Video"
          "Executables"
          "Documents"
          "Dumping\\040Ground"
        ];
  };
}
