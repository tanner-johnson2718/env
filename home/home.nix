{userName, modules}:
{ config, pkgs, lib, ... }:
{
  imports = modules;

  config = {
    home.username = userName;
    home.homeDirectory = "/home/${userName}";
    home.stateVersion = "24.11";
  };
}
