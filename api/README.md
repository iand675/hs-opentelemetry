# OpenTelemetry API for Haskell

The inspiration of the OpenTelemetry project is to make every library and application observable out of the box by having them call the OpenTelemetry API directly. Until that happens, there is a need for a separate library which can inject this information. A library that enables observability for another library is called an instrumentation library. In the case of Haskell, instrumentation is currently entirely manual.

This package provides everything needed to interact with the OpenTelemetry API.

The methods in this package can be safely called by library or end-user application regardless of
whether the application has registered an OpenTelemetry SDK configuration or not.

In order to generate and export telemetry data, you will also need to use the [OpenTelemetry Haskell SDK](https://github.com/iand675/hs-opentelemetry/sdk).

## Tracing Quick Start

### You Will Need

- An application you wish to instrument
- [OpenTelemetry Haskell SDK](https://github.com/iand675/hs-opentelemetry/sdk)

**Note for library authors:** Only your end users will need an OpenTelemetry SDK. If you wish to support OpenTelemetry in your library, you only need to use the OpenTelemetry API. For more information, please read the [tracing documentation][docs-tracing].

### Install Dependencies

Add `otel-api` to your `package.yaml` or Cabal file.

### Trace Your Code

``` haskell
```

### Useful Links
- For more information on OpenTelemetry, visit: <https://opentelemetry.io/>
- For more about OpenTelemetry Haskell: <https://github.com/iand675/hs-opentelemetry>
