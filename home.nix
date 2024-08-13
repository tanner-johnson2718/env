{config, pkgs, ...}:

{
    home.username = "lcars";
    home.homeDirectory = "/home/lcars";

    home.stateVersion = "24.05";

    programs.home-manager.enable = true;
}