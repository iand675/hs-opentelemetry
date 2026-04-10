# hs-opentelemetry-instrumentation-yesod

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-yesod?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-yesod)

OpenTelemetry instrumentation for [Yesod](https://www.yesodweb.com/) web
applications. Provides a `YesodMiddleware` that creates spans per request with
route-aware span names.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

```haskell
import OpenTelemetry.Instrumentation.Yesod (openTelemetryYesodMiddleware)

instance Yesod App where
  yesodMiddleware = openTelemetryYesodMiddleware . defaultYesodMiddleware
```

For a complete example, see [examples/yesod-minimal](https://github.com/iand675/hs-opentelemetry/tree/main/examples/yesod-minimal).
