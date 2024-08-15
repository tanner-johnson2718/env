{
  description = "System configuration flake";

  inputs = 
  {
    nixpkgs = 
    {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem 
    {
      system = "x86_64-linux";
      modules = [ 
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}