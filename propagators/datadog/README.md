# hs-opentelemetry-propagator-datadog

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-propagator-datadog?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-propagator-datadog)

Datadog trace context propagation for hs-opentelemetry. Implements the
`x-datadog-trace-id`, `x-datadog-parent-id`, and `x-datadog-sampling-priority`
headers.

Use this when your services communicate with Datadog-instrumented systems
that don't support W3C TraceContext.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Set `OTEL_PROPAGATORS` before starting your application. Combine with the
default W3C propagators so both formats are understood:

```
OTEL_PROPAGATORS=tracecontext,baggage,datadog
```

Then initialize the SDK as usual. Instrumentation middleware (wai, http-client)
injects and extracts Datadog headers alongside W3C ones:

```haskell
import OpenTelemetry.Trace (withTracerProvider)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMw <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMw myApp
```

For programmatic use without the SDK's env var resolution:

```haskell
import OpenTelemetry.Propagator.Datadog (datadogTraceContextPropagator)
import OpenTelemetry.Context (setGlobalTextMapPropagator)

setGlobalTextMapPropagator datadogTraceContextPropagator
```

## Module

`OpenTelemetry.Propagator.Datadog`
