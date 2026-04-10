# hs-opentelemetry-propagator-xray

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-propagator-xray?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-propagator-xray)

AWS X-Ray trace context propagation for hs-opentelemetry. Implements the
`X-Amzn-Trace-Id` header format.

Use this when running behind AWS load balancers or alongside X-Ray-instrumented
services.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Set `OTEL_PROPAGATORS` before starting your application. Combine with the
default W3C propagators:

```
OTEL_PROPAGATORS=tracecontext,baggage,xray
```

Then initialize the SDK as usual. Instrumentation middleware (wai, http-client)
extracts and injects the `X-Amzn-Trace-Id` header alongside W3C headers:

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
import OpenTelemetry.Propagator.XRay (xrayPropagator)
import OpenTelemetry.Context (setGlobalTextMapPropagator)

setGlobalTextMapPropagator xrayPropagator
```

## Module

`OpenTelemetry.Propagator.XRay`
