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

  skipPackages = [];

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
    hs-opentelemetry-propagator-jaeger = ../propagators/jaeger;
    hs-opentelemetry-propagator-xray = ../propagators/xray;
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
    # amazonka-2.0 has overly conservative base/containers bounds; jailbreak
    # lets it build against newer GHC (9.10+) where base >= 4.19.
    amazonka = pkgs.haskell.lib.compose.doJailbreak prev.amazonka;
    amazonka-core = pkgs.haskell.lib.compose.doJailbreak prev.amazonka-core;
    # co-log 0.7.x is in nixpkgs-unstable; our constraint is <0.7.
    # Pin to 0.6.1.2 so the instrumentation package can build.
    co-log = final.callHackage "co-log" "0.6.1.2" {};
    co-log-core = final.callHackage "co-log-core" "0.3.2.2" {};
  };
}
