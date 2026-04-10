# hs-opentelemetry-instrumentation-tasty

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-tasty?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-tasty)

OpenTelemetry instrumentation for the
[Tasty](https://hackage.haskell.org/package/tasty) test framework. Creates
spans for individual test cases, test groups, and resource setup/teardown.
Handles parallel test execution correctly.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

1. Initialize a tracer provider in your test executable.
2. Call `instrumentTestTree` on your `TestTree`.

```haskell
import OpenTelemetry.Instrumentation.Tasty (instrumentTestTree)

main :: IO ()
main = withTracerProvider $ \_ -> do
  defaultMain =<< instrumentTestTree tests
```
