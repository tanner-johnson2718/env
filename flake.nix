{
  description = ''
    Flake to export my user terminal configuration
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    inherit (nixpkgs.lib) nixosSystem;
    pkgs = nixpkgs.legacyPackages.${system};
    common = {...}:{
      system.stateVersion = "24.05";
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;
    };
  in {

    nixosConfigurations.root = nixosSystem  {
      modules = [ ( {config, lib, pkgs, modulesPath,  ...}:{
        imports = [
          common
          ./term.nix
          "${modulesPath}/virtualisation/qemu-vm.nix"
        ];

        config.term.config.enable = true;
        config.term.config.leader = "Space";
        config.term.config.extraTerminalPkgs = with pkgs; [  ];

        config = {
          nixpkgs.hostPlatform = "${system}";
          networking.firewall.allowedTCPPorts = [ 22 ];
          users.extraUsers.root.password = "root";
          users.mutableUsers = false;

          virtualisation = {
            memorySize = 2048; # Use 2048MiB memory.
            cores = 4;
            graphics = false;
          };

          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
            permitRootLogin = "yes";
          };
        };
      })];
    };

    nixosModules.term = (import ./term.nix);
  };
}
