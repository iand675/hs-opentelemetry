# hs-opentelemetry-instrumentation-hspec

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-hspec?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-hspec)

OpenTelemetry instrumentation for
[Hspec](https://hspec.github.io/) test suites. Creates a span for each test
case so you can trace test execution alongside your application spans.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

```haskell
import OpenTelemetry.Instrumentation.Hspec (wrapHspec)

main :: IO ()
main = withTracerProvider $ \_ ->
  wrapHspec $ hspec spec
```

See [examples/hspec](https://github.com/iand675/hs-opentelemetry/tree/main/examples/hspec) for a working example.
