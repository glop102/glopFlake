{ ... }:
{
  # Turn on graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Allow the gpu module to be added to the initrd for earlier init
  boot.initrd.kernelModules = [ "amdgpu" ];

  environment.etc."sway/config.d/outputs.conf".text = ''
    output DP-1 position 0,0
    output DP-3 position 2560,0
  '';
}
