{
  description = ''
    Configuration for my main system. Export parts of my main system in the 
    form of configurable modules and dev shells.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = (import nixpkgs { inherit system; } );
  in {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem  {
      inherit system;
      modules = [ ( {config, lib, modulesPath,  ...}:{
        imports = [
          ./user.nix
          ./term.nix
          ./hw/hp_envy_15t.nix
        ];

        config.user.config.enable = true;
        config.user.config.envRepo = "env";
        config.user.config.userName = "lcars";
        config.user.config.reposPath = "/var/git";
        config.user.config.enableDE = true;
        config.user.config.enableEcryptfs = true;
        config.user.config.ecryptfsBakPath = "/var/ecryptfsBak";

        config.term.config.enable = true;
        config.term.config.tmuxExtraConf = "";
        config.term.config.bashExtra = "";
        # config.term.config.extraTerminalPkgs = [];

        config = {
          # Main system first installed version was 24.05
          system.stateVersion = "24.05";
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnsupportedSystem = true;

          networking.networkmanager.enable = true;
          networking.hostName = config.user.config.userName;
          networking.useDHCP = lib.mkDefault true;

          fonts.packages = with (import nixpkgs { inherit system; } ); [cascadia-code];
          fonts.fontconfig.enable = true;
          fonts.fontconfig.defaultFonts.monospace = ["Cascadia Mono"];
          fonts.fontconfig.defaultFonts.serif = ["Cascadia Mono"];
          fonts.fontconfig.defaultFonts.sansSerif = ["Cascadia Mono"];
        };
      })];
    };

   ###########################################################################
    # Nix Modules to export sys config other systems
   ###########################################################################

    nixosModules.user = (import ./user.nix);
    nixosModules.term = (import ./term.nix);

   ###########################################################################
    # Nix Shells to export developer environments to other system.
   ###########################################################################
    devShells.${system} = { qmk = (import ./de/qmk/qmk.nix){ inherit pkgs; }; };
  };
}
