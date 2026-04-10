# hs-opentelemetry-propagator-w3c

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-propagator-w3c?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-propagator-w3c)

[W3C TraceContext](https://www.w3.org/TR/trace-context/) and
[W3C Baggage](https://www.w3.org/TR/baggage/) propagation for
hs-opentelemetry.

This is the default propagation format. The SDK enables `tracecontext,baggage`
unless you override `OTEL_PROPAGATORS`, so most applications don't need to
configure anything.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## How it works

When you call `withTracerProvider` (or `initializeGlobalTracerProvider`), the
SDK reads `OTEL_PROPAGATORS` (default: `tracecontext,baggage`) and sets the
global propagator. Instrumentation middleware then uses it automatically:

```haskell
import OpenTelemetry.Trace (withTracerProvider)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)

main :: IO ()
main = withTracerProvider $ \_ -> do
  -- W3C traceparent/tracestate headers are extracted from incoming
  -- requests and injected into outgoing ones automatically
  otelMw <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMw myApp
```

For manual composition without the SDK:

```haskell
import OpenTelemetry.Propagator.W3CTraceContext (w3cTraceContextPropagator)
import OpenTelemetry.Propagator.W3CBaggage (w3cBaggagePropagator)
import OpenTelemetry.Context (setGlobalTextMapPropagator)

setGlobalTextMapPropagator (w3cTraceContextPropagator <> w3cBaggagePropagator)
```

## Modules

| Module | Headers |
|---|---|
| `OpenTelemetry.Propagator.W3CTraceContext` | `traceparent`, `tracestate` |
| `OpenTelemetry.Propagator.W3CBaggage` | `baggage` |
