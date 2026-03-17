{ pkgs, config, ... }:
{
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };
  environment.systemPackages = with pkgs; [
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
