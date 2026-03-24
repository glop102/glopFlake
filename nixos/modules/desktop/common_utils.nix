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
      extensions =
        with pkgs.vscode-extensions;
        [
          # Python things
          ms-python.python # unclear what this encompasses
          ms-python.debugpy # debugger
          ms-python.vscode-pylance # LSP
          ms-python.mypy-type-checker
          #ms-python.pylint # linting - highlights every single function if you don't put a docstring

          # Nix things
          bbenoist.nix
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "sublime-keybindings";
            publisher = "ms-vscode";
            version = "4.1.10";
            sha256 = "sha256-XlogenuBmP+tE18VLH4lUSpOq/7d022n8HgXnKjY3n0=";
          }
        ];
    };

    programs = {
      chromium.enable = true; # Does not actually add chromium to the system, just changes policies?
      firefox.enable = true;
    };
  };
}
