# Changelog for hs-opentelemetry-api

## Unreleased

### Bug fixes
- **`addAttributes` now correctly overwrites existing keys.**
  `H.union` argument order was reversed, causing existing attribute values to
  silently take precedence over new ones. New values now win on key conflict,
  matching `addAttribute` behavior and spec intent.
- **`traceIdRatioBased` description now always uses `TraceIdRatioBased{ratio}` format.**
  Previously, `traceIdRatioBased 1.0` returned `alwaysOn` whose description was
  `"AlwaysOnSampler"`, violating the spec's MUST requirement. The ratio is now
  clamped to `[0, 1]` and the description always follows the spec format.

### Spec conformance (SHOULD-level)
- **`LoggerProvider` shutdown suppresses processor dispatch.**
  Added `loggerProviderIsShutdown` flag. After `shutdownLoggerProvider`,
  `emitLogRecord` still returns a `ReadWriteLogRecord` but skips calling
  processors. `loggerIsEnabled` now returns `IO Bool` and accounts for
  shutdown state.
- **`Baggage` `insertChecked` enforces W3C size limits.**
  New `insertChecked :: Token -> Element -> Baggage -> Either InvalidBaggage Baggage`
  enforces the 180-member limit (W3C ABNF grammar) and 8192-byte total
  serialized size limit. `InvalidBaggage` now derives `Show, Eq`.

### Breaking changes
- **`createLoggerProvider` is now monadic (`MonadIO m => ... -> m LoggerProvider`).**
  Required to safely allocate the internal shutdown `IORef`. Existing `let`
  bindings need to become `<-` bindings.
- **`loggerIsEnabled` now returns `IO Bool` instead of `Bool`.**
  Checks the provider shutdown flag, which requires reading the `IORef`.
- **`propagatorNames` renamed to `propagatorFields`.**
  The `Propagator` record field is now called `propagatorFields` to match the
  OpenTelemetry spec's `Fields` method. Values are actual header names (e.g.
  `["traceparent", "tracestate"]`), not display names.
- **New `TextMapPropagator` type alias.**
  `type TextMapPropagator = Propagator Context RequestHeaders RequestHeaders`
  is now exported from `OpenTelemetry.Propagator`.
- **Global `TextMapPropagator` API.**
  `getGlobalTextMapPropagator` and `setGlobalTextMapPropagator` provide a
  spec-conformant global propagator. Defaults to no-op per spec. The SDK
  sets this during initialization. Instrumentation libraries should prefer
  the global propagator over `getTracerProviderPropagators`.
- **`SemanticsOptions` is now opaque with generalized stability lookup.**
  Instead of a record with `httpOption` and `databaseOption` fields,
  `SemanticsOptions` now stores the parsed env var values as a set. Use the new
  `lookupStability :: Text -> SemanticsOptions -> StabilityOpt` function to query
  any signal key (e.g. `"http"`, `"database"`, `"messaging"`, `"rpc"`). The
  convenience functions `httpOption` and `databaseOption` still work as before.
  `HttpOption` is now a type alias for the renamed `StabilityOpt` data type.
  Third-party instrumentation libraries can now participate in the
  `OTEL_SEMCONV_STABILITY_OPT_IN` mechanism without modifying this module.

### Bug fixes
- **Fix: `setStatus` merge semantics.** Previously used `max` on an `Ord SpanStatus`
  instance to merge statuses, which broke Error-over-Error (last-writer-wins) regardless
  of how `Ord` was defined. Now uses an explicit `mergeStatus` function implementing the
  three spec rules: Ok is final, Unset is ignored, everything else is last-writer-wins.
  The `Ord` instance is now lawful (EQ for Error/Error) and only represents the class
  hierarchy (Ok > Error > Unset), not merge logic.
- **Fix: `forceFlushTracerProvider` leaked async threads on timeout.** Outstanding
  processor flush asyncs were never cancelled when the timeout fired. Now calls
  `mapM_ cancel jobs` on the `Nothing` (timeout) branch.
- **Fix: `isRecording` returned `True` for `FrozenSpan`.** `FrozenSpan` is an
  already-completed immutable span (used for links/export). It is not recording.
  Now returns `False`, aligning with `whenSpanIsRecording`.
- **Fix: `setGlobalTracerProvider` used non-atomic `writeIORef`.** Concurrent reads
  could see torn state. Now uses `atomicWriteIORef`.
- **Fix: `setGlobalMeterProvider` and `setGlobalLoggerProvider` used non-atomic
  `writeIORef`.** Same rationale as the tracer provider; now uses
  `atomicWriteIORef`.
- **Fix: noop observable instruments reported `enabled = True`.** The no-op
  `Meter` now reports `False` from observable `*Enabled` actions so callers can
  skip expensive measurement callbacks when no SDK is installed (aligned with
  synchronous noop instruments).
- **Fix: span mutation functions (`addAttribute`, `addAttributes`, `addEvent`,
  `addLink`, `setStatus`, `updateName`) used non-atomic `modifyIORef'`.**
  Concurrent calls could race and silently drop updates (e.g. lost events
  under concurrent `addEvent`). All now use `atomicModifyIORef'`, matching
  `endSpan` which was already atomic. Also fixed `withCarryOnProcessor` in
  `OpenTelemetry.Contrib.CarryOns`.
