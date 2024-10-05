{config, lib, ...}:
let
  cfg = config.user;
in
{
  imports = [
    ./firefox.nix
    ./steam.nix
  ];

  options = {
    user.enable = lib.mkEnableOption "Enable user module";
    user.firefox.enable = lib.mkEnableOption "Enable Firefox";
    user.steam.enable = lib.mkEnableOption "Enable Steam";
  };
}