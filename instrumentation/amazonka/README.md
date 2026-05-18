# hs-opentelemetry-instrumentation-amazonka

OpenTelemetry instrumentation for the [Amazonka](https://hackage.haskell.org/package/amazonka) AWS SDK.

## GHC Compatibility

This package requires `amazonka >= 2.0`. As of April 2026, the published
`amazonka-2.0` on Hackage does not compile with GHC 9.10+ due to
`DuplicateRecordFields` changes in generated service packages (`amazonka-sts`,
`amazonka-sso`). You may need to use amazonka from its GitHub `main` branch
or wait for the next Hackage release.

## Usage

```haskell
import Amazonka
import OpenTelemetry.Instrumentation.Amazonka (instrumentEnv)
import OpenTelemetry.Trace (getTracerProvider, makeTracer, tracerOptions)

main :: IO ()
main = do
  tp <- getTracerProvider
  let tracer = makeTracer tp "my-app" tracerOptions
  env <- newEnv discover
  let tracedEnv = instrumentEnv tracer env
  -- All send calls through tracedEnv will create OTel spans
  runResourceT $ send tracedEnv someRequest
```

## Attributes

Per the [OTel AWS SDK semantic conventions](https://opentelemetry.io/docs/specs/semconv/cloud-providers/aws-sdk/):

| Attribute | Description |
|-----------|-------------|
| `rpc.system` | Always `"aws-api"` |
| `rpc.service` | AWS service abbreviation (e.g., `"S3"`, `"DynamoDB"`) |
| `rpc.method` | AWS operation name (e.g., `"GetObject"`, `"PutItem"`) |
| `aws.request_id` | From response headers when available |
| `http.response.status_code` | HTTP status code |
| `server.address` | AWS endpoint host |
| `cloud.region` | AWS region |
