{ pkgs, config, ... }:
{
  # Turn on graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Allow the gpu module to be added to the initrd for earlier init
  boot.initrd.kernelModules = [ "amdgpu" ];
}
