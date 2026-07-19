{ pkgs }:
let
  playgroundVm = pkgs.writeShellApplication {
    name = "playground-vm";
    runtimeInputs = with pkgs; [
      coreutils
      qemu_kvm
      util-linux
    ];
    text = ''
      usage() {
        cat <<'EOF'
      Usage: playground-vm [options]

        --iso PATH        Attach an installer ISO and boot it once
        --disk-size SIZE  Maximum disk size when creating it (default: prompt)
        --memory SIZE     Guest memory (default: 8G)
        --cpus COUNT      Guest CPU count (default: host CPU count)
        --ssh-port PORT   Forward localhost PORT to guest SSH (default: 2222)
        --state-dir PATH  Override the persistent VM state directory
        -h, --help        Show this help
      EOF
      }

      iso=""
      disk_size=""
      memory="8G"
      cpus="$(nproc)"
      ssh_port="2222"
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/glopFlake/playground"

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --iso | --disk-size | --memory | --cpus | --ssh-port | --state-dir)
            if [[ $# -lt 2 ]]; then
              printf 'Missing value for %s\n' "$1" >&2
              exit 2
            fi
            case "$1" in
              --iso) iso="$2" ;;
              --disk-size) disk_size="$2" ;;
              --memory) memory="$2" ;;
              --cpus) cpus="$2" ;;
              --ssh-port) ssh_port="$2" ;;
              --state-dir) state_dir="$2" ;;
            esac
            shift 2
            ;;
          -h | --help)
            usage
            exit 0
            ;;
          *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
        esac
      done

      if [[ ! "$memory" =~ ^[1-9][0-9]*[KMGT]?$ ]]; then
        printf 'Invalid memory size: %s\n' "$memory" >&2
        exit 2
      fi
      if [[ ! "$cpus" =~ ^[1-9][0-9]*$ ]]; then
        printf 'Invalid CPU count: %s\n' "$cpus" >&2
        exit 2
      fi
      if [[ ! "$ssh_port" =~ ^[1-9][0-9]*$ ]] || (( ssh_port > 65535 )); then
        printf 'Invalid SSH port: %s\n' "$ssh_port" >&2
        exit 2
      fi

      if [[ -n "$iso" ]]; then
        if [[ ! -f "$iso" ]]; then
          printf 'Installer ISO does not exist: %s\n' "$iso" >&2
          exit 2
        fi
        iso="$(realpath "$iso")"
      fi

      umask 077
      mkdir -p "$state_dir"
      chmod 700 "$state_dir"
      state_dir="$(realpath "$state_dir")"

      exec 9>"$state_dir/playground.lock"
      if ! flock -n 9; then
        printf 'Another playground VM is using %s\n' "$state_dir" >&2
        exit 1
      fi

      disk="$state_dir/disk.qcow2"
      uefi_vars="$state_dir/OVMF_VARS.fd"

      if [[ ! -e "$disk" ]]; then
        if [[ -z "$disk_size" ]]; then
          if [[ ! -t 0 ]]; then
            printf 'The disk does not exist; pass --disk-size when running non-interactively.\n' >&2
            exit 2
          fi
          read -r -p 'Maximum virtual disk size [64G]: ' disk_size
          disk_size="''${disk_size:-64G}"
        fi
        if [[ ! "$disk_size" =~ ^[1-9][0-9]*[KMGT]?$ ]]; then
          printf 'Invalid disk size: %s\n' "$disk_size" >&2
          exit 2
        fi
        qemu-img create -f qcow2 "$disk" "$disk_size"
      elif [[ -n "$disk_size" ]]; then
        printf '%s already exists; --disk-size only applies during creation.\n' "$disk" >&2
        exit 2
      fi

      if [[ ! -e "$uefi_vars" ]]; then
        install -m 0600 ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd "$uefi_vars"
      fi

      machine="q35,accel=kvm"
      cpu="host"
      if [[ ! -r /dev/kvm || ! -w /dev/kvm ]]; then
        printf 'KVM is unavailable; falling back to software emulation.\n' >&2
        machine="q35,accel=tcg"
        cpu="max"
      fi

      boot_options="menu=on"
      qemu_args=(
        -name playground
        -machine "$machine"
        -cpu "$cpu"
        -smp "$cpus"
        -m "$memory"
        -drive "if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
        -drive "if=pflash,format=raw,file=$uefi_vars"
        -drive "file=$disk,if=virtio,format=qcow2,discard=unmap"
        -device virtio-vga-gl
        -display "gtk,gl=on"
        -device qemu-xhci
        -device usb-tablet
        -device virtio-rng-pci
        -device virtio-balloon-pci
        -audiodev "pipewire,id=audio0"
        -device ich9-intel-hda
        -device "hda-duplex,audiodev=audio0"
        -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$ssh_port-:22"
        -device "virtio-net-pci,netdev=net0"
      )

      if [[ -n "$iso" ]]; then
        qemu_args+=(
          -drive "file=$iso,format=raw,media=cdrom,readonly=on"
        )
        boot_options="menu=on,once=d"
      fi
      qemu_args+=( -boot "$boot_options" )

      printf 'VM state: %s\n' "$state_dir"
      printf 'Guest SSH: ssh -p %s glop102@localhost\n' "$ssh_port"
      exec qemu-system-x86_64 "''${qemu_args[@]}"
    '';
  };
in
{
  playground-vm = {
    type = "app";
    program = "${playgroundVm}/bin/playground-vm";
    meta.description = "Run the persistent playground NixOS VM";
  };
}
