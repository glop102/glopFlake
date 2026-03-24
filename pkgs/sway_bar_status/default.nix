{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "sway_bar_status";
  version = "0.0.1";

  src = ./.;

  cargoHash = "sha256-+63SHiy/OLGjBNTLwO5VnbRUp2L/bptcpjU24puXzGU=";

  meta = with lib; {
    description = "Random hardcoded status program for my personal sway status";
    license = licenses.unlicense;
    maintainers = [ ];
  };
}
