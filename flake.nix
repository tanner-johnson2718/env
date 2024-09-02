{
  description = ''
    Configuration for my main system. Export parts of my main system in the 
    form of configurable modules and dev shells.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix, ... }:
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
    in 
    nixosSystem  {
      inherit system;
      modules = [ ( {config, lib, modulesPath, pkgs,  ...}:{
        imports = [
          common
          ./home
          ./hp_envy_15t.nix
        ];

        config.user.config.enable = true;
        config.user.config.userName = "lcars";
        config.user.config.reposPath = "/var/git";
        config.user.config.envRepo = "env";
        config.user.config.enableEcryptfs = true;
        config.user.config.ecryptfsBakPath = "/var/ecryptfsBak";
        

        config.term.config.enable = true;
        config.term.config.extraTerminalPkgs = with pkgs;
        [
          pev
          bintools
          aircrack-ng 
          tcpdump 
        ];

        config.gnome.config.enable = true;
        config.gnome.config.extraDEPkgs =
        with pkgs;
        [
          vscode
          nil
          prusa-slicer
          rpi-imager
          wireshark
        ];

        config = {
          nixpkgs.hostPlatform = "${system}";
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          
          networking = {
            wireless.networks.Nan.psk = "password";
            networkmanager.enable = true;
            hostName = config.user.config.userName;
            useDHCP = lib.mkDefault true;
          };  
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
          ./home
        ];

        config.user.config.enable = true;
        config.user.config.userName = "garagePi";
        config.user.config.reposPath = "/var/git";
        config.user.config.envRepo = "env";

        config.term.config.enable = true;

        config = {
          nixpkgs.hostPlatform = "${system}";
          raspberry-pi-nix.board = "bcm2711";
          networking = {
            hostName = config.user.config.userName;
            wireless.networks.Nan.psk = "password";
            useDHCP = true;
            interfaces = {
              wlan0.useDHCP = true;
              eth0.useDHCP = true;
            };
          };
        };
      })];
    };

   ###########################################################################
    # Nix Modules to export sys config other systems
   ###########################################################################

    nixosModules.home = (import ./home);
    nixosModules.argp = (import ./argp.nix);

   ###########################################################################
    # Nix Shells to export developer environments to other system.
   ###########################################################################
    # devShells.${system} = { qmk = (import ./qmk/qmk.nix){ inherit pkgs; keymap="./qmk/keymap.c"; }; };
  };
}
