# hs-opentelemetry-instrumentation-monad-logger

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-monad-logger?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-monad-logger)

Bridges [monad-logger](https://hackage.haskell.org/package/monad-logger) to the
OpenTelemetry Logs pipeline. Provides a logging callback for `runLoggingT` that
forwards messages as OTel log records with automatic trace correlation and
source location attributes.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Create an OTel callback and pass it to `runLoggingT`:

```haskell
import Control.Monad.Logger (runLoggingT, logInfoN)
import OpenTelemetry.Instrumentation.MonadLogger (mkOTelLogCallback)
import OpenTelemetry.Log (withLoggerProvider)

main :: IO ()
main = withLoggerProvider $ \lp -> do
  callback <- mkOTelLogCallback lp
  runLoggingT myApp callback
  where
    myApp = do
      logInfoN "Application started"
      -- Log records are forwarded to the OTel pipeline
      -- and correlated with the active trace context.
```
