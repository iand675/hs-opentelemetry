# hs-opentelemetry-exporter-in-memory

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-exporter-in-memory?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-exporter-in-memory)

Collects exported spans, metrics, and logs in memory. Intended for testing
instrumented code.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Set up an in-memory exporter, run instrumented code, then inspect the results:

```haskell
import OpenTelemetry.Exporter.InMemory.Span (inMemorySpanExporter, getFinishedSpans)
import OpenTelemetry.Exporter.InMemory.Assertions (assertHasSpan)
import OpenTelemetry.Processor.Simple (simpleProcessor)

test :: IO ()
test = do
  exporter <- inMemorySpanExporter
  -- configure a TracerProvider with simpleProcessor exporter
  -- ... run instrumented code ...
  spans <- getFinishedSpans exporter
  assertHasSpan "handleRequest" spans
```

The `OpenTelemetry.Exporter.InMemory.Assertions` module provides HUnit-style
assertions (`assertHasSpan`, `assertSpanHasAttribute`, etc.) for verifying
span/metric/log output in tests.
