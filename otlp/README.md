# otlp
A package containing `.hs` files with data types generated from `.proto` files in the `proto` submodule.

## Auto-generation Instructions
To generate `.hs` files from a new version of the `proto` submodule, check that all of the modules that should be generated are listed under `generated-other-modules` in `package.yaml` and run `stack build`.
