# Changelog for hs-opentelemetry-api

## Unreleased

### Full Spec conformance against 1.55.0
- **`InstrumentationScope` type alias added.**
  The OTel spec renamed "Instrumentation Library" to "Instrumentation Scope".
  `InstrumentationScope` is now a type alias for `InstrumentationLibrary`, and
  `instrumentationScope` is the preferred constructor. The underlying type
  retains the old name for backwards compatibility.
  Spec: <https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/>
- **`LogRecordExporter.forceFlush` now returns `IO FlushResult`.**
  Previously returned `IO ()`. The spec says ForceFlush SHOULD let the
  caller know whether it succeeded, failed, or timed out.
  Spec: <https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecordexporter>
- **`shouldSample` now receives the `InstrumentationScope`.**
  The `Sampler` type's `CustomSampler` constructor now takes the tracer's
  `InstrumentationLibrary` as a final parameter. This is a breaking change
  for custom sampler implementations.
  Spec: <https://opentelemetry.io/docs/specs/otel/trace/sdk/#shouldsample>
- **`ImmutableLogRecord` internal fields switched to `UMaybe`.**
  The `logRecordTimestamp`, `logRecordTracingDetails`, `logRecordSeverityText`,
  `logRecordSeverityNumber`, and `logRecordEventName` fields now use unboxed
  optionals for lower allocation on the emit hot path. External
  `LogRecordArguments` fields remain as `Maybe`.

### Performance

Major performance rework across the tracing and metrics hot paths. The previous
release (`origin/main`) used `System.Random.Stateful` for ID generation,
`IORef ImmutableSpan` with a flat mutable record for span state,
`System.Clock.TimeSpec` for timestamps, Haskell-side hex encoding, and
`http-types`/`case-insensitive`/`binary` as transitive dependencies. All of
these have been replaced:

- **Span representation split**: `ImmutableSpan` identity fields (trace/span ID,
  kind, start time) are now immutable and accessed without touching any `IORef`;
  only mutable state (`hotName`, `hotEnd`, `hotAttributes`, etc.) goes through a
  single `IORef SpanHot`. Eliminates an indirection on every
  `getSpanContext`/`isRecording` call.
- **Unboxed TraceId/SpanId**: two `Word64` fields in registers instead of a
  heap-allocated pinned `ShortByteString`. Eliminates allocation on every span.
- **Thread-local xoshiro256++ RNG**: replaced `System.Random.Stateful` (Haskell
  `random` package) with thread-local xoshiro256++ implemented in C, seeded once
  from the platform CSPRNG (`arc4random_buf` / `getrandom`). Zero contention,
  zero syscalls, zero Haskell allocation after initial seed. Dropped the `random`
  dependency.
- **Timestamp FFI**: `Timestamp` is now `Word64` nanoseconds. Direct
  `clock_gettime` C FFI call bypasses the `clock` package's
  `alloca`/`errno`/`Storable` overhead. OTLP serialization is zero-cost
  (`coerce`). Dropped the `clock` dependency.
- **C hex encoding**: trace/span ID hex via SWAR in C (`hs_otel_hex.c`),
  avoiding intermediate `ByteString` allocations from the old Haskell encoder.
- **No-op fast path**: `inSpan` skips `mask`/`bracketError`/context
  modification entirely when no processors are registered.
- **`bracketError` elimination**: inlined the `mask $ \restore ->` pattern into
  `inSpan`, eliminating a 4-tuple allocation, `uninterruptibleMask_`, and `try`
  that the previous generic `bracketError` helper required.
