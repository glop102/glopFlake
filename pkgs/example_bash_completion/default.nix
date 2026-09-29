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
    installShellCompletion --cmd example --zsh <($out/bin/example completions zsh)
    installShellCompletion --cmd example --fish <($out/bin/example completions fish)
  '';
}
