{
  description = "no";
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = {self, nixpkgs, home-manager, ...}: {
    nixosModules = {
      asus_gu603 = (import ./hw/asus_gu603.nix);
    };

    nixosConfigurations = { 
      gamebox0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          (self.nixosModules.asus_gu603 {hostName = "gamebox0";})
          home-manager.nixosModules.home-manager
          {
            users.users.gamebox0 = {
              isNormalUser = true;
              description = "gamebox0";
              extraGroups = [ "networkmanager" "wheel" ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.gamebox0 = (import ./home){ userName = "gamebox0";};
          }  
        ]; 
      };
    };
  };
}
