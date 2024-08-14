{
  description = "System configuration flake";

  inputs = 
  {
    nixpkgs = 
    {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };

    home-manager = 
    {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  {
    nixosConfigurations.lcars = nixpkgs.lib.nixosSystem 
    {
      system = "x86_64-linux";
      modules = [ 
        ./configuration.nix
        ./hardware-configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}