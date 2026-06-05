# hs-opentelemetry-otlp

[![hs-opentelemetry-otlp](https://img.shields.io/hackage/v/hs-opentelemetry-otlp?style=flat-square&logo=haskell&label=hs-opentelemetry-otlp&labelColor=5D4F85)](https://hackage.haskell.org/package/hs-opentelemetry-otlp)

A package containing `.hs` files with data types generated from the Protobuf definitions (i.e.: `.proto` files) of the OpenTelemetry protocol (OTLP).

The modules are generated with [`wireform-proto`][wireform], which produces
plain Haskell records with direct field access (rather than the lens-based
API of `proto-lens`). Each message becomes a record with a `default<Type>`
value, and the `Proto.Encode`/`Proto.Decode` modules from `wireform-proto`
provide `encodeMessage`/`decodeMessage`.

[wireform]: https://github.com/iand675/wireform-

## Code Generation Instructions

To generate `.hs` files from a new version of OTLP, you need to take the corresponding Git tag from the opentelemetry-proto repository[^1], write it into the `OTLP_VERSION` file, and run the `./scripts/generate-modules.sh` script.

The script clones `opentelemetry-proto`, copies the `.proto` files into `proto/`,
and runs the `hs-opentelemetry-otlp-gen` executable (guarded behind the
`codegen` cabal flag) which drives `wireform-proto`'s code generator. No
`protoc` binary is required.

Generated files can be found in the `src` directory.

[^1]: https://github.com/open-telemetry/opentelemetry-proto
