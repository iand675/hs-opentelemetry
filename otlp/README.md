# hs-opentelemetry-otlp

[![hs-opentelemetry-otlp](https://img.shields.io/hackage/v/hs-opentelemetry-otlp?style=flat-square&logo=haskell&label=hs-opentelemetry-otlp&labelColor=5D4F85)](https://hackage.haskell.org/package/hs-opentelemetry-otlp)

A package containing `.hs` files with data types generated from the Protobuf definitions (i.e.: `.proto` files) of the OpenTelemetry protocol (OTLP).

## Code Generation Instructions

To generate `.hs` files from a new version of OTLP, you need to take the corresponding Git tag from the opentelemetry-proto repository[^1], write it into the `OTLP_VERSION` file, and run the `./scripts/generate-modules.sh` script.

Generated files can be found in the `src` directory.

[^1] https://github.com/open-telemetry/opentelemetry-proto