- **Fix: log record mutation (`addAttribute`, `addAttributes`) used non-atomic
  lazy `modifyIORef`.** Same race condition as span mutations, plus thunk
  buildup from the lazy variant. `modifyLogRecord` and `atomicModifyLogRecord`
  now both use `atomicModifyIORef'` (strict and atomic).
- **Fix: `forceFlushLoggerProvider` leaked async threads on timeout.** Same
  bug as `forceFlushTracerProvider` — processor flush asyncs were never
  cancelled when the timeout fired. Now calls `mapM_ cancel jobs`.
- **Fix: `shutdownLoggerProvider` aborted on first processor failure.** Used
  `wait` which re-throws on async exception, causing remaining processors to
  be skipped. Now uses `waitCatch` so all processors get a chance to shut down.
- **Fix: `Dropped` / no-processor spans discarded parent `TraceState`.** When
  creating a child span with a `Dropped` parent, or when no processors are
  configured, `traceState` was forced to `TraceState.empty`. Now inherits the
  parent's `traceState`, preserving vendor data in W3C `tracestate`.
- **Fix: `shutdownTracerProvider` was sequential.** Each processor shutdown had to
  complete before the next started. Now launches all shutdowns concurrently and
  waits for all via `waitCatch`.

### ReadableLogRecord true snapshot
- `ReadableLogRecord` is now a `data` type holding a snapshotted `ImmutableLogRecord`,
  scope, and resource — instead of a `newtype` wrapper around `ReadWriteLogRecord`.
- `mkReadableLogRecord` is now `IO` (reads the `IORef` at call time to produce a
  consistent point-in-time snapshot). Callers must update `let` bindings to `<-`.

### Span lifecycle enforcement
- `setStatus`, `addAttribute`, `addAttributes`, `addEvent`, `addLink`, and
  `updateName` now check `spanEnd` and silently skip mutations on ended spans.
  This aligns with the OTel spec: "the Span MUST NOT be modified after it ends."

### Exception handlers (Haskell extension)
- New `OpenTelemetry.Trace.ExceptionHandler` module with `ExceptionClassification`, `ExceptionResponse`, `ExceptionHandler` types
- Smart constructors: `ignoreExceptionType`, `ignoreExceptionMatching`, `recordExceptionType`, `recordExceptionMatching`, `classifyException`, `exitSuccessHandler`
- `TracerProvider` now has `tracerProviderExceptionHandlers` field for global exception classification
- `TracerOptions` now has `tracerExceptionHandlerOptions` field for per-library exception classification
- `inSpan''` consults exception handlers before setting Error status / recording events
- **Breaking**: `TracerOptions` changed from `newtype` to `data` (added `tracerExceptionHandlerOptions` field)

### Resource & InstrumentationLibrary ergonomics
- `instrumentationLibrary :: Text -> Text -> InstrumentationLibrary` — smart constructor (name + version)
- `withSchemaUrl :: Text -> InstrumentationLibrary -> InstrumentationLibrary` — composable modifier
- `withLibraryAttributes :: Attributes -> InstrumentationLibrary -> InstrumentationLibrary` — composable modifier
- `materializeResourcesWithSchema :: Maybe String -> Resource schema -> MaterializedResources` — set runtime schema URL
- `setMaterializedResourcesSchema :: Maybe String -> MaterializedResources -> MaterializedResources` — override schema

### Tracing
- `makeTracer` now wires `TracerOptions.tracerSchema` into `InstrumentationLibrary.librarySchemaUrl` (was ignored)
- Add `alwaysRecord` sampler — decorator that upgrades DROP→RECORD_ONLY so span processors see all spans without increasing export volume
- Fix `isValid` to require BOTH TraceId AND SpanId non-zero (was incorrectly valid if either was non-zero)
- Add `TraceState.lookup` for getting a value by key (MUST per spec)
- Add `spanExporterForceFlush` field to `SpanExporter` (MUST per spec); built-in simple/batch processors now call it

### Logs
- Add `logRecordEventName` field to `ImmutableLogRecord` and `eventName` to `LogRecordArguments`
- Add `loggerIsEnabled` function to check if a Logger has registered processors (SHOULD per spec)

### Metrics
- Add `startTimeUnixNano` field to `SumDataPoint`, `HistogramDataPoint`, `ExponentialHistogramDataPoint`, `GaugeDataPoint`
- View `name` and `description` override fields on `View`
- `AggregationTemporality`, `MetricExemplar`, `ExponentialHistogramDataPoint`, exemplar fields on data points, `MetricExportExponentialHistogram`, `filterAttributesByKeys`
- `AdvisoryParameters`: optional `advisoryHistogramAggregation`; `HistogramAggregation` (explicit vector or exponential scale)
- Observable instruments: `observable*Enabled` fields
- `OpenTelemetry.Environment`: `lookupMetricExportIntervalMillis`, `MetricsExemplarFilter`, `lookupMetricsExemplarFilter`
- `OpenTelemetry.Debug.MetricExport` for debug rendering of metric batches

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
