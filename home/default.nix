{...}@inputs:
{ config, pkgs, ... }:
{
  imports = [ ./term.nix ];
  
  config = {
    home.username = inputs.userName;
    home.homeDirectory = "/home/${inputs.userName}";
    home.stateVersion = "24.11";
  };
}
