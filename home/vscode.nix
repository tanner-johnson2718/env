{ pkgs, home, config, ... }:
{
    programs.vscode = {
        enable = true;
        enableUpdateCheck = false;
        package = pkgs.vscodium;
    };
}