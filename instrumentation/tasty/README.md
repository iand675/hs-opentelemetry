# hs-opentelemetry-instrumentation-tasty

[![hs-opentelemetry-instrumentation-tasty](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-tasty?style=flat-square&logo=haskell&label=hs-opentelemetry-instrumentation-tasty&labelColor=5D4F85)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-tasty)

OpenTelemetry instrumentation for the [Tasty] test framework; it creates the following spans inside the instrumented `TestTree`:

1. Individual test cases
2. Test groups
3. Resource setup and teardown

As Tasty executes all tests in parallel, this instrumentation should be robust in the presence of parallel execution.

[Tasty]: https://hackage.haskell.org/package/tasty

## Usage

Usage requires:

1. Setting and tearing down a trace provider as normal in your test executable.
2. Calling `instrumentTestTree` on your `TestTree`.

See the test suite for examples of how to use the library.
