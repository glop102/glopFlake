{ pkgs, config, ... }:
{
  # TODO Add Sway and the config for it, as well as some notification daemon
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };
  environment.systemPackages = with pkgs; [
  ];
}
