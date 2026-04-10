# hs-opentelemetry-instrumentation-ghc-metrics

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-ghc-metrics?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-ghc-metrics)

Registers GHC RTS statistics as OpenTelemetry metrics (GC pause times,
allocation rates, thread counts, etc.). Requires the program to be run with
`+RTS -T` (or `-t`, `-s`) so that `GHC.Stats.getRTSStats` is enabled.

Also provides process-level metrics (RSS, CPU time) via
`OpenTelemetry.Instrumentation.ProcessMetrics`.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Register GHC metrics after initializing the SDK:

```haskell
import OpenTelemetry.Instrumentation.GHCMetrics (registerGHCMetrics)
import OpenTelemetry.Metric.Core (getGlobalMeterProvider, getMeter)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  mp <- getGlobalMeterProvider
  meter <- getMeter mp "my-service"
  _ <- registerGHCMetrics meter
  -- GC pause times, allocation rates, thread counts, etc.
  -- are now exported alongside your application metrics.
  runMyApp
```

Run with `+RTS -T` to enable RTS statistics collection.
