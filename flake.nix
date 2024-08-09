{
  description = "Haskell OpenTelemetry support.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv/v1.0.5";
    # Hack to avoid needing to use impure when loading the devenv root.
    #
    # See .envrc for how we substitute this with the actual path.
    #
    # Alternatively, use the --impure flag when running nix develop, nix show, etc.
    # devenv-root = {
    #   url = "file+file:///dev/null";
    #   flake = false;
    # };

    otlp-protobufs = {
      url = "github:open-telemetry/opentelemetry-proto/b43e9b18b76abf3ee040164b55b9c355217151f3";
      flake = false;
    };
  };

  outputs = inputs @ {
    # devenv-root,
    nixpkgs,
    devenv,
    flake-utils,
    ...
  }: let
    inherit (nixpkgs) lib;
    inherit
      (import ./nix/matrix.nix)
      supportedSystems
      ;
    ignoreGeneratedFiles = attrs:
      {
        excludes =
          attrs.excludes
          or []
          ++ [
            "^otlp/src/"
            ".*\\.cabal$"
          ];
      }
      // attrs;
    pre-commit-hooks = {
      # General hooks
      end-of-file-fixer = ignoreGeneratedFiles {
        enable = true;
        excludes = [
          ".*\\.l?hs$"
          ".*\\.proto$"
        ];
      };
      # Nix hooks
      alejandra.enable = true;
      deadnix.enable = true;
      # Haskell hooks
      fourmolu = ignoreGeneratedFiles {
        enable = true;
      };
      hpack.enable = true;
    };
  in
    {
      lib = {
        haskellOverlay = import ./nix/haskell-overlay.nix;
      };
    }
    // flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      haskellPackageUtils = import ./nix/haskell-packages.nix {
        inherit
          lib
          pkgs
          ;
      };
      inherit (haskellPackageUtils) extendedPackageSetByGHCVersions;

      mkShellForGHC = ghcVersion: let
        myHaskellPackages = extendedPackageSetByGHCVersions.${ghcVersion};
      in
        devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({...}: {
              # devenv.root = let
              #   devenvRootFileContent = builtins.readFile devenv-root.outPath;
              # in
              #   pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
              # packages = with pkgs; [
              #   ghciwatch
              # ];

              dotenv.enable = true;

              languages.haskell = {
                enable = true;
                package = myHaskellPackages.ghc.withHoogle (
                  hpkgs:
                    lib.attrVals (builtins.attrNames (haskellPackageUtils.localDevPackageDepsAsAttrSet myHaskellPackages)) hpkgs
                );
              };

              pre-commit.hooks = pre-commit-hooks;
            })
            (import ./nix/devenv/otlp-protobuf-setup.nix)
          ];
        };
    in {
      packages =
        {
          # devenv-up = self.devShells.${system}.default.config.procfileScript;
        }
        // haskellPackageUtils.localPackageMatrix;

      devShells = rec {
        default = ghc96;
        # ghc810 = mkShellForGHC "ghc810";
        # ghc90 = mkShellForGHC "ghc90";
        ghc92 = mkShellForGHC "ghc92";
        ghc94 = mkShellForGHC "ghc94";
        ghc96 = mkShellForGHC "ghc96";
        ghc98 = mkShellForGHC "ghc98";
        ghc910 = mkShellForGHC "ghc98";
      };

      checks = {
        pre-commit-check = devenv.inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = pre-commit-hooks;
        };
      };
    });

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = [
      "https://cache.iog.io"
      "https://cache.garnix.io"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    allow-import-from-derivation = "true";
  };
}
