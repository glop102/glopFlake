{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    };
  };
  outputs = {self, nixpkgs}: {
    legacyPackages = nixpkgs.legacyPackages;
  };
}
