{
  lib,
  pkgs,
}: let
  allOpenTelemetryPackages = import ./haskell-packages.nix {inherit pkgs lib;};
in
  hfinal: _hsuper: allOpenTelemetryPackages.localPackageCabalDerivations hfinal
