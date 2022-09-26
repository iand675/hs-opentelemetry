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
      cabal-install
      stack
      hpack

      haskell.packages.${compiler}.implicit-hie
      haskell.packages.${compiler}.haskell-language-server
      haskell.packages.${compiler}.hspec-discover
      haskell.packages.${compiler}.fourmolu

      postgresql
      zlib
    ];
  }
