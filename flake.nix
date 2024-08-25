{
  description = "";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs, ... }@inputs: 
  {

    ###########################################################################
    # Nix Systems Define
    ###########################################################################
    nixosConfigurations.default = nixpkgs.lib.nixosSystem 
    {
      system = "x86_64-linux";
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



  };
}