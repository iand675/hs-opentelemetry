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
| IsValid (both TraceId AND SpanId non-zero)                                                       |          | +  |
| IsRemote                                                                                         |          | +  |
| Conforms to the W3C TraceContext spec                                                            |          | (partial)  |
| [TraceState](specification/trace/api.md#tracestate) get/add/update/delete                        |          | +  |
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
| [Tracer.Enabled](specification/trace/api.md#enabled)                                             | X        | +  |
| [SpanExporter ForceFlush](specification/trace/sdk.md#forceflush-2)                               |          | +  |
| [Attribute Limits](specification/common/common.md#attribute-limits)                              | X        | +  |

## Baggage

| Feature                            | Optional | Haskell |
|------------------------------------|----------|----|
| Basic support                      |          | +  |
| Use official header name `baggage` |          | +  |

## Metrics

|Feature                                       |Optional| Haskell |
|----------------------------------------------|--------|--|
| [MeterProvider](specification/metrics/api.md#meterprovider) — Get a Meter | | + |
| [Meter](specification/metrics/api.md#meter) — create instruments | | + |
| [Counter / UpDownCounter / Histogram / Gauge](specification/metrics/api.md#instrument) (sync) | | + |
| [Observable instruments](specification/metrics/api.md#asynchronous-instrument-api) | | + (callbacks at creation + register) |
| [Enabled](specification/metrics/api.md#enabled) (sync) | | + |
| [Enabled](specification/metrics/api.md#enabled) (async) | | + |
| Global default MeterProvider | | + |
| [Metrics SDK](specification/metrics/sdk.md) — aggregations (sum, explicit + exponential histogram, gauge) | | + |
| Histogram min/max tracking | | + |
| Default histogram bounds per spec (includes 750, 7500) | | + |
| Views (drop, aggregation, attribute keys, name, description) | | + |
| View selector: name (wildcard), kind, unit, meter_name, meter_version, meter_schema_url | | + |
| Advisory Attributes parameter fallback for attribute_keys | | + |
| Exemplars (trace context + OTLP + Prometheus text) | | + |
| ExemplarFilter: TraceBased (default), AlwaysOn, AlwaysOff | | + |
| OTEL_METRICS_EXEMPLAR_FILTER wired into SDK | | + |
| Cardinality limits (per instrument) | | + |
| Cardinality overflow attribute (otel.metric.overflow=true) | | + |
| Periodic metric reader (SDK helper) | | + |
| Delta / cumulative temporality (export) | | + |
| startTimeUnixNano on data points | | + |
| ForceFlush (triggers metric collect) | | + |
| View name/description override | | + |
| In-memory metric exporter (testing) | | + |
| Console metric exporter | | + |
| Exporter selection (OTEL_METRICS_EXPORTER wiring) | | + |
| Instrument name case-insensitive matching | | + |
| NaN/Inf measurement handling (silently dropped) | | + |

See `OpenTelemetry.Metrics`, `OpenTelemetry.MeterProvider`, `OpenTelemetry.Metrics.View`, `OpenTelemetry.MetricReader` (SDK), `OpenTelemetry.Exporter.Metric`, `OpenTelemetry.Exporter.OTLP.Metric`, `OpenTelemetry.Exporter.Prometheus`.

## Logs

| Feature                                                                         | Optional | Haskell |
|---------------------------------------------------------------------------------|----------|---------|
| [LoggerProvider](specification/logs/api.md#loggerprovider)                      |          | +       |
| Get a Logger (name, version, schema_url, attributes)                            |          | +       |
| [Logger.Enabled](specification/logs/api.md#enabled)                             | X        | +       |
| [Emit LogRecord](specification/logs/api.md#emit-a-logrecord)                    |          | +       |
| LogRecord: timestamp, observed timestamp, severity, body, attributes            |          | +       |
| LogRecord: EventName                                                            |          | +       |
| LogRecord: trace context fields (TraceId, SpanId, TraceFlags)                   |          | +       |
| Shutdown / ForceFlush (LoggerProvider)                                           |          | +       |
| [LogRecordProcessor](specification/logs/sdk.md#logrecordprocessor) interface     |          | +       |
| Built-in Simple processor                                                       |          | - (stub) |
| Built-in Batch processor                                                        |          | - (stub) |
| [LogRecordExporter](specification/logs/sdk.md#logrecordexporter) interface       |          | +       |
| Concrete OTLP log exporter                                                      |          | - (stub) |
| Concrete handle/console log exporter                                            |          | - (stub) |
| Concrete in-memory log exporter (testing)                                       |          | - (stub) |

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
|OTEL_METRICS_EXPORTER                         | + |
|OTEL_METRIC_EXPORT_INTERVAL                   | + |
|OTEL_METRICS_EXEMPLAR_FILTER                  | + |
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
| Standard output (logging)                                                      |          | + (metrics only) |
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
