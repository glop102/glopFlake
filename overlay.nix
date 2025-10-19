final: prev: {
  # One Day pkgs will be imported here
  hello-static = final.hello.override {
    stdenv = final.pkgsStatic.stdenv;
  };
}
