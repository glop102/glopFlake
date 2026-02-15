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
  ];

  programs.vscode = {
    enable = true;
    extensions = [];
  };

  programs = {
    chromium.enable = true;
    firefox.enable = true;
  };
}
