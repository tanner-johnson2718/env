# https://github.com/yokoffing/Betterfox/blob/main/user.js
# https://github.com/oddlama/nix-config/blob/main/users/myuser/graphical/firefox.nix
{ pkgs, home, config, lib, ... }:
let
  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "129.0";
    hash = "sha256-hpkEO5BhMVtINQG8HN4xqfas/R6q5pYPZiFK8bilIDs=";
  };
in
{
    programs.firefox = {
        enable = true;
        profiles ={
          default = {
            extraConfig =  builtins.concatStringsSep "\n" [ 
              (builtins.readFile "${betterfox}/user.js")
            ];
          };
        };
    };
}