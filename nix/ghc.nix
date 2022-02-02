{ pkgs ? import ./pkgs.nix {} }:
rec {
  ghc = pkgs.haskell.compiler.${compiler};
  compiler = "ghc${ghcVersion}";
  ghcVersion = "8107";
}
