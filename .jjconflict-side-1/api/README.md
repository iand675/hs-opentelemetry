# hs-opentelemetry-api

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-api?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-api)

Types and interfaces for instrumenting Haskell libraries and applications with
OpenTelemetry. Provides `inSpan`, `counterAdd`, `histogramRecord`,
`emitLogRecord`, and the rest of the instrumentation surface.

Both library authors and application authors depend on this package. Library
authors use it so their users aren't forced into a particular SDK configuration.
Application authors use it alongside the
[SDK](https://github.com/iand675/hs-opentelemetry/tree/main/sdk) for the
actual instrumentation calls.

When no SDK is configured, all operations are no-ops with minimal overhead
(~13.6 ns per `inSpan` call).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

### Traces

```haskell
import OpenTelemetry.Trace.Core

handleRequest :: Tracer -> Request -> IO Response
handleRequest tracer req =
  inSpan tracer "handleRequest" defaultSpanArguments $ do
    processRequest req
```

Use `inSpan'` when you need the `Span` handle to attach attributes:

```haskell
inSpan' tracer "fetchUser" defaultSpanArguments $ \span -> do
  user <- lookupUser uid
  addAttribute span "user.id" (toAttribute uid)
  pure user
```

### Metrics

```haskell
import OpenTelemetry.Metric.Core

counter <- meterCreateCounterInt64 meter
  "http.requests" "" Nothing defaultAdvisoryParameters

counterAdd counter 1 [("method", toAttribute ("GET" :: Text))]
```

### Logs

```haskell
import OpenTelemetry.Log.Core

emitLogRecord logger $ emptyLogRecordArguments
  { body = Just (toValue ("request handled" :: Text))
  , severityNumber = Just SeverityNumberInfo
  }
```

## Install

Add `hs-opentelemetry-api` to your `.cabal` file or `package.yaml`.
