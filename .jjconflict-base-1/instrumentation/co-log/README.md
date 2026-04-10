# hs-opentelemetry-instrumentation-co-log

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-co-log?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-co-log)

Bridges [co-log](https://hackage.haskell.org/package/co-log) to the
OpenTelemetry Logs pipeline. Provides `LogAction` values that forward co-log
messages as OTel log records with automatic trace correlation. Supports both
the standard `Message` type and custom message types via a conversion function.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Create an OTel `LogAction` and use it in your co-log setup:

```haskell
import Colog (LogAction, logMsg)
import OpenTelemetry.Instrumentation.CoLog (mkOTelLogAction)
import OpenTelemetry.Log (withLoggerProvider)

main :: IO ()
main = withLoggerProvider $ \lp -> do
  logAction <- mkOTelLogAction lp
  -- Use logAction wherever your co-log setup expects a LogAction.
  -- Log records are forwarded to the OTel pipeline and
  -- correlated with the active trace context.
  runApp logAction
```