- **Thread-local context rewrite**: the previous `thread-utils-context` V1
  stored contexts in 32-stripe `IntMap`s with CAS (`casArray#` + `yield#`
  retry) on every write. Every `getContext` call allocated a `ThreadId` box
  via `myThreadId#`, crossed the FFI boundary to `rts_getThreadId`, then did
  an O(log n) `IntMap.lookup` inside the stripe. Every `adjustContext` /
  `attachContext` additionally CAS'd the entire stripe `IntMap`, with
  `yield#`-based spin on contention. `lookupSpan` went through
  `Data.Vault.Strict` (a `HashMap` keyed by `Data.Unique`).
  The new implementation replaces all of this with a flat open-addressed hash table
  backed by `MutableByteArray#` keys and `MutableArray#` values, where each
  thread gets its own `IORef`. Hot-path reads and writes now go directly through
  that `IORef` with zero contention. CAS is only used for
  thread registration (once per thread lifetime). Two custom CMM primops
  (`stg_getCurrentThreadId`, `stg_probeThreadSlot`) fuse thread ID retrieval
  with the table probe in a single STG call, eliminating the `myThreadId#`
  box allocation and `rts_getThreadId` FFI call entirely. The OTel wrapper for `Context` itself
  now has dedicated unboxed slots for `Span` and `Baggage`,
  replacing `Data.Vault.Strict` lookups with O(1) pattern matches.
  Result: `getContext` dropped from 17.3 ns to 2.9 ns (6x), `lookupSpan`
  from 10.0 ns to 0.6 ns / 0 B (17x).
- **CAS `yield#` removal**: removed `yield#` from the CAS failure path in
  `casModifyIORef_`; its presence prevented GHC from optimizing the uncontended
  success path.
- **Cached attribute limits**: pre-resolved from `TracerProvider` onto `Tracer`
  at `makeTracer` time, eliminating repeated pointer chasing on every attribute
  operation.
- **Deferred caller attributes**: source-location attributes passed lazily to
  `createSpanHelper`, only forced when the span is actually recorded.
- **INLINE audit**: ~30 hot-path functions annotated; `shouldSample` split into
  an inline wrapper + NOINLINE complex path so GHC can perform case-of-case at
  call sites.
- **`AttrsBuilder`**: church-encoded attribute builder that folds directly into
  the span's `HashMap`, avoiding intermediate list/tuple allocation.
  search for histogram bucket index, `AtomicBucketArray` (single
  `MutableByteArray#` with `fetchAddIntArray#`), `OptionalDouble` for histogram
  min/max.
- **Dependency removals**: dropped `random`, `clock`, `http-types`,
  `case-insensitive`, `binary`, `charset`, `regex-tdfa` from the API package.

Current benchmark results (GHC 9.10, `-O1`, aarch64-osx, `-N1 -A32m`):

| Operation | Time | Allocated |
|---|---|---|
| `inSpan` no-op (no processors) | 13.6 ns | 15 B |
| `inSpan` active (skip callerAttrs) | 218 ns | 1.2 KB |
| `inSpan` active | 445 ns | 2.5 KB |
| bare span (create+end) | 209 ns | 1.2 KB |
| HTTP span (3 attrs) | 410 ns | 2.5 KB |
| DB span (5 attrs) | 520 ns | 3.3 KB |
| 3-deep nested spans | 683 ns | 3.7 KB |
| `getContext` | 2.9 ns | 15 B |
| `lookupSpan` | 0.6 ns | 0 B |
| SpanId gen (xoshiro) | 3.0 ns | 0 B |
| TraceId gen (xoshiro) | 5.8 ns | 0 B |

Head-to-head comparison (same benchmark code, same machine, GHC 9.10,
`-O1 -N1 -A32m`):

| Operation | origin/main | Current | Speedup |
|---|---|---|---|
| `createSpan` no-op | 39.7 ns / 191 B | 13.6 ns / 15 B | **2.9x / 12.7x** |
| `inSpan` no-op | 316 ns / 1,678 B | 13.6 ns / 15 B | **23x / 112x** |
| `createSpan+endSpan` no-op | 593 ns / 1,846 B | 441 ns / 1,095 B | **1.3x / 1.7x** |

The `inSpan` no-op improvement is the most representative: it's the path
every instrumented function takes when the SDK is not installed or has no
processors. The old version paid for `mask`, context read/write, and
`System.Random` ID generation even on the no-op path; the new version
short-circuits all of that.

Cross-language comparison (bare span create+end, no attributes, AlwaysSample):

