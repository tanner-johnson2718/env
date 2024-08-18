{
  description = ''
    ESP32 dev env shell. We override mirrexagon's esp idf flake
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  
  outputs = {self, nixpkgs, ...}@inputs:
  let
    system = "x86_64-linux";

    nixpkgs-esp-dev = builtins.fetchGit {
      url = "https://github.com/mirrexagon/nixpkgs-esp-dev.git";
      rev = "86a2bbe01fe0258887de7396af2a5eb0e37ac3be";
    };

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ (import "${nixpkgs-esp-dev}/overlay.nix") ]; 
    };
  in
  {
    devShells.${system}.default =  pkgs.mkShell {
      buildInputs = with pkgs; [ esp-idf-full ];

      shellHook = ''
        echo Welcome
      '';
    };
  };
    
}