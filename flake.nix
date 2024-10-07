{
  description = "no";
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = {self, nixpkgs, home-manager, ...}: {
    nixosModules = {
      script-builder = (import ./script-builder);
      common = (import ./common);
      home = (import ./home);
      apps = (import ./apps);
      asus_gu603 = (import ./hw/asus_gu603.nix);
    };

    nixosConfigurations = { 
      gamebox0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager

          self.nixosModules.common
          self.nixosModules.home
          self.nixosModules.apps
          self.nixosModules.asus_gu603

          ({config, ...}:{
            config = {
              asus_gu603.hostName = "gamebox0";
              home.enable = true;
              home.userName = "gamebox0";
              home.term.enable = true;
              home.vscode.enable = true;
              home.threeD.enable = true;

              apps.enable = true;
              apps.firefox.enable = true;
              apps.steam.enable = true;
              apps.proton.enable = true;

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
