{
  description = '' 
   Shell to flash qmk firmware with my keymap
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";  
  
  outputs = {self, nixpkgs, ...}@inputs:
  let
    system = "x86_64-linux";
    qmk_firmware_url = "https://github.com/qmk/qmk_firmware.git";
    qmk_firmware_rev = "fe50774cb488f981dfd41c7a5bc5f34dfcd9cb9d";
    keymap_path = "keyboards/gmmk/gmmk2/p65/ansi/keymaps/via";
  in 
  {
    devShells.${system}.default = 
      let
        pkgs = import nixpkgs { inherit system; };
      in 
      pkgs.mkShell {
        packages = with pkgs; [ git qmk ];
        shellHook = ''
          git clone ${qmk_firmware_url}
          cd qmk_firmware
          git checkout ${qmk_firmware_rev}
          qmk setup
          cp ../keymap.c ${keymap_path}
          qmk compile --keyboard gmmk/gmmk2/p65/ansi --keymap via
          sudo qmk flash --keyboard gmmk/gmmk2/p65/ansi --keymap via
        '';
      };

  };

}