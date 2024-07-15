{
  lib,
  pkgs,
}: let
  allOpenTelemetryPackages = import ./haskell-packages.nix {inherit pkgs lib;};
in
  allOpenTelemetryPackages.localPackageCabalDerivations
