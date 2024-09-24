{
  outputs = {self, nixpkgs, ...}:
  {
    nixosModules.term = import ./term.nix;
  };
}