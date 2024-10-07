{config, lib, pkgs, ...}:
let
  cfg = config.home;
in
{
  options = {
    home.enable = lib.mkEnableOption "Enable My Home Manager Modules";
    home.userName = lib.mkOption { type = lib.types.str; };
    home.term.enable = lib.mkEnableOption "Enable My Terminal";
    home.vscode.enable = lib.mkEnableOption "Enable My VSCode Settings";
    home.threeD.enable = lib.mkEnableOption "Enable 3d printing stuff";
  };

  config = lib.mkIf cfg.enable {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = ".bak";
    home-manager.users."${cfg.userName}" = (import ./home.nix){ 
    userName = "${cfg.userName}";
    modules = []
        ++ (if cfg.term.enable then [./term.nix] else [])
        ++ (if cfg.vscode.enable then [./vscode.nix] else []);
    };

    environment.systemPackages = with pkgs; []
      ++ (if cfg.threeD.enable then [prusa-slicer] else []);
  };
}