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

  # Packages incompatible with specific GHC versions. Keys must match
  # supportedGHCVersions entries; absent keys default to [].
  skipPackagesByGHCVersion = {
    # mysql-0.2.1 Setup.hs uses Cabal [Char] paths that became SymbolicPath
    # in Cabal 3.14 (GHC 9.12). persistent-mysql pulls in mysql, so both fail.
    # postgresql-libpq FFI stubs generate C incompatible with libpq-18.2's
    # char* parameter type under the stricter clang in the GHC 9.12 package set.
    ghc912 = [
      "hs-opentelemetry-instrumentation-persistent-mysql"
      "hs-opentelemetry-instrumentation-postgresql-simple"
    ];
    # bytesmith-0.3.14.0 requires text >= 2.1 (uses ByteArray in Text ctor);
    # GHC 9.6/9.4 have text 2.0.x. honeycomb → chronos → bytesmith cascades.
    # co-log-0.6.1.2 also fails via a transitive bytesmith dep in its test suite.
    # TODO: release honeycomb 0.1.0.2 dropping chronos; update co-log pin.
    ghc96 = [
      "hs-opentelemetry-vendor-honeycomb"
      "hs-opentelemetry-instrumentation-co-log"
    ];
    ghc94 = [
      "hs-opentelemetry-vendor-honeycomb"
      "hs-opentelemetry-instrumentation-co-log"
    ];
  };

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
    hs-opentelemetry-instrumentation-amazonka = ../instrumentation/amazonka;
    hs-opentelemetry-instrumentation-cloudflare = ../instrumentation/cloudflare;
    hs-opentelemetry-instrumentation-co-log = ../instrumentation/co-log;
    hs-opentelemetry-instrumentation-conduit = ../instrumentation/conduit;
    hs-opentelemetry-instrumentation-ghc-metrics = ../instrumentation/ghc-metrics;
    hs-opentelemetry-instrumentation-gogol = ../instrumentation/gogol;
    hs-opentelemetry-instrumentation-hspec = ../instrumentation/hspec;
    hs-opentelemetry-instrumentation-http-client = ../instrumentation/http-client;
    hs-opentelemetry-instrumentation-hw-kafka-client = ../instrumentation/hw-kafka-client;
    hs-opentelemetry-instrumentation-katip = ../instrumentation/katip;
    hs-opentelemetry-instrumentation-monad-logger = ../instrumentation/monad-logger;
    hs-opentelemetry-instrumentation-persistent = ../instrumentation/persistent;
    hs-opentelemetry-instrumentation-persistent-mysql = ../instrumentation/persistent-mysql;
    hs-opentelemetry-instrumentation-postgresql-simple = ../instrumentation/postgresql-simple;
    hs-opentelemetry-instrumentation-yesod = ../instrumentation/yesod;
    hs-opentelemetry-instrumentation-wai = ../instrumentation/wai;
    hs-opentelemetry-instrumentation-tasty = ../instrumentation/tasty;
    hs-opentelemetry-exporter-prometheus = ../exporters/prometheus;
    hs-opentelemetry-utils-exceptions = ../utils/exceptions;
    hs-opentelemetry-vendor-honeycomb = ../vendors/honeycomb;

    hspec-example = ../examples/hspec;
    hw-kafka-client-example = ../examples/hw-kafka-client-example;
    otlp-demo = ../examples/otlp-demo;
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
        versionSkips = skipPackagesByGHCVersion.${key} or [];
        allSkips = skipPackages ++ versionSkips;
      in {
        "${k}" = pkgs.buildEnv {
          name = k;
          paths = lib.attrValues (lib.filterAttrs (n: _: !builtins.elem n allSkips) myLocalPackages);
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
    # relax the bounds of 0.7.1.5 ourselves.
    # proto-lens-runtime also caps at base < 4.21 (GHC 9.12 = base 4.21).
    proto-lens = pkgs.haskell.lib.compose.doJailbreak prev.proto-lens;
    proto-lens-runtime = pkgs.haskell.lib.compose.doJailbreak prev.proto-lens-runtime;
    # chronos-1.1.7.0 requires text >= 2.1.2 && < 2.2, but GHC 9.8 ships text
    # 2.0.2 and GHC 9.4/9.6 have older text. Relax the bound.
    chronos = pkgs.haskell.lib.compose.doJailbreak prev.chronos;
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
    # doJailbreak strips the test dep bound doctest < 0.24 so nixpkgs's
    # doctest 0.24.x can satisfy it at configure time.
    co-log = pkgs.haskell.lib.compose.doJailbreak (final.callHackage "co-log" "0.6.1.2" {});
  };
}
