{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    htop
    vim
    coreutils
    git
    curl
    wget
  ];
}
