{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    package = pkgs.vscodium;
    extensions = with pkgs; [
      vscode-extensions.streetsidesoftware.code-spell-checker
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.eamodio.gitlens
      vscode-extensions.tomoki1207.pdf
    ];
    userSettings = {
        "nix.enableLanguageServer" = true;
        "workbench.activityBar.location" = "top";
        "window.menuBarVisibility" = "hidden";
        "editor.detectIndentation" = false;
        "workbench.editor.showTabs" = "single";
    };
    keybindings = [
      ({
        "key" = "ctrl+shift+g t";
        "command" = "gitlens.diffWithRevisionFrom";
        "when" = "editorTextFocus && config.gitlens.keymap == 'chorded' && gitlens:activeFileStatus =~ /tracked/";
      })
    ];
  };
} 