{ pkgs, config, ... }:
{
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };
  environment.systemPackages = with pkgs; [
  ];

  # Turn on graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Allow the gpu module to be added to the initrd for earlier init
  boot.initrd.kernelModules = ["amdgpu"];
}
