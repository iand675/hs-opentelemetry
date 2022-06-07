let
  pkgs = import ./nix/pkgs.nix {};
  settings = import ./nix/ghc.nix {};
in
  with pkgs;
  with settings;
  mkShell {
    buildInputs = [
      niv

      ghc
      stack

      haskell.packages.${compiler}.implicit-hie
      haskell.packages.${compiler}.haskell-language-server
      haskell.packages.${compiler}.hspec-discover
    ];
  }
