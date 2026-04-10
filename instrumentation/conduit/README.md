# hs-opentelemetry-instrumentation-conduit

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-conduit?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-conduit)

OpenTelemetry instrumentation for
[conduit](https://hackage.haskell.org/package/conduit) streaming pipelines.
Wraps conduit stages in spans to trace data flow through your pipeline.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

```haskell
import OpenTelemetry.Instrumentation.Conduit (inSpan)
import OpenTelemetry.Trace (withTracerProvider, getTracer, tracerOptions)
import OpenTelemetry.Trace.Core (defaultSpanArguments)

main :: IO ()
main = withTracerProvider $ \tp -> do
  let tracer = getTracer tp "my-service" tracerOptions
  runConduitRes $
    sourceFile "input.csv"
      .| inSpan tracer "parse" defaultSpanArguments (\_ -> mapC parseRow)
      .| inSpan tracer "transform" defaultSpanArguments (\_ -> mapC transformRow)
      .| sinkFile "output.json"
```
