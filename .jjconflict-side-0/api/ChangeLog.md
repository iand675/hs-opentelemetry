# Changelog for hs-opentelemetry-api

## Unreleased

- Fix `isValid` to require BOTH TraceId AND SpanId non-zero (was incorrectly valid if either was non-zero)
- Add `TraceState.lookup` for getting a value by key (MUST per spec)
- Add `spanExporterForceFlush` field to `SpanExporter` (MUST per spec); built-in simple/batch processors now call it
- Add `logRecordEventName` field to `ImmutableLogRecord` and `eventName` to `LogRecordArguments`
- Add `loggerIsEnabled` function to check if a Logger has registered processors (SHOULD per spec)
- Add `startTimeUnixNano` field to `SumDataPoint`, `HistogramDataPoint`, `ExponentialHistogramDataPoint`, `GaugeDataPoint`
- View `name` and `description` override fields on `View`
- Metrics: `AggregationTemporality`, `MetricExemplar`, `ExponentialHistogramDataPoint`, exemplar fields on data points, `MetricExportExponentialHistogram`, `filterAttributesByKeys`.
- `AdvisoryParameters`: optional `advisoryHistogramAggregation`; `HistogramAggregation` (explicit vector or exponential scale).
- Observable instruments: `observable*Enabled` fields.
- `OpenTelemetry.Environment`: `lookupMetricExportIntervalMillis`, `MetricsExemplarFilter`, `lookupMetricsExemplarFilter`.
- `OpenTelemetry.Debug.MetricExport` for debug rendering of metric batches.

## 0.3.1.0

- Add `tracerIsEnabled` function to check if a Tracer is enabled (helps avoid expensive operations when tracing is disabled)
- Fix `spanIdBaseEncodedByteString` error message

## 0.3.0.0

- Export `fromList` from `OpenTelemetry.Trace.TraceState` for creating TraceState from key-value pairs

## 0.2.1.0

- defined and exported `toImmutableSpan` and `FrozenOrDropped` from `OpenTelemetry.Trace.Core`

## 0.2.0.0

- `callerAttributes` and `ownCodeAttributes` now work properly if the call stack has been frozen. Hence most
  span-construction functions should now get correct source code attributes in this situation also (#137.
- Added `detectInstrumentationLibrary` for producing `InstrumentationLibrary`s with TH (#2).
- Fixed precedence order of resource merge (#156).
- Added the ability to add links to spans after creation (#152).
- Correctly compute attribute length limits (#151).
- Add helper for reading boolean environment variables correctly (#153).
- Initial scaffolding for logging support. Renamed `Processor` to `SpanProcessor`.
- Export `FlushResult` (#96)
- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes
- Improved conformance with semantic conventions.

## 0.0.3.6

- GHC 9.4 support
- Add Show instances to several api types

## 0.0.3.1

- `adjustContext` uses an empty context if one hasn't been created on the current thread yet instead of acting as a no-op.

## 0.0.2.1

- Doc enhancements

## 0.0.2.0

- Separate `Link` and `NewLink` into two different datatypes to improve Link creation interface.
- Add some version bounds
- Catch & print all synchronous exceptions when calling span processor
  start and end hooks

## 0.0.1.0

- Initial release
