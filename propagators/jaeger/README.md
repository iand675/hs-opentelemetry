# hs-opentelemetry-propagator-jaeger

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-propagator-jaeger?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-propagator-jaeger)

[Jaeger propagation format](https://www.jaegertracing.io/docs/1.21/client-libraries/#propagation-format)
for hs-opentelemetry. Implements the `uber-trace-id` header and `uberctx-*`
baggage headers.

> **Note:** The Jaeger propagation format is deprecated upstream in favor of
> W3C TraceContext. Use this for interop with legacy Jaeger deployments.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Set `OTEL_PROPAGATORS` before starting your application:

```
OTEL_PROPAGATORS=jaeger
```

Or alongside W3C:

```
OTEL_PROPAGATORS=tracecontext,baggage,jaeger
```

Then initialize the SDK as usual. Instrumentation middleware (wai, http-client)
handles `uber-trace-id` injection and extraction:

```haskell
import OpenTelemetry.Trace (withTracerProvider)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMw <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMw myApp
```

For programmatic use:

```haskell
import OpenTelemetry.Propagator.Jaeger (jaegerPropagator)
import OpenTelemetry.Context (setGlobalTextMapPropagator)

setGlobalTextMapPropagator jaegerPropagator
```

## Module

`OpenTelemetry.Propagator.Jaeger`
