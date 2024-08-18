{
  description = ''
      Dev Shell with aircrack-ng tools for wifi snooping
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  outputs = {self, nixpkgs, ...}@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {

    devShells.${system}.default =  pkgs.mkShell {
      packages = with pkgs; [ aircrack-ng tcpdump wireshark ];
      shellHook = ''
        alias ng_start="sudo airmon-ng start wlp5s0"
        alias ng_stop="sudo airmon-ng stop wlp5s0mon"
      '';
    };
  };
}