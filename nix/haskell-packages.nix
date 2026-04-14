{
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    listToAttrs
    map
    ;
  inherit (import ./matrix.nix) supportedGHCVersions;
in rec {
  inherit pkgs;

  skipPackages = [
    "hs-opentelemetry-exporter-handle"
    "hs-opentelemetry-exporter-in-memory"
    "hs-opentelemetry-exporter-otlp"
    "hs-opentelemetry-sdk"
    "hs-opentelemetry-instrumentation-cloudflare"
    "hs-opentelemetry-instrumentation-conduit"
    "hs-opentelemetry-instrumentation-ghc-metrics"
    "hs-opentelemetry-instrumentation-hspec"
    "hs-opentelemetry-instrumentation-http-client"
    "hs-opentelemetry-instrumentation-hw-kafka-client"
    "hs-opentelemetry-instrumentation-persistent"
    "hs-opentelemetry-instrumentation-persistent-mysql"
    "hs-opentelemetry-instrumentation-postgresql-simple"
    "hs-opentelemetry-instrumentation-yesod"
    "hs-opentelemetry-instrumentation-wai"
    "hs-opentelemetry-instrumentation-tasty"
    "hs-opentelemetry-utils-exceptions"
    "hs-opentelemetry-vendor-honeycomb"
    "hspec-example"
    "hw-kafka-client-example"
    "yesod-minimal"
  ];

  localPackages = {
    hs-opentelemetry-api = ../api;
    hs-opentelemetry-api-types = ../api-types;
    hs-opentelemetry-sdk = ../sdk;
    hs-opentelemetry-otlp = ../otlp;
    hs-opentelemetry-semantic-conventions = ../semantic-conventions;
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
    hs-opentelemetry-instrumentation-hw-kafka-client = ../instrumentation/hw-kafka-client;
    hs-opentelemetry-instrumentation-persistent = ../instrumentation/persistent;
    hs-opentelemetry-instrumentation-persistent-mysql = ../instrumentation/persistent-mysql;
    hs-opentelemetry-instrumentation-postgresql-simple = ../instrumentation/postgresql-simple;
    hs-opentelemetry-instrumentation-yesod = ../instrumentation/yesod;
    hs-opentelemetry-instrumentation-wai = ../instrumentation/wai;
    hs-opentelemetry-instrumentation-tasty = ../instrumentation/tasty;
    hs-opentelemetry-utils-exceptions = ../utils/exceptions;
    hs-opentelemetry-vendor-honeycomb = ../vendors/honeycomb;

    hspec-example = ../examples/hspec;
    hw-kafka-client-example = ../examples/hw-kafka-client-example;
    yesod-minimal = ../examples/yesod-minimal;
  };

  localPackageCabalDerivations = hfinal: let
    baseConfig = lib.mapAttrs (name: path: pkgs.haskell.lib.compose.doJailbreak (hfinal.callCabal2nix name path {})) localPackages;
  in
    baseConfig
    // {
      hs-opentelemetry-otlp = pkgs.haskell.lib.addSetupDepends baseConfig.hs-opentelemetry-otlp [pkgs.protobuf];
    };

  pluckLocalPackages = hpkgs: let
    narrowAttrs = sourceAttrs: matchAttrs:
      lib.foldl' (
        acc: key:
          if lib.hasAttr key matchAttrs
          then acc // {"${key}" = sourceAttrs.${key};}
          else acc
      ) {} (lib.attrNames sourceAttrs);
  in
    narrowAttrs hpkgs localPackages;

  extendedPackageSetByGHCVersions = listToAttrs (
    map (ghcVersion: {
      name = ghcVersion;
      value = pkgs.haskell.packages.${ghcVersion}.extend (final: prev: localPackageCabalDerivations final // nixpkgsHaskellTweaks final prev);
      #value = pkgs.haskell.packages.${ghcVersion}.override {overrides = nixpkgsHaskellTweaks;};
    })
    supportedGHCVersions
  );

  mapKeyValues = f: attrs: let
    inherit (lib.attrsets) foldlAttrs;
  in
    foldlAttrs (acc: key: value: acc // f key value) {} attrs;

  localPackageMatrix =
    mapKeyValues (
      key: value: let
        myLocalPackages = pluckLocalPackages value;
        k = "hs-opentelemetry-suite-${key}";
      in {
        "${k}" = pkgs.buildEnv {
          name = k;
          paths = lib.attrValues (lib.filterAttrs (n: _: !builtins.elem n skipPackages) myLocalPackages);
        };
      }
    )
    extendedPackageSetByGHCVersions;

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

  nixpkgsHaskellTweaks = final: prev: {
    # nixpkgs has 0.7.1.5, 0.7.1.6 relaxes bounds for 9.10, but we can also just
    # relax the bounds of 0.7.1.5 ourselves
    proto-lens = pkgs.haskell.lib.compose.doJailbreak prev.proto-lens;
    thread-utils-context = final.callCabal2nix "thread-utils-context" (builtins.fetchTarball {
      url = "https://hackage.haskell.org/package/thread-utils-context-0.4.1.0/thread-utils-context-0.4.1.0.tar.gz";
      sha256 = "0b5jcfnrf3rss6kbcdg7q1mhlnn4405zfd6b5w9qv3nmn7vw3mks";
    }) {};
  };
}
