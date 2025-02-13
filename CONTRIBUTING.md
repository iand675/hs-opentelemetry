# Contributing

## Development Environment

This project uses [nix](https://nixos.org/guides/nix-package-manager.html) and [direnv](https://direnv.net/) to manage the development environment. To get started:

1. Install `nix` and `direnv`
2. Run `direnv allow` in the project root to load the `.envrc` file
3. Run `nix develop` to enter the development environment

The `flake.nix` file defines the development environments for different GHC versions. The default environment uses GHC 9.6, but you can enter other environments with `nix develop .#ghc92` for example.

Some of the nix configuration requires evaluation with the `--impure` flag, so if a nix command fails,
consider rerunning it in impure mode.

## Package Structure

The project is organized into several packages:

- `api`: Core OpenTelemetry API types and functions
- `sdk`: OpenTelemetry SDK implementation
- `otlp`: OpenTelemetry protocol implementation
- `exporters/*`: Exporter implementations for various backends
- `propagators/*`: Propagator implementations for various contexts
- `instrumentation/*`: Instrumentation libraries for various frameworks/libraries
- `util/*`: Utility packages

To add a new package, create a new directory under the appropriate category and update the `localPackages` set in `nix/haskell-packages.nix`.

## Submitting Changes

1. Fork the repository and create a new branch
2. Make your changes. Update the appropriate package changelog(s).
3. Commit your changes with descriptive commit message(s).
4. Push your branch to your fork.
5. Open a pull request against the main repository.

Please ensure that your changes follow the project's coding style and include tests where applicable.
