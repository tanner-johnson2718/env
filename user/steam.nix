{lib, config, pkgs, ...} :
let
  cfg = config.user;
in
{
  programs.steam = lib.mkIf cfg.steam.enable {
    enable = true;
    extraCompatPackages = with pkgs; [proton-ge-bin];
  };

  environment.systemPackages = lib.mkIf cfg.steam.enable 
    (with pkgs; [
      discord
    ]);
}