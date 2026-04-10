# hs-opentelemetry-sdk

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-sdk?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-sdk)

The OpenTelemetry SDK for Haskell. This is the package your application entry
point depends on to initialize providers, configure exporters, and set up the
telemetry pipeline. It reads standard `OTEL_*` environment variables for
configuration.

You will also depend on [hs-opentelemetry-api](https://github.com/iand675/hs-opentelemetry/tree/main/api) for the actual
instrumentation calls (`inSpan`, `counterAdd`, etc.).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

### Traces

```haskell
import OpenTelemetry.Trace

main :: IO ()
main = withTracerProvider $ \tp -> do
  let tracer = getTracer tp "my-service" tracerOptions
  inSpan tracer "main" defaultSpanArguments $ do
    putStrLn "Hello, traced world!"
```

`withTracerProvider` reads `OTEL_*` environment variables, initializes the
global tracer provider, and shuts it down on exit (flushing buffered spans).

For more control over initialization:

```haskell
import OpenTelemetry.Trace

main :: IO ()
main = bracket
  initializeGlobalTracerProvider
  (\tp -> shutdownTracerProvider tp Nothing)
  $ \tp -> do
    let tracer = makeTracer tp "my-service" tracerOptions
    -- your application code
```

### Metrics

```haskell
import OpenTelemetry.MeterProvider

mp <- createMeterProvider resource defaultSdkMeterProviderOptions
meter <- getMeter mp "my-service"
counter <- meterCreateCounterInt64 meter "http.requests" "" Nothing defaultAdvisoryParameters
```

Export with a periodic reader (push) or on-demand (pull for Prometheus):

```haskell
import OpenTelemetry.Exporter.OTLP.Metric (otlpMetricExporter)

exporter <- otlpMetricExporter =<< loadExporterEnvironmentVariables
forkPeriodicMetricReader env exporter =<< periodicMetricReaderOptionsFromEnv
```

### Logs

```haskell
import OpenTelemetry.Log

main :: IO ()
main = withLoggerProvider $ \lp -> do
  let logger = makeLogger lp "my-app"
  emitLogRecord logger $ emptyLogRecordArguments
    { body = Just (toValue ("started" :: Text))
    , severityNumber = Just SeverityNumberInfo
    }
```

## Configuration

The SDK is configured primarily through environment variables. Key variables:

| Variable | Purpose |
|---|---|
| `OTEL_SERVICE_NAME` | Service name for the resource |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Headers for the OTLP exporter (e.g. API keys) |
| `OTEL_TRACES_SAMPLER` | Sampler to use (`always_on`, `always_off`, `traceidratio`, `parentbased_*`) |
| `OTEL_TRACES_SAMPLER_ARG` | Sampler argument (e.g. ratio for `traceidratio`) |
| `OTEL_SDK_DISABLED` | Disable the SDK entirely |

See the [OpenTelemetry environment variable spec](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/) for the full list.

## Install

Add `hs-opentelemetry-sdk` to your `.cabal` file or `package.yaml`.
