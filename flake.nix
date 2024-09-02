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
      modules = [ ( {config, lib, modulesPath,  ...}@args:{
        imports = [
          ./user.nix 
          ./hp_envy_15t.nix
          (import ./common.nix ( args // {inherit system;} ) )
        ];

        config.user.config.enable = true;
        config.user.config.userName = "lcars";
        config.user.config.enableDE = true;
        config.user.config.enableEcryptfs = true;
        config.user.config.ecryptfsBakPath = "/var/ecryptfsBak";
        config.term.config.enable = true;

        config = {
          
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          
          networking = {
            wireless.networks.Nan.psk = "password";
            networkmanager.enable = true;
            hostName = config.user.config.userName;
            useDHCP = lib.mkDefault true;
          };

          fonts.packages = with (import nixpkgs { inherit system; } ); [cascadia-code];
          fonts.fontconfig.enable = true;
          fonts.fontconfig.defaultFonts.monospace = ["Cascadia Mono"];
          fonts.fontconfig.defaultFonts.serif = ["Cascadia Mono"];
          fonts.fontconfig.defaultFonts.sansSerif = ["Cascadia Mono"];
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
      modules = [ ( {config, lib, modulesPath,  ...}@args:{
        imports = [
          raspberry-pi-nix.nixosModules.raspberry-pi 
          ./user.nix  
          (import ./common ( args // {inherit system;} ) )
        ];

        config.user.config.enable = true;
        config.user.config.userName = "garagePi";
        config.term.config.enable = true;

        config = {
          raspberry-pi-nix.board = "bcm2711";
          users.users.${config.user.config.userName}.initialPassword = "${config.user.config.userName}";
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

    nixosModules.user = (import ./user.nix);
    nixosModules.term = (import ./term.nix);
    nixosModules.argp = (import ./argp.nix);

   ###########################################################################
    # Nix Shells to export developer environments to other system.
   ###########################################################################
    # devShells.${system} = { qmk = (import ./qmk/qmk.nix){ inherit pkgs; keymap="./qmk/keymap.c"; }; };
  };
}
