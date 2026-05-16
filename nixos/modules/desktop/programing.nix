{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.glopFlake.desktop = {
    programmingTools = lib.mkEnableOption "Enable the glopFlake common items for programming";
  };
  config = lib.mkIf config.glopFlake.desktop.programmingTools {
    environment.systemPackages = with pkgs; [
      claude-code
      opencode
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
  };
}
