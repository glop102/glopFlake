{ ... }:
{
  # Have the Virtio kernel modules added into the initrd
  boot.initrd.kernelModules = [
    "virtio"
    "virtio_pci"
    "virtio_ring"
    "virtio_console"
    "virtio_blk"
    "virtio_scsi"
    "virtio_gpu"
    "virtio_dma_buf"
    "virtio_balloon"
    "virtio_net"
    "virtio_rng"
  ];
}
