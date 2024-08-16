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

    ###########################################################################
    # Nix Systems Define
    ###########################################################################
    nixosConfigurations.default = nixpkgs.lib.nixosSystem 
    {
      system = "x86_64-linux";
      inherit (self.packages.x86_64-linux) pkgs;
      modules = [
        ./common.nix
        ./sys/dev.nix
        ./hw/hp_laptop.nix
      ];
    };

    ###########################################################################
    # Nix Overwrite Nix Packages
    ###########################################################################
    # packages = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all (system:
    #   let
    #     pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    #     theme = import ./theme.nix;
    #   in
    #   {
    #     pkgs = pkgs // removeAttrs self.packages.${system} [ "pkgs" ];
    #     alacritty = pkgs.callPackage ./pkgs/alacritty.nix { inherit theme; };
    #   }
    # );

  };
}