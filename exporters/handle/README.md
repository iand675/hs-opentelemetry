# hs-opentelemetry-exporter-handle

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-exporter-handle?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-exporter-handle)

Exports traces, metrics, and logs to a `Handle` (typically `stdout` or `stderr`).
Useful for local development and debugging.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

The handle exporter is selected automatically when you set:

```
OTEL_TRACES_EXPORTER=console
```

For manual wiring (e.g. when building a custom `TracerProvider`):

```haskell
import OpenTelemetry.Exporter.Handle.Span (makeHandleSpanExporter)
import OpenTelemetry.Processor.Simple (simpleProcessor)
import System.IO (stdout)

exporter <- makeHandleSpanExporter stdout
let processor = simpleProcessor exporter
-- pass processor to your TracerProvider configuration
```

Metric and log handle exporters are available from
`OpenTelemetry.Exporter.Handle.Metric` and `OpenTelemetry.Exporter.Handle.LogRecord`.
