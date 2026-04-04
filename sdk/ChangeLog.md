# Changelog for hs-opentelemetry-sdk

## Unreleased

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
- `ExemplarFilter`: TraceBased (default), AlwaysOn, AlwaysOff — replaces boolean `exemplarCaptureTraceContext`
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
