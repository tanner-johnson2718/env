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
  # Config for root node
  ###########################################################################

    nixosConfigurations.root = 
    let
      system = "x86_64-linux";
    in 
    nixosSystem  {
      inherit system;
      modules = [ ( {config, lib, pkgs,  ...}:{
        imports = [
          common
          ./term.nix
        ];

        config.term.config.enable = true;
        config.term.config.leader = "Space";
        config.term.config.extraTerminalPkgs = with pkgs; [  ];

        config = {
          nixpkgs.hostPlatform = "${system}";
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        };

        virtualisation.vmVariant = {
          virtualisation = {
            memorySize = 2048; # Use 2048MiB memory.
            cores = 4;
            graphics = false;
          };
        };
          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
          };

          networking.firewall.allowedTCPPorts = [ 22 ];
      })];
    };

   ###########################################################################
    # Nix Modules to export sys config other systems
   ###########################################################################

    nixosModules.term = (import ./term.nix);
  };
}
