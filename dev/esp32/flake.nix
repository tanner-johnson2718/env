{
  description = ''
    ESP32 dev env shell
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  
  outputs = {self, nixpkgs, ...}@inputs:
  let
    system = "x86_64-linux";
    espidf_url = "https://github.com/espressif/esp-idf.git";
    espidf_branch = "release/v5.3";
    espidf_rev = "466a392a7683f42feed28753b8f725c2aa82d804";
  in
  {
    devShells.${system}.default = 
      let
        pkgs = import nixpkgs { inherit system; };
      in 
      pkgs.mkShell {


        packages = with pkgs; [ 
          (pkgs.callPackage ./esp32-toolchain.nix {})
          git
          wget
          gnumake
          flex
          bison
          gperf
          pkg-config
          cmake
          ncurses5
          ninja
          (python3.withPackages (p: with p; [ pip virtualenv ]))
        ];


        shellHook = ''
          git clone ${espidf_url} -b ${espidf_branch}
          cd esp-idf
          git checkout ${espidf_rev}
          export IDF_PATH=$(pwd)/esp-idf
          export PATH=$IDF_PATH/tools:$PATH
          export IDF_PYTHON_ENV_PATH=$(pwd)/.python_env

          if [ ! -e $IDF_PYTHON_ENV_PATH ]; then
            python -m venv $IDF_PYTHON_ENV_PATH
            . $IDF_PYTHON_ENV_PATH/bin/activate
            pip install -r $IDF_PATH/requirements.txt
          else
            . $IDF_PYTHON_ENV_PATH/bin/activate
          fi
        '';
      };
  }; 
    
}