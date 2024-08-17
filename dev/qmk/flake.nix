{
  description = '' 
    Flake to create a dev env for building and flashing qmk firmware.
    Will apply a key map patch to a specified kb and give alais's to build and flash.
  '';

  inputs.nixpkgs.url        = "github:nixos/nixpkgs/nixos-24.05";  
  inputs.qmk_firmware.url   = "github:qmk/qmk_firmware";
  inputs.qmk_firmware.flake = false;
    
  outputs = {self, nixpkgs, ...}@inputs:
  let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = 
    let
      pkgs = import nixpkgs {
          inherit system;
        };
    in pkgs.mkShell {
      packages = with pkgs; [
        qmk
      ];

      shellHook = ''
        echo brah
      '';
    };
  };

}