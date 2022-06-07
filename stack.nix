let
  pkgs = import ./nix/pkgs.nix {};
  ghc = import ./nix/ghc.nix {};
in
  with pkgs;
  haskell.lib.buildStackProject {
    buildInputs = [postgresql zlib];
    ghc = ghc.ghc;
    name = "hs-opentelemetry";
  }
