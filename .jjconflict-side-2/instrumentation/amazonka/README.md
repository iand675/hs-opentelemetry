# hs-opentelemetry-instrumentation-amazonka

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-amazonka?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-amazonka)

OpenTelemetry instrumentation for the
[Amazonka](https://hackage.haskell.org/package/amazonka) AWS SDK. Creates a
span per AWS API call with attributes following the
[OTel AWS SDK semantic conventions](https://opentelemetry.io/docs/specs/semconv/cloud-providers/aws-sdk/).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Instrument your Amazonka `Env` after initializing the SDK:

```haskell
import Amazonka
import OpenTelemetry.Instrumentation.Amazonka (instrumentEnv)
import OpenTelemetry.Trace (withTracerProvider, getTracer, tracerOptions)

main :: IO ()
main = withTracerProvider $ \tp -> do
  let tracer = getTracer tp "my-service" tracerOptions
  env <- newEnv discover
  let tracedEnv = instrumentEnv tracer env
  -- All send calls through tracedEnv produce OTel spans
  runResourceT $ send tracedEnv someRequest
```

## Attributes

| Attribute | Example |
|---|---|
| `rpc.system` | `aws-api` |
| `rpc.service` | `S3`, `DynamoDB` |
| `rpc.method` | `GetObject`, `PutItem` |
| `aws.request_id` | (from response headers) |
| `http.response.status_code` | `200` |
| `server.address` | endpoint host |
| `cloud.region` | `us-east-1` |

## GHC Compatibility

Requires `amazonka >= 2.0`. The published `amazonka-2.0` on Hackage may not
compile with GHC 9.10+ due to `DuplicateRecordFields` changes in generated
service packages. You may need amazonka from its GitHub `main` branch.
