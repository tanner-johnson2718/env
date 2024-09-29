{ pkgs, home, config, ... }:
{
    programs.vscode = {
        enable = true;
        enableUpdateCheck = false;
        package = pkgs.vscodium;
        extensions = with pkgs; [
            vscode-extensions.streetsidesoftware.code-spell-checker
            vscode-extensions.bbenoist.nix
            vscode-extensions.jnoortheen.nix-ide
        ];
    };
}