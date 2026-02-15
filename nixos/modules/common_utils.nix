{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    htop
    vim
    coreutils
    git
    curl
    wget
    mpv
    hardinfo2 # System information and benchmarks for Linux systems
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland
    gimp
    chromium
  ];

  programs.vscode = {
    enable = true;
    extensions = [];
  };

  programs = {
    chromium.enable = true; # Does not actually add chromium to the system, just changes policies?
    firefox.enable = true;
  };
}
