# hs-opentelemetry-propagator-b3

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-propagator-b3?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-propagator-b3)

[B3 propagation](https://github.com/openzipkin/b3-propagation) for
hs-opentelemetry. Supports both the single-header (`b3`) and multi-header
(`X-B3-TraceId`, `X-B3-SpanId`, etc.) formats.

Use this for interop with Zipkin-based tracing systems.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

### Via environment variable

The SDK registers B3 automatically. Set `OTEL_PROPAGATORS` before
starting your application:

```
OTEL_PROPAGATORS=b3
```

Or for multi-header format:

```
OTEL_PROPAGATORS=b3multi
```

You can combine it with the default W3C propagators:

```
OTEL_PROPAGATORS=tracecontext,baggage,b3
```

Then initialize the SDK as usual. Instrumentation middleware (wai, http-client,
hw-kafka-client) picks up the global propagator and uses it to inject context
into outgoing requests and extract it from incoming ones:

```haskell
import OpenTelemetry.Trace (withTracerProvider)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)

main :: IO ()
main = withTracerProvider $ \_ -> do
  -- B3 headers are injected/extracted automatically
  -- based on OTEL_PROPAGATORS
  otelMw <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMw myApp
```

### Programmatic

For direct use without the SDK's env var resolution:

```haskell
import OpenTelemetry.Propagator.B3 (b3TraceContextPropagator)
import OpenTelemetry.Context (setGlobalTextMapPropagator)

setGlobalTextMapPropagator b3TraceContextPropagator
```

## Module

`OpenTelemetry.Propagator.B3`
