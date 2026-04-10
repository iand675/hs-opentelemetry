# hs-opentelemetry-instrumentation-katip

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-katip?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-katip)

Bridges [Katip](https://hackage.haskell.org/package/katip) structured logging
to the OpenTelemetry Logs pipeline. Provides a `Scribe` that forwards log items
as OTel log records with automatic trace correlation. Katip's structured
payloads (namespaces, JSON context, source locations) are preserved as log
record attributes.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Create an OTel scribe and register it with your Katip `LogEnv`:

```haskell
import Katip
import OpenTelemetry.Instrumentation.Katip (mkOTelScribe)
import OpenTelemetry.Log (withLoggerProvider)

main :: IO ()
main = withLoggerProvider $ \lp -> do
  scribe <- mkOTelScribe lp defaultScribeSettings
  le <- registerScribe "otel" scribe defaultScribeSettings
    =<< initLogEnv "my-app" "production"
  runKatipT le $ do
    logMsg "app" InfoS "Application started"
    -- Log records are forwarded to the OTel pipeline
    -- and correlated with the active trace context
```
