# hs-opentelemetry-utils-exceptions

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-utils-exceptions?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-utils-exceptions)

`MonadMask`-based span wrappers for transformer stacks that don't have
`MonadUnliftIO`. Provides `inSpanM`, `inSpanM'`, and `inSpanM''` as
alternatives to the `inSpan` family from the API package.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

```haskell
import OpenTelemetry.Utils.Exceptions (inSpanM)

-- Works in any (MonadIO m, MonadMask m) stack, not just MonadUnliftIO
handleRequest :: Tracer -> Request -> MyMonad Response
handleRequest tracer req =
  inSpanM tracer "handleRequest" defaultSpanArguments $ do
    processRequest req
```

Use `inSpanM'` when you need the `Span` handle to attach attributes.

See [yesodweb/yesod#1533](https://github.com/yesodweb/yesod/issues/1533) for
background on subtle issues with `MonadMask` and resource cleanup.
