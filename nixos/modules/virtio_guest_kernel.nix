{
  config,
  lib,
  pkgs,
  ...
}:
# A kernel built for a KVM guest with virtio devices and nothing else.
#
# The stock nixpkgs kernel starts from `defconfig` plus common-config.nix and
# answers "m" to every remaining tristate (autoModules), which is how it ends
# up with thousands of modules. Here neither of those applies: the base is the
# upstream x86 defconfig plus the kernel's own kvm_guest.config fragment, and
# everything NixOS needs on top is listed below. Nothing gets turned on
# because a driver happens to exist.
#
# Two things to know when changing it:
#  - NixOS skips its requiredKernelConfig assertions for any kernel built
#    through buildLinux, so a missing option is only found at boot. Test in a
#    VM before deploying.
#  - Everything the system needs early is built in (`yes`), so the initrd has
#    no modules to find. With includeDefaultModules off, an initrd module that
#    is neither built in nor built as a module fails the build, which is the
#    check we want.
let
  cfg = config.glopFlake.virtioGuestKernel;
  inherit (lib.kernel) yes no;

  # The x86 defconfig is a desktop config and builds these in. They are whole
  # subsystems for hardware a virtio guest never has, and built-in code stays
  # in RAM. The console is plain VGA text plus ttyS0, keyboard is i8042.
  defconfigHardware = {
    DRM = no;
    SOUND = no;
    WIRELESS = no;
    WLAN = no;
    ETHERNET = no; # virtio_net lives outside this menu
    USB_SUPPORT = no;
    ATA = no;
    AGP = no;
    PCCARD = no;
    INPUT_JOYSTICK = no;
    INPUT_TABLET = no;
    INPUT_TOUCHSCREEN = no;
    MACINTOSH_DRIVERS = no;
    NFS_FS = no;
    HIBERNATION = no;
  };

  baseConfig = defconfigHardware // {
    # Virtio devices a KVM host (DigitalOcean, qemu) gives a guest.
    VIRTIO_PCI = yes;
    VIRTIO_BLK = yes;
    VIRTIO_NET = yes;
    SCSI_VIRTIO = yes;
    VIRTIO_BALLOON = yes;
    VIRTIO_CONSOLE = yes;
    HW_RANDOM_VIRTIO = yes;
    SERIAL_8250 = yes;
    SERIAL_8250_CONSOLE = yes;

    # Executables, initrd (NixOS compresses it with zstd).
    BINFMT_ELF = yes;
    BINFMT_SCRIPT = yes;
    BLK_DEV_INITRD = yes;
    RD_ZSTD = yes;

    # What systemd checks for at startup or its units rely on: cgroup
    # accounting and limits, BPF for IPAddressDeny / RestrictAddressFamilies,
    # seccomp for SystemCallFilter, namespaces for the Private*/Protect*
    # sandboxing settings, PSI for systemd-oomd.
    DEVTMPFS = yes;
    CGROUPS = yes;
    CGROUP_BPF = yes;
    CGROUP_PIDS = yes;
    MEMCG = yes;
    BPF_SYSCALL = yes;
    PSI = yes;
    SECCOMP = yes;
    SECCOMP_FILTER = yes;
    NAMESPACES = yes;
    USER_NS = yes;
    NET_NS = yes;
    PID_NS = yes;
    IPC_NS = yes;
    UTS_NS = yes;
    FHANDLE = yes;
    DMIID = yes;
    AUTOFS_FS = yes;
    INOTIFY_USER = yes;
    SIGNALFD = yes;
    TIMERFD = yes;
    EPOLL = yes;
    CRYPTO_USER_API_HASH = yes;
    CRYPTO_HMAC = yes;
    CRYPTO_SHA256 = yes;

    # Filesystems. ext4 for the disk; tmpfs with ACLs/xattrs for /run and
    # friends; erofs + overlayfs for the /etc overlay.
    EXT4_FS = yes;
    EXT4_FS_POSIX_ACL = yes;
    EXT4_FS_SECURITY = yes;
    TMPFS = yes;
    TMPFS_POSIX_ACL = yes;
    TMPFS_XATTR = yes;
    EROFS_FS = yes;
    OVERLAY_FS = yes;

    # zramSwap (zstd is its default algorithm).
    SWAP = yes;
    ZRAM = yes;
    # Since 6.12 each zram compressor is its own option; without this zram
    # silently falls back to lzo-rle.
    ZRAM_BACKEND_ZSTD = yes;
    ZSMALLOC = yes;
    CRYPTO_ZSTD = yes;

    # Networking.
    NET = yes;
    INET = yes;
    IPV6 = yes;
    UNIX = yes;
    PACKET = yes;
  };

  # The nftables backend of the NixOS firewall, including the reverse-path
  # check (done with fib). Much less than the iptables-nft compat layer needs.
  firewallConfig = {
    NETFILTER = yes;
    NF_TABLES = yes;
    NF_TABLES_INET = yes;
    NF_TABLES_IPV4 = yes;
    NF_TABLES_IPV6 = yes;
    NF_CONNTRACK = yes;
    NFT_CT = yes;
    NFT_LOG = yes;
    NFT_LIMIT = yes;
    NFT_REJECT = yes;
    NFT_REJECT_INET = yes;
    NFT_FIB_INET = yes;
    NFT_FIB_IPV4 = yes;
    NFT_FIB_IPV6 = yes;
  };

  kernel = pkgs.linux.override {
    enableCommonConfig = false;
    autoModules = false;
    # make runs config targets one at a time, so the fragment is merged on
    # top of defconfig.
    defconfig = "defconfig kvm_guest.config";
    structuredExtraConfig =
      baseConfig // lib.optionalAttrs config.networking.firewall.enable firewallConfig // cfg.extraConfig;
  };
in
{
  options.glopFlake.virtioGuestKernel = {
    enable = lib.mkEnableOption "a minimal kernel for KVM guests with virtio devices";
    extraConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      example = lib.literalExpression "{ SQUASHFS = lib.kernel.yes; }";
      description = "Extra kernel options (lib.kernel values) for what this host needs beyond the base set.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackagesFor kernel;

    # Stage 1 needs nothing the kernel does not already have built in. The
    # default list is for real hardware (SATA, NVMe, USB keyboards).
    boot.initrd.includeDefaultModules = false;

    # A virtio VM has no device that needs firmware blobs.
    hardware.enableRedistributableFirmware = false;
    # No vTPM on these hosts, so no TPM drivers either.
    systemd.tpm2.enable = false;
    boot.initrd.systemd.tpm2.enable = false;

    # Only the nftables options are built in; the iptables-nft compat layer
    # the firewall otherwise uses would need a much longer list.
    networking.nftables.enable = lib.mkDefault true;
    assertions = [
      {
        assertion = config.networking.firewall.enable -> config.networking.nftables.enable;
        message = "glopFlake.virtioGuestKernel only builds the nftables firewall backend; enable networking.nftables.";
      }
    ];
  };
}
