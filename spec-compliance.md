# Compliance of Implementations with Specification

The following tables show which features are implemented by the Haskell OpenTelemetry
implementation.

`+` means the feature is supported, `-` means it is not supported, `N/A` means
the feature is not applicable to the particular language, blank cell means the
status of the feature is not known.

For the `Optional` column, `X` means the feature is optional, blank means the
feature is required, and columns marked with `*` mean that for each type of
exporter (OTLP, Zipkin, and Jaeger), implementing at least one of the supported
formats is required. Implementing more than one format is optional.

## Traces

| Feature                                                                                          | Optional | Haskell |
|--------------------------------------------------------------------------------------------------|----------|----|
| [TracerProvider](specification/trace/api.md#tracerprovider-operations)                           |          | +  |
| Create TracerProvider                                                                            |          | +  |
| Get a Tracer                                                                                     |          | +  |
| Get a Tracer with schema_url                                                                     |          | (partial)  |
| Safe for concurrent calls                                                                        |          | +  |
| Shutdown (SDK only required)                                                                     |          | +  |
| ForceFlush (SDK only required)                                                                   |          | +  |
| [Trace / Context interaction](specification/trace/api.md#context-interaction)                    |          | +  |
| Get active Span                                                                                  |          | +  |
| Set active Span                                                                                  |          | +  |
| [Tracer](specification/trace/api.md#tracer-operations)                                           |          | +  |
| Create a new Span                                                                                |          | +  |
| Get active Span                                                                                  |          | +  |
| Mark Span active                                                                                 |          | +  |
| Safe for concurrent calls                                                                        |          | +  |
| [SpanContext](specification/trace/api.md#spancontext)                                            |          | +  |
| IsValid                                                                                          |          | +  |
| IsRemote                                                                                         |          | +  |
| Conforms to the W3C TraceContext spec                                                            |          | (partial)  |
| [Span](specification/trace/api.md#span)                                                          |          | +  |
| Create root span                                                                                 |          | +  |
| Create with default parent (active span)                                                         |          | +  |
| Create with parent from Context                                                                  |          | +  |
| No explicit parent Span/SpanContext allowed                                                      |          | +  |
| Processor.OnStart receives parent Context                                                        |          | +  |
| UpdateName                                                                                       |          | +  |
| User-defined start timestamp                                                                     |          | +  |
| End                                                                                              |          | +  |
| End with timestamp                                                                               |          | +  |
| IsRecording                                                                                      |          | +  |
| IsRecording becomes false after End                                                              |          | +  |
| Set status with StatusCode (Unset, Ok, Error)                                                    |          | +  |
| Safe for concurrent calls                                                                        |          | +  |
| events collection size limit                                                                     |          | +  |
| attribute collection size limit                                                                  |          | +  |
| links collection size limit                                                                      |          | +  |
| [Span attributes](specification/trace/api.md#set-attributes)                                     |          | +  |
| SetAttribute                                                                                     |          | +  |
| Set order preserved                                                                              | X        |    |
| String type                                                                                      |          | +  |
| Boolean type                                                                                     |          | +  |
| Double floating-point type                                                                       |          | +  |
| Signed int64 type                                                                                |          | +  |
| Array of primitives (homogeneous)                                                                |          | +  |
| `null` values documented as invalid/undefined                                                    |          | N/A |
| Unicode support for keys and string values                                                       |          | +  |
| [Span linking](specification/trace/api.md#specifying-links)                                      |          | +  |
| Links can be recorded on span creation                                                           |          | +  |
| Links order is preserved                                                                         |          | +  |
| [Span events](specification/trace/api.md#add-events)                                             |          | +  |
| AddEvent                                                                                         |          | +  |
| Add order preserved                                                                              |          | +  |
| Safe for concurrent calls                                                                        |          | +  |
| [Span exceptions](specification/trace/api.md#record-exception)                                   |          | +  |
| RecordException                                                                                  |          | +  |
| RecordException with extra parameters                                                            |          | +  |
| [Sampling](specification/trace/sdk.md#sampling)                                                  |          | +  |
| Allow samplers to modify tracestate                                                              |          | +  |
| ShouldSample gets full parent Context                                                            |          | +  |
| ShouldSample gets InstrumentationLibrary                                                         |          | +  |
| [New Span ID created also for non-recording Spans](specification/trace/sdk.md#sdk-span-creation) |          | +  |
| [IdGenerators](specification/trace/sdk.md#id-generators)                                         |          | +  |
| [SpanLimits](specification/trace/sdk.md#span-limits)                                             | X        | +  |
| [Built-in `Processor`s implement `ForceFlush` spec](specification/trace/sdk.md#forceflush-1)     |          | +  |
| [Attribute Limits](specification/common/common.md#attribute-limits)                              | X        | +  |

## Baggage

| Feature                            | Optional | Haskell |
|------------------------------------|----------|----|
| Basic support                      |          | +  |
| Use official header name `baggage` |          | +  |

## Metrics

|Feature                                       |Optional| Haskell |
|----------------------------------------------|--------|--|
|TBD|

## Resource

| Feature                                                                                                                                     | Optional | Haskell |
|---------------------------------------------------------------------------------------------------------------------------------------------|----------|----|
| Create from Attributes                                                                                                                      |          | +  |
| Create empty                                                                                                                                |          | +  |
| [Merge (v2)](specification/resource/sdk.md#merge)                                                                                           |          | ?  |
| Retrieve attributes                                                                                                                         |          | +  |
| [Default value](specification/resource/semantic_conventions/README.md#semantic-attributes-with-sdk-provided-default-value) for service.name |          | +  |

## Context Propagation

| Feature                                                                          | Optional | Haskell |
|----------------------------------------------------------------------------------|----------|----|
| Create Context Key                                                               |          | +  |
| Get value from Context                                                           |          | +  |
| Set value for Context                                                            |          | +  |
| Attach Context                                                                   |          | +  |
| Detach Context                                                                   |          | +  |
| Get current Context                                                              |          | +  |
| Composite Propagator                                                             |          | + (monoid instance) |
| Global Propagator                                                                |          | +  |
| TraceContext Propagator                                                          |          | (partial support) |
| B3 Propagator                                                                    |          |    |
| Jaeger Propagator                                                                |          |    |
| [TextMapPropagator](specification/context/api-propagators.md#textmap-propagator) |          | +  |
| Fields                                                                           |          |    |
| Setter argument                                                                  | X        |    |
| Getter argument                                                                  | X        |    |
| Getter argument returning Keys                                                   | X        |    |

## Environment Variables

Note: Support for environment variables is optional.

|Feature                                       | Haskell |
|----------------------------------------------|---|
|OTEL_SDK_DISABLED                             | + |
|OTEL_RESOURCE_ATTRIBUTES                      | + |
|OTEL_SERVICE_NAME                             | + |
|OTEL_LOG_LEVEL                                |   |
|OTEL_PROPAGATORS                              | + |
|OTEL_BSP_*                                    | + |
|OTEL_EXPORTER_OTLP_*                          | (partial support) |
|OTEL_EXPORTER_JAEGER_*                        |   |
|OTEL_EXPORTER_ZIPKIN_*                        |   |
|OTEL_TRACES_EXPORTER                          | (partial support) |
|OTEL_METRICS_EXPORTER                         |   |
|OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT               | + |
|OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT        | + |
|OTEL_SPAN_EVENT_COUNT_LIMIT                   | + |
|OTEL_SPAN_LINK_COUNT_LIMIT                    | + |
|OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT              | + |
|OTEL_LINK_ATTRIBUTE_COUNT_LIMIT               | + |
|OTEL_TRACES_SAMPLER                           | + |
|OTEL_TRACES_SAMPLER_ARG                       | + |
|OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT             | + |
|OTEL_ATTRIBUTE_COUNT_LIMIT                    | + |

## Exporters

| Feature                                                                        | Optional | Haskell |
|--------------------------------------------------------------------------------|----------|----|
| [Exporter interface](specification/trace/sdk.md#span-exporter)                 |          | +  |
| [Exporter interface has `ForceFlush`](specification/trace/sdk.md#forceflush-2) |          | +  |
| Standard output (logging)                                                      |          |    |
| In-memory (mock exporter)                                                      |          | +  |
| [OTLP](specification/protocol/otlp.md)                                         |          | +  |
| OTLP/gRPC Exporter                                                             | *        |    |
| OTLP/HTTP binary Protobuf Exporter                                             | *        | +  |
| OTLP/HTTP JSON Protobuf Exporter                                               |          |    |
| OTLP/HTTP gzip Content-Encoding support                                        | X        | +  |
| Concurrent sending                                                             |          |    |
| Honors retryable responses with backoff                                        | X        | +  |
| Honors non-retryable responses                                                 | X        | +  |
| Honors throttling response                                                     | X        | (partial support) |
| Multi-destination spec compliance                                              | X        |    |
| [Zipkin](specification/trace/sdk_exporters/zipkin.md)                          |          |    |
| Zipkin V1 JSON                                                                 | X        |    |
| Zipkin V1 Thrift                                                               | X        |    |
| Zipkin V2 JSON                                                                 | *        |    |
| Zipkin V2 Protobuf                                                             | *        |    |
| Service name mapping                                                           |          |    |
| SpanKind mapping                                                               |          |    |
| InstrumentationLibrary mapping                                                 |          |    |
| Boolean attributes                                                             |          |    |
| Array attributes                                                               |          |    |
| Status mapping                                                                 |          |    |
| Error Status mapping                                                           |          |    |
| Event attributes mapping to Annotations                                        |          |    |
| Integer microseconds in timestamps                                             |          |    |
| [Jaeger](specification/trace/sdk_exporters/jaeger.md)                          |          |    |
| Jaeger Thrift over UDP                                                         | *        |    |
| Jaeger Protobuf via gRPC                                                       | *        |    |
| Jaeger Thrift over HTTP                                                        | *        |    |
| Service name mapping                                                           |          |    |
| Resource to Process mapping                                                    |          |    |
| InstrumentationLibrary mapping                                                 |          |    |
| Status mapping                                                                 |          |    |
| Error Status mapping                                                           |          |    |
| Events converted to Logs                                                       |          |    |
| OpenCensus                                                                     |          |    |
| TBD                                                                            |          |    |
| Prometheus                                                                     |          |    |
| TBD                                                                            |          |    |
