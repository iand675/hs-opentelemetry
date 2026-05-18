# hs-opentelemetry-instrumentation-hspec

[![hs-opentelemetry-instrumentation-hspec](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-hspec?style=flat-square&logo=haskell&label=hs-opentelemetry-instrumentation-hspec&labelColor=5D4F85)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-hspec)

OpenTelemetry instrumentation for the [Hspec] test framework; it creates one span per test case inside the instrumented `Spec` tree.

[Hspec]: https://hackage.haskell.org/package/hspec

## Usage

```haskell
do
  provider <- getGlobalTracerProvider
  let tracer = OpenTelemetry.Trace.makeTracer provider "my-test-suite" OpenTelemtry.Trace.tracerOptions
  context <- OpenTelemetry.Context.ThreadLocal.getContext

  hspec $ instrumentSpec tracer context $ do
    describe "Spec" do
      it "is instrumented with OpenTelemetry" do
        True `shouldBe` True
```

See [examples/hspec](../../examples/hspec) for an instrumented test suite.
