# hs-opentelemetry-exporter-otlp

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-exporter-otlp?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-exporter-otlp)

OTLP exporter for traces, metrics, and logs. Sends telemetry data to any
[OTLP-compatible](https://opentelemetry.io/docs/specs/otlp/) backend over
HTTP (protobuf) or gRPC.

Works with Jaeger, Honeycomb, Datadog, Grafana Cloud, the OpenTelemetry
Collector, and any other service that accepts OTLP.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

The SDK automatically configures an OTLP exporter when `OTEL_EXPORTER_OTLP_ENDPOINT`
is set. For manual setup:

```haskell
import OpenTelemetry.Exporter.OTLP.Span (otlpSpanExporter)

config <- loadExporterEnvironmentVariables
exporter <- otlpSpanExporter config
```

Metric and log exporters are available from `OpenTelemetry.Exporter.OTLP.Metric`
and `OpenTelemetry.Exporter.OTLP.LogRecord`.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4318` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | | Comma-separated `key=value` headers (e.g. API keys) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `http/protobuf` | `http/protobuf` or `grpc` |
| `OTEL_EXPORTER_OTLP_TIMEOUT` | `10000` | Request timeout in milliseconds |

## gRPC

Enable the `grpc` Cabal flag for gRPC transport support.
