# OpenTelemetry API for Haskell

This package provides an interface for instrumentors to use when instrumenting
a library directly or implementing a wrapper API around an existing project.

The methods in this package can be safely called by libraries or end-user applications regardless of
whether the application has registered an OpenTelemetry SDK configuration or not.
When the OpenTelemetry SDK has not registered a tracer provider with any span processors, there API incurs minimal performance overhead, as most of the core interface performs no-ops.

In order to generate and export telemetry data, you will also need to use the [OpenTelemetry Haskell SDK](https://github.com/iand675/hs-opentelemetry/blob/main/sdk/README.md).

The inspiration of the OpenTelemetry project is to make every library and application observable out of the box by having them call the OpenTelemetry API directly. Until that happens, there is a need for a separate library which can inject this information. A library that enables observability for another library is called an instrumentation library. In the case of Haskell, instrumentation is currently entirely manual.

Visit the [GitHub project](https://github.com/iand675/hs-opentelemetry#readme) for a list of provided instrumentation libraries.

## Install Dependencies

Add `hs-opentelemetry-api` to your `package.yaml` or Cabal file.

### Useful Links
- For more information on OpenTelemetry, visit: <https://opentelemetry.io/>
- For more about the Haskell OpenTelemetry project, visit: <https://github.com/iand675/hs-opentelemetry>
