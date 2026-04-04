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

| Feature                                                                                                                         | Optional | Haskell |
|---------------------------------------------------------------------------------------------------------------------------------|----------|----|
| [TracerProvider](https://opentelemetry.io/docs/specs/otel/trace/api/#tracerprovider-operations)                                |          | +  |
| Create TracerProvider                                                                                                           |          | +  |
| Get a Tracer                                                                                                                    |          | +  |
| Get a Tracer with schema_url                                                                                                    |          | +  |
| Safe for concurrent calls                                                                                                       |          | +  |
| [Shutdown](https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown) (SDK only required)                                   |          | +  |
| [ForceFlush](https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflush) (SDK only required)                               |          | +  |
| [Trace / Context interaction](https://opentelemetry.io/docs/specs/otel/trace/api/#context-interaction)                         |          | +  |
| Get active Span                                                                                                                 |          | +  |
| Set active Span                                                                                                                 |          | +  |
| [Tracer](https://opentelemetry.io/docs/specs/otel/trace/api/#tracer-operations)                                                |          | +  |
| Create a new Span                                                                                                               |          | +  |
| Get active Span                                                                                                                 |          | +  |
| Mark Span active                                                                                                                |          | +  |
| Safe for concurrent calls                                                                                                       |          | +  |
| [SpanContext](https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext)                                                 |          | +  |
| IsValid (both TraceId AND SpanId non-zero)                                                                                      |          | +  |
| IsRemote                                                                                                                        |          | +  |
| Conforms to the W3C TraceContext spec                                                                                           |          | +  |
| [TraceState](https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate) get/add/update/delete                             |          | +  |
| [Span](https://opentelemetry.io/docs/specs/otel/trace/api/#span)                                                               |          | +  |
| Create root span                                                                                                                |          | +  |
| Create with default parent (active span)                                                                                        |          | +  |
| Create with parent from Context                                                                                                 |          | +  |
| No explicit parent Span/SpanContext allowed                                                                                     |          | +  |
| [Processor.OnStart receives parent Context](https://opentelemetry.io/docs/specs/otel/trace/sdk/#onstart)                       |          | +  |
| [UpdateName](https://opentelemetry.io/docs/specs/otel/trace/api/#updatename)                                                   |          | +  |
| User-defined start timestamp                                                                                                    |          | +  |
| [End](https://opentelemetry.io/docs/specs/otel/trace/api/#end)                                                                 |          | +  |
| End with timestamp                                                                                                              |          | +  |
| [IsRecording](https://opentelemetry.io/docs/specs/otel/trace/api/#isrecording)                                                 |          | +  |
| IsRecording becomes false after End                                                                                             |          | +  |
| [Set status with StatusCode](https://opentelemetry.io/docs/specs/otel/trace/api/#set-status) (Unset, Ok, Error)                |          | +  |
| Safe for concurrent calls                                                                                                       |          | +  |
| [events collection size limit](https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits)                                |          | +  |
| [attribute collection size limit](https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits)                             |          | +  |
| [links collection size limit](https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits)                                 |          | +  |
| [Span attributes](https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes)                                          |          | +  |
| SetAttribute                                                                                                                    |          | +  |
| Set order preserved                                                                                                             | X        |    |
| String type                                                                                                                     |          | +  |
| Boolean type                                                                                                                    |          | +  |
| Double floating-point type                                                                                                      |          | +  |
| Signed int64 type                                                                                                               |          | +  |
| Array of primitives (homogeneous)                                                                                               |          | +  |
| `null` values documented as invalid/undefined                                                                                   |          | N/A |
| Unicode support for keys and string values                                                                                      |          | +  |
| [Span linking](https://opentelemetry.io/docs/specs/otel/trace/api/#specifying-links)                                           |          | +  |
| Links can be recorded on span creation                                                                                          |          | +  |
| Links order is preserved                                                                                                        |          | +  |
| [Span events](https://opentelemetry.io/docs/specs/otel/trace/api/#add-events)                                                  |          | +  |
| AddEvent                                                                                                                        |          | +  |
| Add order preserved                                                                                                             |          | +  |
| Safe for concurrent calls                                                                                                       |          | +  |
| [Span exceptions](https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception)                                        |          | +  |
| RecordException                                                                                                                 |          | +  |
| RecordException with extra parameters                                                                                           |          | +  |
| [Sampling](https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling)                                                       |          | +  |
| AlwaysRecord sampler (decorator: DROP→RECORD_ONLY)                                                                              | X        | +  |
| Allow samplers to modify tracestate                                                                                             |          | +  |
| ShouldSample gets full parent Context                                                                                           |          | +  |
| ShouldSample gets InstrumentationLibrary                                                                                        |          | +  |
| [New Span ID created also for non-recording Spans](https://opentelemetry.io/docs/specs/otel/trace/sdk/#sdk-span-creation)      |          | +  |
| [IdGenerators](https://opentelemetry.io/docs/specs/otel/trace/sdk/#id-generators)                                              |          | +  |
| [SpanLimits](https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits)                                                  | X        | +  |
| [Built-in `Processor`s implement `ForceFlush` spec](https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflush-1)          |          | +  |
| [Tracer.Enabled](https://opentelemetry.io/docs/specs/otel/trace/api/#enabled)                                                  | X        | +  |
| [SpanExporter ForceFlush](https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflush-2)                                    |          | +  |
| [Attribute Limits](https://opentelemetry.io/docs/specs/otel/common/#attribute-limits)                                          | X        | +  |

## Baggage

| Feature                                                                                           | Optional | Haskell |
|---------------------------------------------------------------------------------------------------|----------|----|
| [Basic support](https://opentelemetry.io/docs/specs/otel/baggage/api/)                           |          | +  |
| Use official header name `baggage`                                                                |          | +  |

## Metrics

| Feature                                                                                                                            | Optional | Haskell |
|------------------------------------------------------------------------------------------------------------------------------------|----------|--|
| [MeterProvider](https://opentelemetry.io/docs/specs/otel/metrics/api/#meterprovider) — Get a Meter                                |          | + |
| [Meter](https://opentelemetry.io/docs/specs/otel/metrics/api/#meter) — create instruments                                         |          | + |
| [Counter / UpDownCounter / Histogram / Gauge](https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument) (sync)             |          | + |
| [Observable instruments](https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-instrument-api)                        |          | + (callbacks at creation + register) |
| [Enabled](https://opentelemetry.io/docs/specs/otel/metrics/api/#enabled) (sync)                                                   |          | + |
| [Enabled](https://opentelemetry.io/docs/specs/otel/metrics/api/#enabled) (async)                                                  |          | + |
| Global default MeterProvider                                                                                                       |          | + |
| [Metrics SDK](https://opentelemetry.io/docs/specs/otel/metrics/sdk/) — aggregations (sum, explicit + exponential histogram, gauge) |          | + |
| Histogram min/max tracking                                                                                                         |          | + |
| Default histogram bounds per spec (includes 750, 7500)                                                                             |          | + |
| [Views](https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view) (drop, aggregation, attribute keys, name, description)         |          | + |
| View selector: name (wildcard), kind, unit, meter_name, meter_version, meter_schema_url                                            |          | + |
| Advisory Attributes parameter fallback for attribute_keys                                                                           |          | + |
| [Exemplars](https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplar) (trace context + OTLP + Prometheus text)               |          | + |
| [ExemplarFilter](https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplarfilter): TraceBased (default), AlwaysOn, AlwaysOff  |          | + |
| OTEL_METRICS_EXEMPLAR_FILTER wired into SDK                                                                                        |          | + |
| Cardinality limits (per instrument)                                                                                                 |          | + |
| Cardinality overflow attribute (otel.metric.overflow=true)                                                                          |          | + |
| [Periodic metric reader](https://opentelemetry.io/docs/specs/otel/metrics/sdk/#periodic-exporting-metricreader) (SDK helper)        |          | + |
| Delta / cumulative temporality (export)                                                                                             |          | + |
| startTimeUnixNano on data points                                                                                                    |          | + |
| ForceFlush (triggers metric collect)                                                                                                |          | + |
| View name/description override                                                                                                      |          | + |
| In-memory metric exporter (testing)                                                                                                 |          | + |
| Console metric exporter                                                                                                             |          | + |
| Exporter selection (OTEL_METRICS_EXPORTER wiring)                                                                                   |          | + |
| Instrument name case-insensitive matching                                                                                           |          | + |
| NaN/Inf measurement handling (silently dropped)                                                                                     |          | + |

See `OpenTelemetry.Metrics`, `OpenTelemetry.MeterProvider`, `OpenTelemetry.Metrics.View`, `OpenTelemetry.MetricReader` (SDK), `OpenTelemetry.Exporter.Metric`, `OpenTelemetry.Exporter.OTLP.Metric`, `OpenTelemetry.Exporter.Prometheus`.

## Logs

| Feature                                                                                                          | Optional | Haskell |
|------------------------------------------------------------------------------------------------------------------|----------|---------|
| [LoggerProvider](https://opentelemetry.io/docs/specs/otel/logs/api/#loggerprovider)                             |          | +       |
| Get a Logger (name, version, schema_url, attributes)                                                             |          | +       |
| [Logger.Enabled](https://opentelemetry.io/docs/specs/otel/logs/api/#enabled)                                    | X        | +       |
| [Emit LogRecord](https://opentelemetry.io/docs/specs/otel/logs/api/#emit-a-logrecord)                           |          | +       |
| LogRecord: timestamp, observed timestamp, severity, body, attributes                                             |          | +       |
| LogRecord: EventName                                                                                             |          | +       |
| LogRecord: trace context fields (TraceId, SpanId, TraceFlags)                                                    |          | +       |
| [Shutdown / ForceFlush](https://opentelemetry.io/docs/specs/otel/logs/sdk/#shutdown) (LoggerProvider)            |          | +       |
| [LogRecordProcessor](https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecordprocessor) interface            |          | +       |
| Built-in [Simple processor](https://opentelemetry.io/docs/specs/otel/logs/sdk/#simple-log-record-processor) (synchronous export in onEmit) | | + |
| Built-in [Batch processor](https://opentelemetry.io/docs/specs/otel/logs/sdk/#batching-log-record-processor)    |          | +       |
| [LogRecordExporter](https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecordexporter) interface              |          | +       |
| Concrete OTLP log exporter                                                                                       |          | +       |
| Concrete handle/console log exporter                                                                             |          | +       |
| Concrete in-memory log exporter (testing)                                                                        |          | +       |

## Resource

| Feature                                                                                                                                                                          | Optional | Haskell |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|----|
| Create from Attributes                                                                                                                                                           |          | +  |
| Create empty                                                                                                                                                                     |          | +  |
| [Merge (v2)](https://opentelemetry.io/docs/specs/otel/resource/sdk/#merge)                                                                                                      |          | +  |
| Retrieve attributes                                                                                                                                                              |          | +  |
| [Default value](https://opentelemetry.io/docs/specs/otel/resource/semantic_conventions/#semantic-attributes-with-sdk-provided-default-value) for service.name                    |          | +  |
| Schema URL on Resource (materialize / export)                                                                                                                                    |          | +  |

## Resource Detectors

| Detector                                                                                                                         | Source                | Haskell |
|----------------------------------------------------------------------------------------------------------------------------------|-----------------------|---------|
| Service (service.name, service.version, service.instance.id)                                                                     | Env vars              | +       |
| Process (process.pid, process.executable.name/path, process.command_args)                                                        | Runtime               | +       |
| Process Runtime (process.runtime.name/version/description)                                                                       | Runtime               | +       |
| Operating System (os.type, os.description)                                                                                       | Runtime               | +       |
| Host (host.name, host.arch)                                                                                                      | Runtime               | +       |
| Telemetry SDK (telemetry.sdk.name/language/version)                                                                              | Build info            | +       |
| Container (container.id, container.runtime)                                                                                      | /proc cgroup/mountinfo| +       |
| Cloud (cloud.provider, cloud.platform, cloud.region) — env-var based                                                            | Env vars              | +       |
| FaaS (faas.name, faas.version, faas.instance) — Lambda, GCF, Azure Functions                                                   | Env vars              | +       |
| Kubernetes (k8s.cluster.name, k8s.namespace.name, k8s.pod.name/uid, k8s.node.name)                                             | Env vars + SA token   | +       |
| AWS EC2 IMDS (host.id, host.type, host.image.id, cloud.region, cloud.availability_zone, cloud.account.id)                      | IMDS v2 HTTP          | +       |
| AWS ECS Task Metadata (aws.ecs.task.arn/family/revision, aws.ecs.cluster.arn, aws.ecs.launchtype, aws.log.*)                   | ECS metadata endpoint | +       |
| GCP Compute Metadata (host.id, host.name, host.type, cloud.region, cloud.availability_zone, cloud.account.id)                  | GCP metadata server   | +       |
| Azure VM IMDS (host.id, host.type, cloud.region, cloud.account.id)                                                              | Azure IMDS            | -       |

## Context Propagation

| Feature                                                                                                                 | Optional | Haskell |
|-------------------------------------------------------------------------------------------------------------------------|----------|----|
| [Create Context Key](https://opentelemetry.io/docs/specs/otel/context/)                                                |          | +  |
| Get value from Context                                                                                                  |          | +  |
| Set value for Context                                                                                                   |          | +  |
| [Attach Context](https://opentelemetry.io/docs/specs/otel/context/#attach-context)                                     |          | +  |
| [Detach Context](https://opentelemetry.io/docs/specs/otel/context/#detach-context)                                     |          | +  |
| Get current Context                                                                                                     |          | +  |
| [Composite Propagator](https://opentelemetry.io/docs/specs/otel/context/api-propagators/#composite-propagator)         |          | + (monoid instance) |
| [Global Propagator](https://opentelemetry.io/docs/specs/otel/context/api-propagators/#global-propagators)              |          | +  |
| [TraceContext Propagator](https://www.w3.org/TR/trace-context/)                                                         |          | +  |
| TraceContext multi-header tracestate                                                                                    |          | +  |
| [B3 Propagator](https://opentelemetry.io/docs/specs/otel/context/api-propagators/#b3-requirements)                     |          | + (single + multi) |
| [Jaeger Propagator](https://www.jaegertracing.io/docs/1.21/client-libraries/#propagation-format)                       |          | + (trace context + baggage) |
| [AWS X-Ray Propagator](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader) |        | + (X-Amzn-Trace-Id header) |
| [TextMapPropagator](https://opentelemetry.io/docs/specs/otel/context/api-propagators/#textmap-propagator)              |          | +  |
| [Fields](https://opentelemetry.io/docs/specs/otel/context/api-propagators/#fields) (`propagatorFields` = actual header names) |    | +  |
| Setter argument                                                                                                         | X        | + (injector field) |
| Getter argument                                                                                                         | X        | + (extractor field) |
| Getter argument returning Keys                                                                                          | X        | + (`textMapKeys`) |

## Environment Variables

Note: Support for environment variables is optional. See the [OTel environment variable specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/).

| Feature                                       | Haskell | Notes |
|-----------------------------------------------|---------|-------|
| OTEL_SDK_DISABLED                             | +       | |
| OTEL_RESOURCE_ATTRIBUTES                      | +       | |
| OTEL_SERVICE_NAME                             | +       | Takes precedence over `OTEL_RESOURCE_ATTRIBUTES` |
| OTEL_LOG_LEVEL                                | +       | Levels: none, error, warn, info, debug (default: info) |
| OTEL_PROPAGATORS                              | +       | Comma-separated; default: tracecontext,baggage; supports: tracecontext, baggage, b3, b3multi, datadog, jaeger, xray |
| OTEL_BSP_*                                    | +       | SCHEDULE_DELAY, EXPORT_TIMEOUT, MAX_QUEUE_SIZE, MAX_EXPORT_BATCH_SIZE |
| OTEL_BLRP_*                                   | +       | SCHEDULE_DELAY, EXPORT_TIMEOUT, MAX_QUEUE_SIZE, MAX_EXPORT_BATCH_SIZE |
| OTEL_EXPORTER_OTLP_*                          | +       | Full per-signal support: ENDPOINT, HEADERS, COMPRESSION, TIMEOUT, PROTOCOL, CERTIFICATE, INSECURE for traces, metrics, and logs |
| OTEL_TRACES_EXPORTER                          | +       | Registry-based; default: otlp; supports: none, otlp, custom via registry |
| OTEL_METRICS_EXPORTER                         | +       | Supports: otlp, prometheus, console, none |
| OTEL_LOGS_EXPORTER                            | +       | Supports: otlp, console, none; default: otlp |
| OTEL_METRIC_EXPORT_INTERVAL                   | +       | |
| OTEL_METRICS_EXEMPLAR_FILTER                  | +       | Supports: trace_based, always_on, always_off |
| OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT               | +       | |
| OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT        | +       | |
| OTEL_SPAN_EVENT_COUNT_LIMIT                   | +       | |
| OTEL_SPAN_LINK_COUNT_LIMIT                    | +       | |
| OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT              | +       | |
| OTEL_LINK_ATTRIBUTE_COUNT_LIMIT               | +       | |
| OTEL_TRACES_SAMPLER                           | +       | Supports: always_on, always_off, traceidratio, parentbased_always_on, parentbased_always_off, parentbased_traceidratio |
| OTEL_TRACES_SAMPLER_ARG                       | +       | |
| OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT             | +       | |
| OTEL_ATTRIBUTE_COUNT_LIMIT                    | +       | |
| OTEL_CONFIG_FILE                              | +       | YAML-based SDK configuration |

## Exporters

| Feature                                                                                                            | Optional | Haskell |
|--------------------------------------------------------------------------------------------------------------------|----------|----|
| [Exporter interface](https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-exporter)                           |          | +  |
| [Exporter interface has `ForceFlush`](https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflush-2)           |          | +  |
| Standard output (logging)                                                                                          |          | + (spans, metrics, logs) |
| In-memory (mock exporter)                                                                                          |          | +  |
| [OTLP](https://opentelemetry.io/docs/specs/otlp/)                                                                 |          | +  |
| OTLP/gRPC Exporter                                                                                                | *        | + (via `grpc` cabal flag) |
| OTLP/HTTP binary Protobuf Exporter                                                                                | *        | +  |
| OTLP/HTTP JSON Protobuf Exporter                                                                                  |          |    |
| OTLP/HTTP gzip Content-Encoding support                                                                           | X        | +  |
| Concurrent sending                                                                                                 |          |    |
| [Honors retryable responses with backoff](https://opentelemetry.io/docs/specs/otlp/#failures)                     | X        | +  |
| [Honors non-retryable responses](https://opentelemetry.io/docs/specs/otlp/#failures)                              | X        | +  |
| Honors throttling response                                                                                         | X        | (partial) |
| Multi-destination spec compliance                                                                                  | X        |    |
| [Zipkin](https://opentelemetry.io/docs/specs/otel/trace/sdk_exporters/zipkin/)                                    |          |    |
| Zipkin V1 JSON                                                                                                     | X        |    |
| Zipkin V1 Thrift                                                                                                   | X        |    |
| Zipkin V2 JSON                                                                                                     | *        |    |
| Zipkin V2 Protobuf                                                                                                 | *        |    |
| Service name mapping                                                                                               |          |    |
| SpanKind mapping                                                                                                   |          |    |
| InstrumentationLibrary mapping                                                                                     |          |    |
| Boolean attributes                                                                                                 |          |    |
| Array attributes                                                                                                   |          |    |
| Status mapping                                                                                                     |          |    |
| Error Status mapping                                                                                               |          |    |
| Event attributes mapping to Annotations                                                                            |          |    |
| Integer microseconds in timestamps                                                                                 |          |    |
| [Jaeger](https://opentelemetry.io/docs/specs/otel/trace/sdk_exporters/jaeger/)                                    |          | N/A |
| _(Deprecated by OTel spec — use OTLP to send to Jaeger backends)_                                                 |          |    |
| OpenCensus                                                                                                         |          |    |
| TBD                                                                                                                |          |    |
| [Prometheus](https://opentelemetry.io/docs/specs/otel/metrics/sdk_exporters/prometheus/)                          |          | +  |

## Haskell-Specific Extensions

| Feature                                                | Notes |
|--------------------------------------------------------|-------|
| Exception handlers (`ExceptionHandler` / `ExceptionClassification`) | Classify exceptions as Error / Recorded / Ignored; enrich spans with extra attributes. Configurable per `TracerProvider` and `Tracer`. Includes `exitSuccessHandler` for common Haskell patterns. |
| Simple processors export synchronously in `OnEnd` / `onEmit` | Matches Go, Java, .NET, C++, Rust, Python SDKs. Use Batch variants for non-blocking production use. |

## Development-Status / Not Yet Implemented

These features are either in "Development" status in the OTel specification (subject to change)
or not yet implemented. They are tracked here for visibility.

| Feature                                              | Spec Status   | Haskell |
|------------------------------------------------------|---------------|---------|
| CompositeSampler / ComposableSampler                 | Development   | -       |
| ProbabilitySampler (consistent probability sampling) | Development   | -       |
| OTLP/HTTP JSON exporter                             | Stable        | -       |
| Concurrent OTLP sending                             | Stable        | -       |
