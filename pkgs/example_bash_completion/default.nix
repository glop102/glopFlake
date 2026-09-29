{
stdenv,
bash
}:

stdenv.mkDerivation {
  name = "example";
  # Since we are just making some files directly in the output of the derivation,
  # we do not actually have any sources to unpack right now
  dontUnpack = true;
  installPhase = ''
    CMPDIR="$out/share/bash-completion/completions"

    mkdir -p $out/bin
    echo "echo Example Program!" > $out/bin/example
    chmod +x $out/bin/example

    # This is apparently where bash will check for completions?
    mkdir -p "$CMPDIR"
    cat << 'EOF' > "$CMPDIR/example.bash"
    function _example {
      local CMD=$1
      local CURWORD=$2

      COMPREPLY=( $(compgen -W "--help status other" -- "$CURWORD" ) );
    }
    complete -o default -F _example example
    EOF
  '';
}
