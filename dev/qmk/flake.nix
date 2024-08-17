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
    keyBoard = "gmmk/gmmk2/p65/ansi";
  in {
    devShells."${system}".default = 
    let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      packages = with pkgs; [
        qmk
      ];

      shellHook = ''
        echo qmk_firmware outPath = ${inputs.qmk_firmware.outPath}
        echo keyboard             = ${keyBoard}
        echo patching             = ${inputs.qmk_firmware.outPath}/keyboards/${keyBoard}/keymaps/default/keymap.c
      '';
    };
  };

}