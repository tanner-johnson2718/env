{ pkgs, home, config, ... }:
{
    programs.kitty = {
        enable = true;
        themeFile = "Darkside";
    };
}