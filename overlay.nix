final: prev: {
  # One Day pkgs will be imported here
  hello-static = final.hello.override {
    stdenv = final.pkgsStatic.stdenv;
  };
  # Upstream nixpkgs is using the 2023 release
  gargoyle = prev.gargoyle.overrideAttrs {
    src = final.fetchFromGitHub {
      owner = "garglk";
      repo = "garglk";
      rev = "2026.1.1";
      hash = "sha256-cBFsxbXQa2xqCwW6Gd90vupAykkHvRjeM5yjA383doQ=";
    };
    patches = [];
    version = "2026.1.1";
  };
}
