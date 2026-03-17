{
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [
      zfs # For zpool and zfs
      simplifiedVideoLibraryRenamer
    ];
  };
}
