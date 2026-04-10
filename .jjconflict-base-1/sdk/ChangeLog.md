# Changelog for hs-opentelemetry-sdk

## Unreleased

### Spec conformance (1.55.0 audit)
- **NaN/Inf silently dropped for all metric instrument types.**
  Previously only histograms filtered non-finite double values. Now
  `addSumDbl`, `setSumDbl`, and `recordGauge` also drop NaN and Infinity.
  Spec: <https://opentelemetry.io/docs/specs/otel/metrics/sdk/>

### Performance
- **Batch processor**: switched to `unagi-chan` bounded queue with power-of-two
  sizing. `tryWriteChan` is non-blocking; drain uses `estimatedLength` for
  batch sizing. Export groups spans by tracer at drain time. Concurrent chunk
  export via `mapConcurrently_`.
- **Simple processor**: synchronous export in `onEnd`/`onEmit` (no thread
  overhead). Matches Go/Java/Python SDK design for low-throughput use cases.
- **Metrics**: `AtomicBucketArray` for histogram buckets (single
  `MutableByteArray#` with `fetchAddIntArray#`, zero vector copying on record).
  Separate `SumIntCell`/`SumDblCell` to avoid boxing. Binary search for bucket
  index. `OptionalDouble` sentinel for min/max instead of `Maybe Double`.
- **Default ID generator**: thread-local xoshiro256++ in C, replacing the
  Haskell `random` package (`System.Random.Stateful`) that was used on
  `origin/main`. No contention, no syscalls, no Haskell allocation after
  initial seed.

### Dependencies
- **Replaced `connection` with `crypton-connection`, `x509-store` with `crypton-x509-store`.**
  The legacy `connection` package is not in modern Stackage (LTS-24+) and fails to
  build against `tls 2.x` in nixpkgs. The `crypton-*` forks are drop-in replacements
  with identical module paths.

### Bug fixes
- **Batch processor shutdown deadlock fixed.**
  Second `shutdownTracerProvider` / `shutdownLoggerProvider` call would hang
  forever because `putTMVar` blocks when the worker has already consumed the
  signal. Fixed with `tryPutTMVar` + `IORef` shutdown guard. `OnEnd`/`OnEmit`
  are now also guarded to prevent buffer growth after shutdown.
- **Counter rejects negative values.**
  Monotonic counters now drop negative deltas per spec. Previously, negative
  values were summed into the same cell, producing incorrect monotonic sums.
- **`MeterProvider.shutdown` is now idempotent.**
  Second call returns `ShutdownSuccess` immediately without re-running
  collection, export, or exporter shutdown.
- **`OTEL_SDK_DISABLED=true` no longer disables propagators.**
  `detectPropagators` is now always called, even when the SDK is disabled,
  so `setGlobalTextMapPropagator` runs and instrumentation libraries can
  still propagate context.
- **`service.name` precedence fixed.**
  `OTEL_SERVICE_NAME` now takes precedence over `service.name` defined in
  `OTEL_RESOURCE_ATTRIBUTES`, matching the spec.
- **OTLP exporters return `Failure` after shutdown.**
  `spanExporterExport` and `logRecordExporterExport` now check a shutdown
  flag and return `Failure Nothing` after `shutdown()` is called.
- **Simple processors have 30s export timeout.**
  `export()` in simple span and log record processors is now wrapped in a
  `timeout` to prevent indefinite blocking.
- **BSP default `maxQueueSize` fixed from 1024 to 2048.**
  Now matches the spec default and the documentation table.

### Changes
- **`detectPropagators` and `createFromConfig` now set the global propagator.**
  The SDK initialization path (`initializeGlobalTracerProvider` and
  `createFromConfig`) now calls `setGlobalTextMapPropagator`, making propagators
  available via the global API. Instrumentation libraries (WAI, http-client,
  hw-kafka-client) now use `getGlobalTextMapPropagator` instead of extracting
  propagators from the `TracerProvider`.
- **`OTEL_PROPAGATORS` values are now deduplicated and whitespace-stripped.**
  Per spec: "Values MUST be deduplicated in order to register a Propagator only once."
- **Breaking: `SimpleSpanProcessor` and `SimpleLogRecordProcessor` now export synchronously.**
  `onEnd` / `onEmit` calls the exporter directly on the calling thread instead of
  enqueueing to an unbounded async channel. This matches the OTel specification
  ("passes finished spans directly to the configured SpanExporter") and the behavior
  of every other OTel SDK: Go, Java, .NET, C++, Rust, and Python all export
  synchronously in their simple processors. The previous unbounded `unagi-chan`
  queue could grow without bound under backpressure. Use `BatchSpanProcessor` /
  `BatchLogRecordProcessor` for non-blocking, production-grade processing.
