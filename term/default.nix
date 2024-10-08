{config, lib, pkgs, ...}:
let
  cfg = config.term;
in
{
  options = {
    term.enable = lib.mkEnableOption "Enable My Home Manager Modules";
    term.userName = lib.mkOption { type = lib.types.str; };
    term.term.enable = lib.mkEnableOption "Enable My Terminal";
    term.vscode.enable = lib.mkEnableOption "Enable My VSCode Settings";
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
  };
}