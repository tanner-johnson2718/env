{
  description = ''
    Configuration for my main system. Export parts of my main system in the 
    form of configurable modules.
  '';
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {

    ###########################################################################
    # Nix Systems Define
    ###########################################################################
    nixosConfigurations.default = nixpkgs.lib.nixosSystem 
    {
      inherit system;
      modules = [
        ./hp_laptop.nix
        (
          {config, ...}:{
            # Main system first installed version was 24.05
            system.stateVersion = "24.05";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }
        )
        (
          {config, ...}:{
            imports = [./user.nix];
            config.user.config.enable = true;
            config.user.config.userName = "lcars";
            config.user.config.reposPath = "/var/git";
            config.user.config.enableDE = true;
            config.user.config.enableEcryptfs = true;
            config.user.config.ecryptfsBakPath = "/var/ecryptfsBak";
          }
        )
      ];
    };

    ###########################################################################
    # Nix Modules to export sys config other systems
    ###########################################################################

    nixosModules.user = (import ./user.nix);

    ###########################################################################
    # Nix Shells to export developer environments to other system. for stuff
    # I dont know what to do with.
    ###########################################################################

    devShells.${system} =
    let
      pkgs = (import nixpkgs { inherit system; } );
    in
    {
      aircrack = (import ./aircrack/aircrack.nix){ inherit pkgs; };
      qmk = (import ./qmk/qmk.nix){ inherit pkgs; };
    };
  };
}