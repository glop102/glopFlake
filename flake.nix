{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    };
  };
  outputs = {self, nixpkgs}: 
  let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    overlays = {
      default = import ./overlay.nix;
    };
    legacyPackages = forAllSystems (system:
      nixpkgs.legacyPackages.${system}.appendOverlays 
        (builtins.attrValues self.overlays)
    );
    packages = forAllSystems (system: {
      inherit (self.legacyPackages.${system})
        hello-static
        ;
    });
  };
}
