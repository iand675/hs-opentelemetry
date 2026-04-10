# hs-opentelemetry-otlp

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-otlp?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-otlp)

Haskell data types generated from the [OpenTelemetry Protocol](https://opentelemetry.io/docs/specs/otlp/)
protobuf definitions using [proto-lens](https://hackage.haskell.org/package/proto-lens).

This is a low-level package. Most users should use
[hs-opentelemetry-exporter-otlp](https://github.com/iand675/hs-opentelemetry/tree/main/exporters/otlp) instead, which provides
the export logic on top of these types.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Regenerating

To regenerate from a new OTLP version, update the `OTLP_VERSION` file with the
corresponding tag from
[opentelemetry-proto](https://github.com/open-telemetry/opentelemetry-proto)
and run `./scripts/generate-modules.sh`.
