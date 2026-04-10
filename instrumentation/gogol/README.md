# hs-opentelemetry-instrumentation-gogol

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-gogol?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-gogol)

OpenTelemetry instrumentation for the
[Gogol](https://hackage.haskell.org/package/gogol) Google Cloud SDK. Provides
wrapper functions that create spans per Google API call with RPC semantic
convention attributes.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Gogol doesn't have a hooks/middleware API, so instrumentation is provided as
wrapper functions. Replace `send` with `tracedSend`:

```haskell
import Gogol
import OpenTelemetry.Instrumentation.Gogol (tracedSend)
import OpenTelemetry.Trace (withTracerProvider, getTracer, tracerOptions)

main :: IO ()
main = withTracerProvider $ \tp -> do
  let tracer = getTracer tp "my-service" tracerOptions
  env <- newEnv
  runResourceT . runGoogle env $ do
    result <- tracedSend tracer send (newObjectsGet bucket object)
    ...
```

## Attributes

| Attribute | Example |
|---|---|
| `rpc.system` | `gcp-api` |
| `rpc.service` | `storage` |
| `rpc.method` | `ObjectsGet` |
| `server.address` | `storage.googleapis.com` |
| `cloud.provider` | `gcp` |

## GHC Compatibility

Requires GHC 9.10+ (`gogol-core` is only available in LTS 24+ / nightly).
