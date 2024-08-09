# Build with 'nix-build'

let
  pkgs = import <nixpkgs> { };
in
pkgs.callPackage ./build.nix { }