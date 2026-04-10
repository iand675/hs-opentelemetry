# hs-opentelemetry-instrumentation-http-client

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-http-client?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-http-client)

OpenTelemetry instrumentation for
[http-client](https://hackage.haskell.org/package/http-client) and
[http-conduit](https://hackage.haskell.org/package/http-conduit). Creates
client spans for outgoing HTTP requests with method, URL, and status code
attributes following the
[OTel HTTP semantic conventions](https://opentelemetry.io/docs/specs/semconv/http/).

Also propagates trace context in outgoing request headers and provides optional
HTTP client metrics via `OpenTelemetry.Instrumentation.HttpClient.Metrics`.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

The instrumented functions are drop-in replacements. Import them instead of
the `Network.HTTP.Simple` originals, and make sure the SDK is initialized so
spans have somewhere to go:

```haskell
import OpenTelemetry.Instrumentation.HttpClient (httpLbs)
import OpenTelemetry.Trace (withTracerProvider)
import Network.HTTP.Client (newManager, defaultManagerSettings, parseRequest)

main :: IO ()
main = withTracerProvider $ \_ -> do
  manager <- newManager defaultManagerSettings
  req <- parseRequest "https://example.com/api"
  response <- httpLbs req manager
  -- A client span "GET" is created with url, status code, etc.
  print response
```

For the lower-level API, use `OpenTelemetry.Instrumentation.HttpClient.Raw`.
For the `http-conduit` simple interface, use
`OpenTelemetry.Instrumentation.HttpClient.Simple`.
