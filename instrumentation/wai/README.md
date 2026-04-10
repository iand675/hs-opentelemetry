# hs-opentelemetry-instrumentation-wai

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-wai?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-wai)

WAI middleware that creates a server span for each incoming HTTP request.
Records method, route, status code, and request/response sizes as span
attributes following the
[OTel HTTP semantic conventions](https://opentelemetry.io/docs/specs/semconv/http/).

Also provides optional HTTP server metrics via
`OpenTelemetry.Instrumentation.Wai.Metrics`.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

```haskell
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMiddleware <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMiddleware myApp
```

Child spans from database or HTTP client instrumentation will nest under the
request span automatically through the thread-local context.
