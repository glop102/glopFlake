{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, nixpkgs, ... }@flakeInputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      inherit nixpkgs;
      overlays = {
        default = import ./overlay.nix;
      };
      legacyPackages = forAllSystems (
        system: nixpkgs.legacyPackages.${system}.appendOverlays (builtins.attrValues self.overlays)
      );
      packages = forAllSystems (system: {
        inherit (self.legacyPackages.${system})
          hello-static
          ;
      });
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "treefmt";
          text = ''treefmt "$@"'';
          runtimeInputs = [
            pkgs.deadnix
            pkgs.nixfmt
            pkgs.shellcheck
            pkgs.treefmt
          ];
        }
      );
      nixosConfigurations =
        let
          mkNixos = nixpkgs.lib.nixosSystem;
        in
        {
          playground = mkNixos {
            system = "x86_64-linux";
            specialArgs = { inherit flakeInputs; };
            modules = [
              ./nixos/modules
              ./nixos/computers/playground
            ];
          };
          genserver = mkNixos {
            system = "x86_64-linux";
            specialArgs = { inherit flakeInputs; };
            modules = [
              ./nixos/modules
              ./nixos/computers/genserver
            ];
          };
        };
    };
}
