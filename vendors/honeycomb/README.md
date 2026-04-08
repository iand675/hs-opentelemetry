# Honeycomb Utilities

[![hs-opentelemetry-vendor-honeycomb](https://img.shields.io/hackage/v/hs-opentelemetry-vendor-honeycomb?style=flat-square&logo=haskell&label=hs-opentelemetry-vendor-honeycomb&labelColor=5D4F85)](https://hackage.haskell.org/package/hs-opentelemetry-vendor-honeycomb)

Utilities for deriving Honeycomb-specific constructs from OpenTelemetry instrumentation.

For example, the following will print the URL for the Honeycomb trace visualization associated with the current span:

```haskell
do
  config <- getConfigPartsFromEnv >>= \case
    Nothing -> throwIO $ userError "invalid Honeycomb config"
    Just (teamWriteKey, datasetName) -> pure $ HoneyComb.config teamWriteKey datasetName
  provider <- getGlobalTracerProvider
  target <- resolveHoneycombTarget provider config

  timestamp <- Data.Time.Clock.getCurrentTime

  context <- OpenTelemetry.Context.ThreadLocal.lookupContext >>= \case
    Nothing -> throwIO $ userError "no trace context available"
    Just context -> pure context
  spanContext <- OpenTelemetry.Context.lookupSpan >>= \case
    Nothing -> throwIO $ userError "no span in trace context"
    Just span -> getSpanContext span

  print $ makeDirectTraceLink target timestamp spanContext.traceId
```
