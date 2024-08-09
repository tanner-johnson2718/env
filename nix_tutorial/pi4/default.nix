let
  pkgs = import <nixpkgs> { };
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  packages = rec {
    pigpio = pkgs.callPackage ./pigpio.nix {};
  };
in
packages