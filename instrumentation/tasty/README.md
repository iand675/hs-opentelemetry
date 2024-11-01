# hs-opentelemetry-instrumentation-tasty

OpenTelemetry instrumentation library for Tasty.
It creates spans for:

1. Individual test cases
2. Test groups
3. Resource setup and teardown

The library should be robust to tests running in parallel.

## Usage

Usage requires:

1. Setting and tearing down a trace provider as normal in your test executable.
2. Calling `instrumentTestTree` on your `TestTree`.

See the test suite for examples of how to use the library. 
