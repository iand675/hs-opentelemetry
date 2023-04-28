{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

    # TODO: remove this once hourglass merges https://github.com/vincenthz/hs-hourglass/pull/56
    hs-hourglass = {
      url = "github:k0001/hs-hourglass/cfc2a4b01f9993b1b51432f0a95fa6730d9a558a";
      flake = false;
    };
    # TODO: remove this once https://github.com/vincenthz/hs-crypto-random/pull/14 is merged
    hs-crypto-random = {
      url = "github:9999years/hs-crypto-random/a4bbb57c5fb17c029f2810dc2a47c5f289e5df8d";
      flake = false;
    };
    streaming = {
      url = "github:haskell-streaming/streaming/0c815bf9043d0f0cbda92b80ef791892e2b7fb43";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
      ];

      perSystem = {
        self',
        config,
        pkgs,
        system,
        ...
      }: let
        baseConfiguration = compilerVersion: {
          # There are a couple of naughty packages that break assertions, so we have to omit them here.
          basePackages = builtins.removeAttrs pkgs.haskell.packages.${compilerVersion} ["graphql" "wai-token-bucket-ratelimiter"];
          # If you have a .cabal file in the root, this option is determined
          # automatically. Otherwise, specify all your local packages here.
          packages = {
            hs-opentelemetry-sdk.root = ./sdk;
            hs-opentelemetry-api.root = ./api;
            hs-opentelemetry-otlp.root = ./otlp;
            hs-opentelemetry-exporter-handle.root = ./exporters/handle;
            hs-opentelemetry-exporter-in-memory.root = ./exporters/in-memory;
            hs-opentelemetry-exporter-otlp.root = ./exporters/otlp;
            hs-opentelemetry-propagator-b3.root = ./propagators/b3;
            hs-opentelemetry-propagator-datadog.root = ./propagators/datadog;
            hs-opentelemetry-propagator-w3c.root = ./propagators/w3c;
            hs-opentelemetry-utils-exceptions.root = ./utils/exceptions;
            hs-opentelemetry-vendor-honeycomb.root = ./vendors/honeycomb;
            hs-opentelemetry-instrumentation-cloudflare.root =
              ./instrumentation/cloudflare;
            hs-opentelemetry-instrumentation-conduit.root =
              ./instrumentation/conduit;
            hs-opentelemetry-instrumentation-hspec.root =
              ./instrumentation/hspec;
            hs-opentelemetry-instrumentation-http-client.root =
              ./instrumentation/http-client;
            hs-opentelemetry-instrumentation-persistent.root =
              ./instrumentation/persistent;
            hs-opentelemetry-instrumentation-postgresql-simple.root =
              ./instrumentation/postgresql-simple;
            hs-opentelemetry-instrumentation-yesod.root =
              ./instrumentation/yesod;
            hs-opentelemetry-instrumentation-wai.root = ./instrumentation/wai;
            example-yesod-minimal.root = ./examples/yesod-minimal;
            example-hspec.root = ./examples/hspec;
          };

          # Dependency overrides go here. See https://haskell.flake.page/dependency
          # source-overrides = { };

          devShell = {
            #  Defaults provided by the haskell-flake tooling are cabal, hlint, haskell-language-server, and ghcid.
            #  Everything else we want can be added here.
            tools = hp:
              {
                implicit-hie = hp.implicit-hie;
                hpack = hp.hpack;
                treefmt = config.treefmt.build.wrapper;
                steeloverseer = hp.steeloverseer;
                ghcid = null; # Glitchy on Nix for GHC 9.4
              }
              // config.treefmt.build.programs;
          };

          # devShell omitted in order to provide our own default.
          autoWire = ["packages" "apps" "checks"];
        };

        ghc810 = baseConfiguration "ghc810";
        ghc90 = baseConfiguration "ghc90";
        ghc92 =
          baseConfiguration "ghc92"
          // {
            overrides = self: super:
              with pkgs.haskell.lib; {
                hourglass =
                  self.callCabal2nix "hourglass" inputs.hs-hourglass {};
                bsb-http-chunked = dontCheck super.bsb-http-chunked;
                microlens-th = dontCheck super.microlens-th;
              };
          };
        # There are failing assertions in Nix's haskell-modules/configuration-common.nix
        # for GHC 9.4 + the hspec >= 2.10. It seems like removing the offending
        # packages from the build fixes the issue, but the tests don't pass for older
        # versions of hspec, so we have to override those as well.
        ghc94 =
          baseConfiguration "ghc944"
          // {
            source-overrides = {
              hspec-discover = "2.9.7";
              hspec-meta = "2.9.3";
              postgresql-simple = "0.6.5";
            };
            overrides = self: super:
              with pkgs.haskell.lib; {
                hspec = dontCheck (self.callHackage "hspec" "2.9.7" {});
                hspec-core =
                  dontCheck (self.callHackage "hspec-core" "2.9.7" {});
                persistent =
                  doJailbreak (self.callHackage "persistent" "2.14.5.0" {});

                hourglass =
                  self.callCabal2nix "hourglass" inputs.hs-hourglass {};
                bsb-http-chunked = dontCheck super.bsb-http-chunked;
                microlens-th = dontCheck super.microlens-th;
              };
          };
        ghc96 =
          baseConfiguration "ghc96"
          // {
            source-overrides = {
              http-api-data = "0.5.1";
              attoparsec-iso8601 = "1.1.0.0";
              hedgehog = "1.2";
              tasty-hedgehog = "1.4.0.1";
              proto-lens = "0.7.1.3";
              proto-lens-runtime = "0.7.0.4";
              postgresql-simple = "0.6.5";
              recv = "0.1.0";
            };
            overrides = self: super:
              with pkgs.haskell.lib; {
                retry = dontCheck super.retry;
                # Persistent doesn't have an official GHC 9.6-compatible release yet,
                # so we have to lift the restriction on the template-haskell version.
                persistent =
                  doJailbreak (self.callHackage "persistent" "2.14.5.0" {});
                # There is a revision on Hackage, but it hasn't propagated to nixpkgs yet.
                newtype-generics =
                  doJailbreak (self.callHackage "newtype-generics" "0.6.2" {});
                zigzag =
                  doJailbreak (self.callHackage "zigzag" "0.0.1.0" {});
                streaming = self.callCabal2nix "streaming" inputs.streaming {};

                hourglass =
                  self.callCabal2nix "hourglass" inputs.hs-hourglass {};
                crypto-random =
                  self.callCabal2nix "crypto-random" inputs.hs-crypto-random
                  {};
                bsb-http-chunked = dontCheck super.bsb-http-chunked;
                microlens-th = doJailbreak super.microlens-th;
                persistent-qq =
                  dontCheck (self.callHackage "persistent-qq" "2.12.0.5" {});
                warp = dontCheck (self.callHackage "warp" "3.3.25" {});
              };
          };
        defaultProject = ghc92;
      in {
        # Default shell.
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.haskellProjects.default.outputs.devShell
            config.mission-control.devShell
            config.pre-commit.devShell
          ];
        };
        devShells.ghc810 = pkgs.mkShell {
          inputsFrom = [
            config.haskellProjects.ghc810.outputs.devShell
            config.mission-control.devShell
            config.pre-commit.devShell
          ];
        };
        devShells.ghc92 = pkgs.mkShell {
          inputsFrom = [
            config.haskellProjects.ghc92.outputs.devShell
            config.mission-control.devShell
            config.pre-commit.devShell
          ];
        };
        devShells.ghc94 = pkgs.mkShell {
          inputsFrom = [
            config.haskellProjects.ghc94.outputs.devShell
            config.mission-control.devShell
            config.pre-commit.devShell
          ];
        };
        devShells.ghc96 = pkgs.mkShell {
          inputsFrom = [
            config.haskellProjects.ghc96.outputs.devShell
            config.mission-control.devShell
            config.pre-commit.devShell
          ];
        };
        # TODO, I really want to get this to build all packages for all GHC versions that are supported,
        # but it seems to currently only builds for the default GHC version.
        packages.default =
          pkgs.linkFarmFromDrvs "all-hs-packages"
          (builtins.attrValues (removeAttrs self'.packages ["default"]));

        treefmt = {
          inherit (config.flake-root) projectRootFile;
          # Here you can specify the formatters to use
          programs.alejandra.enable = true;
          programs.ormolu.enable = true;
          programs.ormolu.package =
            defaultProject.basePackages.fourmolu;
          settings.formatter.ormolu = {
            options = ["--ghc-opt" "-XImportQualifiedPost"];
          };
        };

        mission-control.scripts = {
          repl = {
            description = "Start the repl";
            exec = ''
              cabal repl "$@"
            '';
            category = "Dev Tools";
          };
          hlint-all = {
            description = "Run hlint on all packages that we care to enforce style on";
            exec = ''
              hlint --ignore-glob "otlp/**/*.hs" .
            '';
            category = "Dev Tools";
          };
          hpack-all = {
            description = "Run hpack on all packages";
            exec = ''
              find . -name "package.yaml" -exec hpack {} \;
            '';
          };
          docs = {
            description = "Start Hoogle server for project dependencies";
            exec = ''
              echo http://127.0.0.1:8888
              hoogle serve -p 8888 --local
            '';
            category = "Dev Tools";
          };
          oversee = {
            description = "Start feedback loops for development";
            exec = ''
              sos
            '';
            category = "Dev Tools";
          };
          format = {
            description = "Format all files";
            exec = ''
              treefmt
            '';
            category = "Dev Tools";
          };
        };

        pre-commit = {
          check.enable = true;

          settings = {
            hooks = {
              shellcheck.enable = true;
              hlint.enable = true;
              alejandra.enable = true;
              fourmolu.enable = true;
              hpack.enable = true;
            };

            # This is really for fourmolu, but the current version of pre-commit
            # shares the same configuration for fourmolu & ormolu.
            settings.ormolu.defaultExtensions = ["ImportQualifiedPost"];
          };
        };

        # Typically, you just want a single project named "default". But
        # multiple projects are also possible, each using different GHC version.
        haskellProjects = {
          inherit ghc810 ghc92 ghc94 ghc96;
          default = defaultProject;
        };
      };
    };
}
