{
  description = ''
    Flake to export my user terminal configuration
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
  let
    inherit (nixpkgs.lib) nixosSystem;
    common = {...}:{
      system.stateVersion = "24.05";
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;
    };
  in {

  ###########################################################################
  # Config for init node
  ###########################################################################

    nixosConfigurations.init = 
    let
      system = "x86_64-linux";
      userName = "init";
    in 
    nixosSystem  {
      inherit system;
      modules = [ ( {config, lib, pkgs,  ...}:{
        imports = [
          common
          ./user;
        ];

        config.user.config.enable = true;
        config.user.config.userName = userName;
        config.user.config.reposPath = "/var/git";
        config.user.config.envRepo = "env";

        config.term.config.enable = true;
        config.term.config.leader = "Space";
        config.term.config.extraTerminalPkgs = with pkgs; [  ];

        config = {
          nixpkgs.hostPlatform = "${system}";
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        };
      })];
    };

   ###########################################################################
    # Nix Modules to export sys config other systems
   ###########################################################################

    nixosModules.user = (import ./user);
  };
}
