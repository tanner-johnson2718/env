{config, lib, pkgs, ...}:
let
  cfg = config.home;
in
{
  options = {
    home.enable = lib.mkEnableOption "Enable My Home Manager Modules";
    home.userName = lib.mkOption { type = lib.types.str; };
    home.term.enable = lib.mkEnableOption "Enable My Terminal";
    home.kitty.enable = lib.mkEnableOption "Enable My Kitty Settings";
    home.vscode.enable = lib.mkEnableOption "Enable My VSCode Settings";
    home.firefox.enable = lib.mkEnableOption "Enable My FireFox Settings";
  };

  config = lib.mkIf cfg.enable {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users."${cfg.userName}" = (import ./home.nix){ 
      userName = "${cfg.userName}";
      modules = []
        ++ (if cfg.term.enable then [./term.nix] else [])
        ++ (if cfg.kitty.enable then [./kitty.nix] else [])
        ++ (if cfg.vscode.enable then [./vscode.nix] else [])
        ++ (if cfg.firefox.enable then [./firefox.nix] else []);
    };

    environment.systemPackages = with pkgs; []
      ++ (if cfg.kitty.enable then [kitty] else [])
      ++ (if cfg.firefox.enable then [firefox] else []);
  };
}  