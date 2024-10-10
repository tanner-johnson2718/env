{
  description = "no";
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = {self, nixpkgs, home-manager, ...}: {
    nixosModules = {
      common = (import ./common);
      term = (import ./term);
      firefox = (import ./firefox);
      steam = (import ./steam);
      asus_gu603 = (import ./hw/asus_gu603.nix);
    };

    nixosConfigurations = { 
      gamebox0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager

          self.nixosModules.common
          self.nixosModules.term
          self.nixosModules.firefox
          self.nixosModules.steam
          self.nixosModules.asus_gu603

          ({config, ...}:{
            config = {
              asus_gu603.hostName = "gamebox0";
              term.enable = true;
              term.userName = "gamebox0";
              term.term.enable = true;
              term.vscode.enable = true;
              firefox.enable = true;
              steam.enable = true;   # has prusa slicer too

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
