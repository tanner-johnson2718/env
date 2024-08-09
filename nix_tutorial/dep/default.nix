let
  pkgs = import <nixpkgs> { };
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  packages = rec {
    a = pkgs.callPackage ./a.nix {};
    b = pkgs.callPackage ./b.nix { inherit a; };
  };
in
packages