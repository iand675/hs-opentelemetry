{
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    attrNames
    listToAttrs
    map
    ;
  inherit (import ./matrix.nix) supportedGHCVersions;
in rec {
  localPackages = {
    hs-opentelemetry-api = ../api;
    hs-opentelemetry-sdk = ../sdk;
    hs-opentelemetry-otlp = ../otlp;
    hs-opentelemetry-exporter-handle = ../exporters/handle;
    hs-opentelemetry-exporter-in-memory = ../exporters/in-memory;
    hs-opentelemetry-exporter-otlp = ../exporters/otlp;
    hs-opentelemetry-propagator-b3 = ../propagators/b3;
    hs-opentelemetry-propagator-datadog = ../propagators/datadog;
    hs-opentelemetry-propagator-w3c = ../propagators/w3c;
    hs-opentelemetry-instrumentation-cloudflare = ../instrumentation/cloudflare;
    hs-opentelemetry-instrumentation-conduit = ../instrumentation/conduit;
    hs-opentelemetry-instrumentation-hspec = ../instrumentation/hspec;
    hs-opentelemetry-instrumentation-http-client = ../instrumentation/http-client;
    hs-opentelemetry-instrumentation-persistent = ../instrumentation/persistent;
    hs-opentelemetry-instrumentation-persistent-mysql = ../instrumentation/persistent-mysql;
    hs-opentelemetry-instrumentation-postgresql-simple = ../instrumentation/postgresql-simple;
    hs-opentelemetry-instrumentation-yesod = ../instrumentation/yesod;
    hs-opentelemetry-instrumentation-wai = ../instrumentation/wai;
  };

  localPackageCabalDerivations = hfinal: lib.mapAttrs (name: path: hfinal.callCabal2nix name path {}) localPackages;

  pluckLocalPackages = hpkgs:
    let
      narrowAttrs = sourceAttrs: matchAttrs:
        lib.foldl' (acc: key:
          if lib.hasAttr key matchAttrs then
            acc // { "${key}" = sourceAttrs.${key}; }
          else
            acc
        ) {} (lib.attrNames sourceAttrs);
    in narrowAttrs hpkgs localPackages;

  extendedPackageSetByGHCVersions = listToAttrs (
    map (ghcVersion: {
      name = ghcVersion;
      value = pkgs.haskell.packages.${ghcVersion}.extend (final: _prev: localPackageCabalDerivations final);
    })
    supportedGHCVersions
  );

  localPackageMatrix = listToAttrs (
    lib.concatMap (
      ghcVersion: let
        myLocalPackages = pluckLocalPackages extendedPackageSetByGHCVersions.${ghcVersion};
      in
        map (localPackage: {
          name = "${localPackage}-${ghcVersion}";
          value = myLocalPackages.${localPackage};
        })
        (attrNames myLocalPackages)
    )
    supportedGHCVersions
  );

  localDevPackageDeps = hsPackageSet:
    lib.concatMapAttrs (_: v:
      listToAttrs (
        map (p: {
          name = p.pname;
          value = p;
        })
        v.getBuildInputs.haskellBuildInputs
      ))
    (pluckLocalPackages hsPackageSet);

  localDevPackageDepsAsAttrSet = hsPackageSet:
    lib.filterAttrs (k: _: !builtins.hasAttr k (pluckLocalPackages hsPackageSet))
    (localDevPackageDeps hsPackageSet);
}
