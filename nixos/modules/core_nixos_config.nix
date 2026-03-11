{
  config = {
    # Allow unfree packages like steam
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    boot.kernelParams = [ "boot.shell_on_fail" ];
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 6;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
