{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { self', config, pkgs, ... }:
        let
          baseConfiguration = {
            # If you have a .cabal file in the root, this option is determined
            # automatically. Otherwise, specify all your local packages here.
            packages.hs-opentelemetry-sdk.root = ./sdk;
            packages.hs-opentelemetry-api.root = ./api;
            packages.hs-opentelemetry-otlp.root = ./otlp;
            packages.hs-opentelemetry-exporter-handle.root = ./exporters/handle;
            packages.hs-opentelemetry-exporter-in-memory.root =
              ./exporters/in-memory;
            packages.hs-opentelemetry-exporter-jaeger.root = ./exporters/jaeger;
            packages.hs-opentelemetry-exporter-otlp.root = ./exporters/otlp;
            packages.hs-opentelemetry-exporter-prometheus.root =
              ./exporters/prometheus;
            packages.hs-opentelemetry-exporter-zipkin.root = ./exporters/zipkin;
            packages.hs-opentelemetry-propagator-b3.root = ./propagators/b3;
            packages.hs-opentelemetry-propagator-datadog.root =
              ./propagators/datadog;
            packages.hs-opentelemetry-propagator-jaeger.root =
              ./propagators/jaeger;
            packages.hs-opentelemetry-propagator-w3c.root = ./propagators/w3c;
            packages.hs-opentelemetry-utils-exceptions.root =
              ./utils/exceptions;
            packages.hs-opentelemetry-vendor-honeycomb.root =
              ./vendors/honeycomb;
            packages.hs-opentelemetry-instrumentation-cloudflare.root =
              ./instrumentation/cloudflare;
            packages.hs-opentelemetry-instrumentation-conduit.root =
              ./instrumentation/conduit;
            packages.hs-opentelemetry-instrumentation-hspec.root =
              ./instrumentation/hspec;
            packages.hs-opentelemetry-instrumentation-http-client.root =
              ./instrumentation/http-client;
            packages.hs-opentelemetry-instrumentation-persistent.root =
              ./instrumentation/persistent;
            packages.hs-opentelemetry-instrumentation-postgresql-simple.root =
              ./instrumentation/postgresql-simple;
            packages.hs-opentelemetry-instrumentation-yesod.root =
              ./instrumentation/yesod;
            packages.hs-opentelemetry-instrumentation-wai.root =
              ./instrumentation/wai;

            # The base package set representing a specific GHC version.
            # By default, this is pkgs.haskellPackages.
            # You may also create your own. See https://haskell.flake.page/package-set
            basePackages = pkgs.haskell.packages.ghc90;

            # Dependency overrides go here. See https://haskell.flake.page/dependency
            # source-overrides = { };

            devShell = {
              #  # Enabled by default
              #  enable = true;
              #
              #  # Programs you want to make available in the shell.  #  # Default programs can be disabled by setting to 'null'
              tools = hp: {
                fourmolu = hp.fourmolu;
                stack = hp.stack;
                hlint = hp.hlint;
                implicit-hie = hp.implicit-hie;
                haskell-language-server = hp.haskell-language-server;
                hspec-discover = hp.hspec-discover;
              };

              #
              # hlsCheck.enable = true;
            };

            # devShell omitted in order to provide our own default.
            autoWire = [ "packages" "apps" "checks" ];
          };
        in rec {
          # Default shell.
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.haskellProjects.default.outputs.devShell
              config.mission-control.devShell
            ];
          };
          treefmt = {
            inherit (config.flake-root) projectRootFile;
            programs.nixpkgs-fmt.enable = true;
            # Here you can specify the formatters to use
            programs.nixfmt.enable = true;
            programs.ormolu.enable = true;
            programs.ormolu.package =
              haskellProjects.default.basePackages.ormolu;
            programs.cabal-fmt.enable = true;
          };
          mission-control.scripts = {
            repl = {
              description = "Start the cabal repl";
              exec = ''
                cabal repl "$@"
              '';
              category = "Dev Tools";
            };
            hlint-all = {
              description =
                "Run hlint on all packages that we care to enforce style on";
              exec = ''
                hlint --ignore-glob "otlp/**/*.hs" .
              '';
              category = "Dev Tools";
            };
            docs = {
              description = "Start Hoogle server for project dependencies";
              exec = ''
                echo http://127.0.0.1:8888
                hoogle serve -p 8888 --local
              '';
              category = "Dev Tools";
            };
          };
          # Typically, you just want a single project named "default". But
          # multiple projects are also possible, each using different GHC version.
          haskellProjects = rec {
            default = ghc92;
            ghc810 = baseConfiguration // {
              basePackages = pkgs.haskell.packages.ghc810;
            };
            ghc90 = baseConfiguration // {
              basePackages = pkgs.haskell.packages.ghc90;
            };
            ghc92 = baseConfiguration // {
              basePackages = pkgs.haskell.packages.ghc92;
            };
            # ghc94 = baseConfiguration // {
            #   basePackages = removeAttrs pkgs.haskell.packages.ghc94 ["graphql" "wai-token-bucket-ratelimiter"];
            # };
            # ghc96 = baseConfiguration // {
            #   basePackages = pkgs.haskell.packages.ghc96;
            # };
            # ghcHEAD = baseConfiguration // {
            #   basePackages = pkgs.haskell.packages.ghcHEAD;
            # };
          };

          # haskell-flake doesn't set the default package, but you can do it here.
          # packages.default = self'.packages.hs-opentelemetry-sdk;
        };
    };
}
