# hs-opentelemetry-instrumentation-gogol

OpenTelemetry instrumentation for the [Gogol](https://hackage.haskell.org/package/gogol) Google Cloud SDK.

## Usage

Gogol does not have a hooks/middleware API, so instrumentation is provided as
wrapper functions. Replace `send` with `tracedSend` (or `sendEither` with
`tracedSendEither`):

```haskell
import Gogol
import OpenTelemetry.Instrumentation.Gogol (tracedSend)

main :: IO ()
main = do
  tracer <- ...
  env <- newEnv
  runResourceT . runGoogle env $ do
    -- Instead of: send (newObjectsGet bucket object)
    result <- tracedSend tracer send (newObjectsGet bucket object)
    ...
```

## Attributes

Each span includes:

| Attribute            | Example           |
|----------------------|-------------------|
| `rpc.system`         | `gcp-api`         |
| `rpc.service`        | `storage`         |
| `rpc.method`         | `ObjectsGet`      |
| `server.address`     | `storage.googleapis.com` |
| `cloud.provider`     | `gcp`             |
| `error.type`         | (on failure)      |
| `http.response.status_code` | (on failure) |

## Design

Because Gogol runs in a `Google` monad (essentially `ReaderT (Env s) (ResourceT IO)`)
without hook points, the wrappers take the `send` function as a parameter. This
avoids depending on the full `gogol` package (only `gogol-core`) and works with
any send-like function.
