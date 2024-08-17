{
  description = '' 
   IDFK
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";  
  
  outputs = {self, nixpkgs, ...}@inputs:
  let
    system = "x86_64-linux";
    qmk_firmware_url = "https://github.com/qmk/qmk_firmware.git";
    qmk_firmware_rev = "fe50774cb488f981dfd41c7a5bc5f34dfcd9cb9d";
    keymap_path = "keyboards/gmmk/gmmk2/p65/ansi/keymaps/default";
  in 
  {
    devShells.${system}.default = 
      let
        pkgs = import nixpkgs { inherit system; };
      in 
      pkgs.mkShell {
        shellHook = ''
          git clone ${qmk_firmware_url}
          cd qmk_firmware
          git checkout ${qmk_firmware_rev}
          cp ../keymap.c ${keymap_path}
          git diff > ../patch.txt
          cd ..
          rm -rf qmk_firmware
        '';
      };

  };

}

 # kbConf = ''
  # [0] = LAYOUT_65_ansi_blocker(
  # QK_GESC,  KC_1,     KC_2,     KC_3,     KC_4,     KC_5,     KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,  KC_EQL,   KC_BSPC,  KC_DEL,
  # KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,     KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,  KC_RBRC,  KC_BSLS,  RGB_MODE_FORWARD,
  # KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,     KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,  KC_ENT,             KC_HOME,
  # KC_LSFT,  KC_Z,     KC_X,     KC_C,     KC_V,     KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,  KC_GRV,            KC_UP,    KC_END,
  # KC_LCTL,  KC_LGUI,  KC_LALT,                                KC_SPC,                                 KC_PGUP,  KC_PGDN,    KC_LEFT,  KC_DOWN,  KC_RGHT
  # ),
  # '';