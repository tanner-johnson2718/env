{pkgs, keymap}:
let
  qmk_firmware_url = "https://github.com/qmk/qmk_firmware.git";
  qmk_firmware_rev = "fe50774cb488f981dfd41c7a5bc5f34dfcd9cb9d";
  keymap_path = "keyboards/gmmk/gmmk2/p65/ansi/keymaps/via";
in 
pkgs.mkShell {
  packages = with pkgs; [ git qmk ];
  shellHook = ''
    if ! [ -d qmk_firmware ]; then
      echo "Cloning QMK Firmware Source..."
      git clone ${qmk_firmware_url}
    fi
    cd qmk_firmware
    git checkout ${qmk_firmware_rev}
    qmk setup
    if ! [ -f ${keymap} ]; then
      echo "File keymap=${keymap} not found"
      exit 1
    fi
    cp ${keymap} ${keymap_path}
    qmk compile --keyboard gmmk/gmmk2/p65/ansi --keymap via
    sudo qmk flash --keyboard gmmk/gmmk2/p65/ansi --keymap via
    exit 0
  '';
}