| Language | Time | Source |
|---|---|---|
| **Haskell** | **209 ns** | This release (tasty-bench, aarch64-osx) |
| **Go** | ~279 ns | [open-telemetry/opentelemetry-go#6730](https://github.com/open-telemetry/opentelemetry-go/pull/6730) (StartEndSpan/AlwaysSample, May 2025) |
| **Rust** | ~349 ns | [open-telemetry/opentelemetry-rust#1101](https://github.com/open-telemetry/opentelemetry-rust/pull/1101) (basic span no attrs, always-sample, Jun 2023) |

Haskell's bare span is **1.3x faster than Go** and **1.7x faster than Rust**
on the equivalent workload. The `inSpan` wrapper adds `mask`/`restore` for
async-exception safety and TLS context management, bringing the total to
218 ns without caller attributes or 445 ns with automatic `code.*` source
location attributes (which other SDKs do not include by default).

Note: cross-language numbers are from different machines and compilers, so
ratios are approximate. The Go and Rust numbers are from their own CI /
maintainer benchmarks on x86-64 Linux.

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
  bug as `forceFlushTracerProvider`: processor flush asyncs were never
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
  scope, and resource: instead of a `newtype` wrapper around `ReadWriteLogRecord`.
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
- `instrumentationLibrary :: Text -> Text -> InstrumentationLibrary`: smart constructor (name + version)
- `withSchemaUrl :: Text -> InstrumentationLibrary -> InstrumentationLibrary`: composable modifier
- `withLibraryAttributes :: Attributes -> InstrumentationLibrary -> InstrumentationLibrary`: composable modifier
- `materializeResourcesWithSchema :: Maybe String -> Resource schema -> MaterializedResources`: set runtime schema URL
- `setMaterializedResourcesSchema :: Maybe String -> MaterializedResources -> MaterializedResources`: override schema

### Tracing
- `makeTracer` now wires `TracerOptions.tracerSchema` into `InstrumentationLibrary.librarySchemaUrl` (was ignored)
- Add `alwaysRecord` sampler: decorator that upgrades DROP to RECORD_ONLY so span processors see all spans without increasing export volume
- Fix `isValid` to require BOTH TraceId AND SpanId non-zero (was incorrectly valid if either was non-zero)
- Add `TraceState.lookup` for getting a value by key (MUST per spec)
- Add `spanExporterForceFlush` field to `SpanExporter` (MUST per spec); built-in simple/batch processors now call it

### Logs
- Add `logRecordEventName` field to `ImmutableLogRecord` and `eventName` to `LogRecordArguments`
- Add `loggerIsEnabled` function to check if a Logger has registered processors (SHOULD per spec)

### Metrics: full API coverage (new!)

This release introduces complete metrics support to hs-opentelemetry-api,
covering the entire synchronous and asynchronous instrument surface from the
OpenTelemetry specification.

- **Synchronous instruments**: `Counter`, `UpDownCounter`, `Histogram`, `Gauge`
- **Asynchronous (observable) instruments**: `ObservableCounter`,
  `ObservableUpDownCounter`, `ObservableGauge`, with `observable*Enabled`
  fields so callers can skip expensive measurement callbacks when no SDK is
  installed
- **Views**: `name` and `description` override fields on `View`;
  `filterAttributesByKeys` for attribute projection
- **Aggregation**: `AggregationTemporality` (delta / cumulative),
  `ExponentialHistogramDataPoint`, `MetricExportExponentialHistogram`
- **Exemplars**: `MetricExemplar` type; exemplar fields on all data point types
- **Advisory parameters**: `AdvisoryParameters` with optional
  `advisoryHistogramAggregation`; `HistogramAggregation` selects explicit
  bucket boundaries or exponential scale
- **Timestamps**: `startTimeUnixNano` on `SumDataPoint`, `HistogramDataPoint`,
  `ExponentialHistogramDataPoint`, `GaugeDataPoint`
- **Environment**: `lookupMetricExportIntervalMillis`, `MetricsExemplarFilter`,
  `lookupMetricsExemplarFilter`
- **Debug**: `OpenTelemetry.Debug.MetricExport` for human-readable rendering of
  metric export batches

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
