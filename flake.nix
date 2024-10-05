{
  description = "no";
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = {self, nixpkgs, home-manager, ...}: {
    nixosModules = {
      common = (import ./common.nix);
      home = (import ./home);
      user = (import ./user);
      asus_gu603 = (import ./hw/asus_gu603.nix);
    };

    nixosConfigurations = { 
      gamebox0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager

          self.nixosModules.common
          self.nixosModules.home
          self.nixosModules.user
          self.nixosModules.asus_gu603

          ({config, ...}:{
            config = {
              asus_gu603.hostName = "gamebox0";
              home.enable = true;
              home.userName = "gamebox0";
              home.term.enable = true;
              home.kitty.enable = true;
              home.vscode.enable = true;
              home.threeD.enable = true;

              user.enable = true;
              user.firefox.enable = true;
              user.steam.enable = true;

              users.users.gamebox0 = {
                isNormalUser = true;
                description = "Mono User";
                extraGroups = [ "networkmanager" "wheel" "dialout" ];
              };

            };
          })
        ]; 
      };
    };
  };
}
