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
          networking.firewall.enable = false;
          users.extraUsers.root.password = "root";
          users.mutableUsers = false;

          # networking.interfaces.eth0.useDHCP = true;
          # networking.interfaces.br0.useDHCP = true;
          # networking.bridges = {
          #   "br0" = {
          #     interfaces = [ "eth0" ];
          #   };
          # };

          virtualisation = {
            memorySize = 2048; # MiB
            cores = 4;
            graphics = false;
            qemu.networkingOptions = ["-net nic -net user"]; 
            sharedDirectories = {
              vargit = {
                source = "/var/git";
                target = "/var/git";
                securityModel = "none"; 
              };
              
            };
          };

          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
            permitRootLogin = "yes";
            knownHosts = {
              root = {
                publicKey = (builtins.substring 0 80 (builtins.readFile "/home/user/.ssh/id_ed25519.pub"));
                hostNames = ["10.0.2.2"];
              };
            };
          };
        };
      })];
    };

    nixosModules.term = (import ./term.nix);
  };
}
