{ config, pkgs, ... }:
{
  imports = [ ./term.nix ];
  
  config = {
    home.username = "user";
    home.homeDirectory = "/home/user";
    home.stateVersion = "24.05";
  };
}
