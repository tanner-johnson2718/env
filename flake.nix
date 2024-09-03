{
  description = ''
    Configuration for my main system. Export parts of my main system in the 
    form of configurable modules and dev shells.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager?rev=e1391fb22e18a36f57e6999c7a9f966dc80ac073";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix, home-manager, ... }:
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
  # Config for my main personal laptop
  ###########################################################################

    nixosConfigurations.default = 
    let
      system = "x86_64-linux";
      userName = "lcars";
    in 
    nixosSystem  {
      inherit system;
      modules = [ ( {config, lib, modulesPath, pkgs,  ...}:{
        imports = [
          common
          ./hw/hp_envy_15t.nix
          ./user
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${userName} = {config, pkgs, ...}:{
              imports = [ ./home ];
              home.username = userName;
              home.homeDirectory = "/home/${userName}";

              home.stateVersion = "24.05";
              programs.home-manager.enable = true;
            };
          }
        ];

        config.user.config.enable = true;
        config.user.config.userName = userName;
        config.user.config.reposPath = "/var/git";
        config.user.config.envRepo = "env";
        config.user.config.enableEcryptfs = true;

        config.term.config.enable = true;
        config.term.config.extraTerminalPkgs = with pkgs; [ pev bintools aircrack-ng tcpdump ];

        config.gnome.config.enable = true;
        config.gnome.config.extraDEPkgs = with pkgs; [ vscode nil prusa-slicer rpi-imager wireshark ];

        config = {
          nixpkgs.hostPlatform = "${system}";
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        };
      })];
    };

  ###########################################################################
  # Cam Pi w/ possible prusa contrl service, open close garage?
  # Rpi 4b 2gb
  ########################################################################### 

    nixosConfigurations.garagePi = 
    let
      system = "aarch64-linux";
    in
    nixosSystem {
      inherit system;
      modules = [ ( {config, lib, modulesPath,  ...}:{
        imports = [ 
          common
          ./user
        ];

        config.user.config.enable = true;
        config.user.config.userName = "garagePi";
        config.user.config.reposPath = "/var/git";
        config.user.config.envRepo = "env";

        config.term.config.enable = true;

        nixpkgs.hostPlatform = "${system}";
        raspberry-pi-nix.board = "bcm2711";
      })];
    };

   ###########################################################################
    # Nix Modules to export sys config other systems
   ###########################################################################

    nixosModules.user = (import ./user);
    nixosModules.argp = (import ./argp.nix);

   ###########################################################################
    # Nix Shells to export developer environments to other system.
   ###########################################################################
    # devShells.${system} = { qmk = (import ./qmk/qmk.nix){ inherit pkgs; keymap="./qmk/keymap.c"; }; };
  };
}
