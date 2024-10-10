{lib, config, pkgs, ...} :
let
  cfg = config.steam;
in
{
  options = {
    steam.enable = lib.mkEnableOption "Enable";
  };

  config = {
    programs.steam = lib.mkIf cfg.enable {
      enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    environment.systemPackages = lib.mkIf cfg.enable 
      (with pkgs; [
        discord
        prusa-slicer
      ]);
  };
}