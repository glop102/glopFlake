{
rustPlatform,
installShellFiles
}:

rustPlatform.buildRustPackage {
  pname = "example";
  version = "0.1";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    installShellCompletion --cmd example --bash <($out/bin/example completions bash)
  '';
}
