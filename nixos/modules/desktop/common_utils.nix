{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.desktop = {
    commonPrograms = lib.mkEnableOption "Enable the glopFlake common desktop programs";
  };
  config = lib.mkIf config.glopFlake.desktop.commonPrograms {
    environment.systemPackages = with pkgs; [
      htop
      vim
      coreutils
      git
      curl
      wget
      hardinfo2 # System information and benchmarks for Linux systems
      wayland-utils # Wayland utilities
      wl-clipboard # Command-line copy/paste utilities for Wayland
      waypipe

      # GUI programs
      ghostty
      mpv
      gimp
      chromium
      eog
      evince
      libreoffice


      # Some random other things
      claude-code
    ];

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # Python things
        ms-python.python #unclear what this encompasses
        ms-python.debugpy # debugger
        ms-python.pylint # linting
        ms-python.vscode-pylance # LSP
        ms-python.mypy-type-checker

        # Nix things
        bbenoist.nix
      ];
    };

    programs = {
      chromium.enable = true; # Does not actually add chromium to the system, just changes policies?
      firefox.enable = true;
    };
  };
}