- **Metric storage: per-instrument `IORef` replaces global `IORef`.**
  Each instrument now owns its own `IORef (HashMap Attributes Cell)`, eliminating
  cross-instrument contention on the recording hot path. Same-name instrument
  re-registration shares the underlying `IORef` (spec MUST). `SdkMeterStorageState`,
  `DimKey`, and `seriesCountByDims` are removed.
- **Fix: TOCTOU race in instrument registration.** `getOrCreateInstrumentStorage`
  now performs the lookup and insertion inside a single `atomicModifyIORef'`, preventing
  duplicate `IORef`s for the same instrument under concurrent registration.
- **Fix: delta temporality lost-update bug.** `collectResourceMetrics` now atomically
  snapshots and resets each instrument's cell map in one `atomicModifyIORef'`, preventing
  recordings between snapshot and reset from being silently dropped.
- **Fix: metric export grouping.** `buildResourceExport` now groups by
  `InstrumentationLibrary` (scope) with each instrument producing an independent
  metric export, rather than merging instruments that share (scope, name, kind, unit,
  description) but differ in histogram aggregation or export attribute keys.
- **Fix: `OTEL_CONFIG_FILE` resource.schema_url.** `buildResource` now applies
  `resourceSchemaUrl` from the config to the materialized resource.
- **Fix: view matching ignoring unit and meter scope.** `findMatchingView`,
  `shouldDropInstrument`, `viewOverrideName`, `viewOverrideDescription`, and
  `exportKeysFor` now receive real instrument unit and meter scope. Previously
  views with unit or meter-name/version/schema_url selectors never matched.
- **Fix: batch processor worker crash on export exception.** Both batch span and
  batch log processors now catch `SomeException` around `publish`, preventing the
  worker `Async` from dying permanently on a transient exporter failure.
- **Fix: unsorted explicit histogram bucket boundaries.** Advisory and view-supplied
  bucket boundaries are now sorted before use, preventing incorrect bucket placement.
- **Fix: batch processor off-by-one in queue capacity.** Both `BatchSpanProcessor`
  and `BatchLogRecordProcessor` rejected items when `count + 1 >= maxQueueSize`,
  meaning a queue configured for 1024 items only held 1023. Changed to
  `count >= maxQueueSize` so the queue accepts exactly `maxQueueSize` items.
- **Fix: simple processor shutdown flags used non-atomic `writeIORef`.** Both
  `SimpleSpanProcessor` and `SimpleLogRecordProcessor` now use `atomicWriteIORef`
  for the shutdown flag, ensuring happens-before visibility to concurrent readers.
- **Fix: `MeterProvider` shutdown flag used non-atomic `writeIORef`.** Now uses
  `atomicWriteIORef` for the shutdown boolean.
- **Fix: `detectSpanLimits` swapped `OTEL_SPAN_LINK_COUNT_LIMIT` and
  `OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT`.** Positional applicative construction
  mapped link count limit to `eventAttributeCountLimit` and vice versa.
  Corrected field ordering.
- **Batch processor `ForceFlush` now blocks until the worker completes an export cycle.**
  Previously `ForceFlush` signaled the worker and returned immediately, offering no
  guarantee that buffered spans/logs were exported before the caller continued. The new
  implementation uses a generation counter with a timeout derived from `exportTimeoutMillis`.
- **Batch processor `maxExportBatchSize` is now enforced as a hard per-export limit.**
  The buffer is drained fully, then chunked into batches of at most `maxExportBatchSize`
  items before each chunk is exported separately. Matches the OTel spec requirement.
- **Per-export timeout on batch processor.** Individual export calls are wrapped in
  `System.Timeout.timeout exportTimeoutMillis`. A timed-out export returns `Failure`
  without killing the worker.
- **`ReadableLogRecord` is now a true point-in-time snapshot.** `mkReadableLogRecord`
  reads the `IORef` and stores the `ImmutableLogRecord` directly, so exporters see
  a consistent view regardless of concurrent mutations. `mkReadableLogRecord` is now
  `IO` (breaking change to the internal API).
- **Observable callback handles now support real unregistration.** `ObservableCallbackHandle.unregisterObservableCallback`
  removes the callback from the meter's collection registry. Previously it was a no-op.
  Internally, callbacks are stored in an `IntMap` keyed by unique ID rather than a `Seq`.
- Implement declarative SDK configuration via `OTEL_CONFIG_FILE` (`OpenTelemetry.Configuration`)
  - YAML parsing with environment variable substitution (`${VAR}`, `${env:VAR:-default}`)
  - In-memory configuration data model (`OpenTelemetry.Configuration.Types`)
  - Full `Create` operation: TracerProvider, MeterProvider, LoggerProvider, Propagators from config
  - Supports OTLP HTTP, console, and none exporters; batch and simple processors
  - Sampler configuration: always_on, always_off, trace_id_ratio_based, parent_based
  - Resource, attribute limits, span limits, propagator configuration
- **Shutdown/ForceFlush propagation audit:**
  - Batch span processor now calls `spanExporterShutdown` during processor shutdown (was missing)
  - Batch log processor now calls `logRecordExporterShutdown` during processor shutdown
  - `MeterProvider` shutdown now does a final collect + export + `metricExporterShutdown` when an exporter is configured
  - `MeterProvider` forceFlush now does collect + export + `metricExporterForceFlush` when an exporter is configured
  - `SdkMeterProviderOptions` gains `metricExporter :: Maybe MetricExporter` field
  - Periodic metric reader stop now calls `metricExporterShutdown` after final export
  - `forceFlushTracerProvider` exported from `OpenTelemetry.Trace` (SDK)
- Implement `SimpleLogRecordProcessor`: processes log records inline, passes them to configured `LogRecordExporter`
- Implement `BatchLogRecordProcessor`: batches log records with configurable queue size, export interval, and timeout
- Batch/simple span processors now call `spanExporterForceFlush` during processor `ForceFlush`
- IsValid test coverage expanded for TraceId-only and SpanId-only zero cases
- Track `startTimeUnixNano` across all data points (was hardcoded to 0)
- `ForceFlush` on `MeterProvider` now triggers a metric collect
- `View` supports name and description overrides
- `ViewSelector` expanded: name (wildcard), kind, unit, meter_name, meter_version, meter_schema_url criteria (spec MUST)
- `findAllMatchingViews` for multi-view-stream support
- Instrument name matching is now case-insensitive (spec MUST)
- Cardinality overflow: excess series aggregated under `otel.metric.overflow=true` (spec SHOULD)
- Default explicit histogram bounds updated to spec: `[0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]`
- NaN/Inf measurements silently dropped in recordHist/recordExpHist (spec MUST)
- Advisory `Attributes` parameter used as fallback when View has no `attribute_keys` (spec SHOULD)
- `ExemplarFilter`: TraceBased (default), AlwaysOn, AlwaysOff: replaces boolean `exemplarCaptureTraceContext`
- `OTEL_METRICS_EXEMPLAR_FILTER` env var fully wired into SDK
- New `OpenTelemetry.Metrics.ExporterSelection` module: wire `OTEL_METRICS_EXPORTER` to concrete `MetricExporter`
- Comprehensive test coverage for all instrument types, views, delta temporality, observables
- `SdkMeterProviderOptions`: `aggregationTemporality`, `views`, `exemplarOptions`
- `OpenTelemetry.Metrics.View`: instrument selection and aggregation overrides (including drop).
- Exponential histogram aggregation, exemplars, delta temporality with post-collect reset (gauges unchanged).
- Observable callbacks collected in FIFO order; `MetricReader.periodicMetricReaderOptionsFromEnv` for `OTEL_METRIC_EXPORT_INTERVAL`.

## 0.1.0.1

- Update dependency bounds for hs-opentelemetry-api 0.3.0.0

## 0.1.0.0

- Support new versions of dependencies.
- Windows: Replace POSIX-only functionality with a stub, so the package could be built at all (#114).
- Support `OTEL_SDK_DISABLED` (#148).
- Add Datadog as a known propagator (#117).
- Documentation improvements

## 0.0.3.6

- Raise minimum version bounds for `random` to 1.2.0. This fixes duplicate ID generation issues in highly concurrent systems.

## 0.0.3.3

- Fix batch processor flush behavior on shutdown to not drop spans

## 0.0.3.2

- Fix haddock issue

## 0.0.3.1

- `getTracerProviderInitializationOptions'` introduced to enable custom resource detection

## 0.0.2.1

- Doc enhancements
- `makeTracer` introduced to replace `getTracer`
- Tighten exports. Not likely to cause any breaking changes for existing users.

## 0.0.2.0

- Update hs-opentelemetry-api bounds
- Export new `NewLink` interface for creating links

## 0.0.1.0

- Initial release
