{lib,...}:
{
  config = {
    boot.kernelPatches = [
    #{
      # We need to have some things built into the kernel in order to boot as a VM guest
      # Alternativly we could have included the VIRTIO modules in the initrd too...
      #name = "virtio";
      #patch = null;
      #structuredExtraConfig = with lib.kernel; {
      #  VIRTIO = yes;
      #  VIRTIO_PCI = yes;
      #  VIRTIO_BLK = yes;
      #  VIRTIO_CONSOLE = yes;
      #  VIRTIO_NET = yes;
      #  DRM_VIRTIO_GPU = yes;
      #};
    #}
  ];
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
  };
}
