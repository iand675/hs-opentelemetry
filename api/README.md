# OpenTelemetry API for Haskell

The inspiration of the OpenTelemetry project is to make every library and application observable out of the box by having them call the OpenTelemetry API directly. Until that happens, there is a need for a separate library which can inject this information. A library that enables observability for another library is called an instrumentation library. In the case of Haskell, instrumentation is currently entirely manual.

This package provides everything needed to interact with the OpenTelemetry API, either for an instrumentation library or for direct instrumentation.

The methods in this package can be safely called by libraries or end-user applications regardless of
whether the application has registered an OpenTelemetry SDK configuration or not.

In order to generate and export telemetry data, you will also need to use the [OpenTelemetry Haskell SDK](https://github.com/iand675/hs-opentelemetry/blob/main/sdk/README.md).

### Install Dependencies

Add `hs-opentelemetry-api` to your `package.yaml` or Cabal file.

### Useful Links
- For more information on OpenTelemetry, visit: <https://opentelemetry.io/>
- For more about OpenTelemetry Haskell: <https://github.com/iand675/hs-opentelemetry>
