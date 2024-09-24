{
  outputs = {...}:
  {
    nixosModules.term = import ./term.nix;
  };
}