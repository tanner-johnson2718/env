{
  description = "";
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
            imports = [./user.nix];
            config.user.config.enable = true;
            config.user.config.userName = "lcars";
            config.user.config.reposPath = "/var/git";
            config.user.config.enableDE = true;
            config.user.config.enableEcryptfs = true;
            config.user.config.ecryptfsBakPath = "/var/ecryptfsBak";
            config.user.config.enableCleanJobs = true;
          }
        )
      ];
    };

    ###########################################################################
    # Nix Modules to export sys config other systems
    ###########################################################################

    nixosModules.user = (import ./user.nix);

    ###########################################################################
    # Nix Shells to export developer environments to other system
    ###########################################################################

    devShells.${system}.aircrack = (import ./dev/aircrack/aircrack.nix)
    { 
      pkgs = (import nixpkgs { inherit system; } );
    };


  };
}