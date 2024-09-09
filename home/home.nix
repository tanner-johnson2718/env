{pkgs, not_yse, ...}:
let

in
{
  options = {

  };

  programs.git.enable = true;
  programs.git.userEmail = "tanner-johnson2718@gmail.com";
  programs.git.userName = "tanner-johnson2718";

  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    extensions = with pkgs; [
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.ms-vscode.cpptools-extension-pack
      vscode-extensions.eamodio.gitlens
      vscode-extensions.streetsidesoftware.code-spell-checker
    ];
    # globalSnippets = "";
    haskell.enable = false;
    mutableExtensionsDir = false;
    package = pkgs.vscode;
    # keybindings = [(
    #   {
    #     key="ctrl+e";
    #     command="editor.action.insertCursorAtEndOfEachLineSelected";
    #   }
    # )];
    # languageSnippets = "";
    # userSettings = "";
  };

  programs.kitty = {
    enable = true;
    font.name = "Cascadia Mono";
    font.size = 14;
    theme = "Darkside";
  };
}