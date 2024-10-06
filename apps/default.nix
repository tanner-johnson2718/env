{config, lib, ...}:
let
  cfg = config.apps;
in
{
  imports = [
    ./firefox.nix
    ./steam.nix
    ./proton.nix
  ];

  options = {
    apps.enable = lib.mkEnableOption "Enable user module";
    apps.firefox.enable = lib.mkEnableOption "Enable Firefox";
    apps.firefox.bookmarks = lib.mkOption {
      type = lib.types.path;
      default = ./bookmarks.nix;
    };
    apps.steam.enable = lib.mkEnableOption "Enable Steam";
    apps.proton.enable = lib.mkEnableOption "Enable Proton";
  };
}