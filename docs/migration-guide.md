# Migration Guide (0.3.x / 0.1.x to 0.4 / 1.0)

This guide covers all breaking changes when upgrading from what was on
`origin/main` to the current release. Changes are grouped by package, then
by theme.

## hs-opentelemetry-api

### Module renames

| Old module | New module |
|-----------|------------|
| `OpenTelemetry.Logs.Core` | `OpenTelemetry.Log.Core` |
| `OpenTelemetry.Internal.Logs.Core` | `OpenTelemetry.Internal.Log.Core` |
| `OpenTelemetry.Internal.Logs.Types` | `OpenTelemetry.Internal.Log.Types` |
| `OpenTelemetry.Internal.Metrics.Types` | `OpenTelemetry.Internal.Metric.Types` |
| `OpenTelemetry.Internal.Metrics.Export` | `OpenTelemetry.Internal.Metric.Export` |
| `OpenTelemetry.Metrics` | `OpenTelemetry.Metric.Core` |
| `OpenTelemetry.Metrics.InstrumentName` | `OpenTelemetry.Metric.InstrumentName` |

### Span representation (performance rework)

The `Span` type no longer holds a mutable `IORef` at the top level. Mutable
fields are collected into a `SpanHot` sub-record behind a single `IORef`,
while identity fields sit directly on `ImmutableSpan`:

```haskell
-- Old
data Span = Span (IORef ImmutableSpan) | FrozenSpan SpanContext | Dropped SpanContext

-- New
data Span = Span !ImmutableSpan | FrozenSpan !SpanContext | Dropped !SpanContext
```

`ImmutableSpan` now has: `spanContext`, `spanKind`, `spanStart`, `spanParent`,
`spanTracer`, `spanHot :: IORef SpanHot`. The `SpanHot` record carries
`hotName`, `hotEnd`, `hotAttributes`, `hotLinks`, `hotEvents`, `hotStatus`.

**Why:** Eliminates an indirection on every `getSpanContext`, `isRecording`,
etc. Hot-path mutations go through the `IORef SpanHot` with CAS. Cold
identity fields (trace/span ID, kind, start time) are accessed without
touching the `IORef` at all.

### TraceId / SpanId (unboxed Word64)

```haskell
-- Old
newtype TraceId = TraceId ShortByteString
newtype SpanId  = SpanId  ShortByteString

-- New
data TraceId = TraceId !Word64 !Word64
data SpanId  = SpanId  !Word64
```

**Why:** Eliminates pinned `ShortByteString` allocation on every span creation.
Two `Word64`s in registers vs. a heap-allocated byte array. Hex encoding now
uses a C FFI encoder (`hs_otel_hex.c`).

Use `traceIdBytes`, `spanIdBytes`, `bytesToTraceId`, `bytesToSpanId` for
raw-byte conversions. The hex encoding functions (`traceIdBaseEncodedBuilder`,
etc.) still work. `Base` is now `data Base = Base16` only (non-hex encodings
removed).

### IdGenerator (ADT instead of record)

```haskell
-- Old
data IdGenerator = IdGenerator
  { generateSpanIdBytes  :: IO ByteString
  , generateTraceIdBytes :: IO ByteString
  }

-- New
data IdGenerator
  = DefaultIdGenerator     -- thread-local xoshiro256++ (zero contention)
  | CustomIdGenerator
      !(IO ShortByteString)  -- 8 bytes for span ID
      !(IO ShortByteString)  -- 16 bytes for trace ID
```

**Why:** Pattern-matching on `DefaultIdGenerator` lets GHC inline the fast path
directly at call sites, eliminating indirect function calls. The default
generator uses thread-local xoshiro256++ seeded from the platform CSPRNG
(no syscalls after initial seed, no contention).

Use `customIdGenerator spanIO traceIO` instead of the record constructor.

### Timestamp (Word64 nanoseconds)

```haskell
-- Old
newtype Timestamp = Timestamp TimeSpec    -- from clock package

-- New
newtype Timestamp = Timestamp Word64      -- nanoseconds since Unix epoch
```

**Why:** OTLP uses `fixed64` nanoseconds; this representation is zero-cost to
serialize. FFI call (`hs_otel_gettime_ns`) is ~15ns faster than
`System.Clock.getTime` on macOS.

New helpers: `mkTimestamp`, `timestampToNanoseconds`, `OptionalTimestamp`.

### Sampler (ADT with InstrumentationScope)

```haskell
-- Old (record)
data Sampler = Sampler
  { getDescription :: Text
  , shouldSample :: Context -> TraceId -> Text -> SpanArguments
                 -> IO (SamplingResult, AttributeMap, TraceState)
  }

-- New (ADT)
data Sampler
  = AlwaysOnSampler
  | AlwaysOffSampler
  | TraceIdRatioSampler !Double !Word64 !Attribute
  | ParentBasedSampler !ParentBasedOptions
  | AlwaysRecordSampler !Sampler
  | CustomSampler !Text
      !(Context -> TraceId -> Text -> SpanArguments
       -> InstrumentationLibrary -> IO SamplingDecision)
```

**Key differences:**
- `shouldSample` and `getDescription` are top-level functions, not fields
- `shouldSample` takes an additional `InstrumentationLibrary` parameter (the
  tracer's scope), per spec requirement
- Return type is `SamplingDecision` (record with `samplingOutcome`,
  `samplingAttributes`, `samplingTraceState`) instead of a 3-tuple
- Built-in samplers (`alwaysOn`, `alwaysOff`, `traceIdRatioBased`,
  `parentBased`) still work as smart constructors

**Why:** GHC can case-split on known constructors and inline the decision for
AlwaysOn/Off without going through an indirect call. The scope parameter
satisfies the spec's MUST for `shouldSample` parameters.

**`traceIdRatioBased` behavior change:** Now uses lower 63 bits of the trace ID
(bytes 8-15, big-endian), matching Go/Java/Python SDKs. The description always
follows `TraceIdRatioBased{ratio}` format (previously `traceIdRatioBased 1.0`
returned `alwaysOn` whose description was `"AlwaysOnSampler"`).

### SpanProcessor

```haskell
-- Old
spanProcessorOnStart   :: IORef ImmutableSpan -> Context -> IO ()
spanProcessorOnEnd     :: IORef ImmutableSpan -> IO ()
spanProcessorShutdown  :: IO (Async ShutdownResult)
spanProcessorForceFlush :: IO ()

-- New
spanProcessorOnStart   :: ImmutableSpan -> Context -> IO ()
spanProcessorOnEnd     :: ImmutableSpan -> IO ()
spanProcessorShutdown  :: IO ShutdownResult
spanProcessorForceFlush :: IO FlushResult
```

**Why:** Follows from the `Span` representation change (no top-level `IORef`).
Synchronous shutdown/flush return values allow proper result aggregation.

### SpanExporter

```haskell
-- Old
spanExporterShutdown :: IO ()
-- no forceFlush field

-- New
spanExporterShutdown   :: IO ShutdownResult
spanExporterForceFlush :: IO FlushResult   -- new required field
```

### TracerProviderOptions

```haskell
-- Old
tracerProviderOptionsPropagators :: Propagator Context RequestHeaders RequestHeaders

-- New
tracerProviderOptionsPropagators :: TextMapPropagator
```

**Why:** `TextMap` replaces `RequestHeaders` as the carrier type, removing the
`http-types` dependency from the API package. This is to conform to the OTel spec's updated guidance on the propagator interface. 

New field: `tracerProviderOptionsExceptionHandlers :: [ExceptionHandler]`

**Why:** Exception handlers enable classifying exceptions as Error / Recorded / Ignored per span, with
configurable attribute enrichment.

### TracerOptions

```haskell
-- Old
newtype TracerOptions = TracerOptions { tracerSchema :: Maybe Text }

-- New
data TracerOptions = TracerOptions
  { tracerSchema :: Maybe Text
  , tracerExceptionHandlerOptions :: [ExceptionHandler]
  }
```

Use `tracerOptions` for the default.

### shutdownTracerProvider

```haskell
-- Old
shutdownTracerProvider :: TracerProvider -> m ()

-- New
shutdownTracerProvider :: TracerProvider -> Maybe Int -> m ShutdownResult
```

`Maybe Int` is a timeout in microseconds (default 5 seconds). Subsequent calls
return are idempotent.

### getTracer

```haskell
-- Old (pure)
getTracer :: TracerProvider -> InstrumentationLibrary -> TracerOptions -> Tracer

-- New (monadic, cached)
getTracer :: MonadIO m => TracerProvider -> InstrumentationLibrary -> TracerOptions -> m Tracer
```

**Why:** Per-scope caching avoids re-resolving attribute limits and exception
handlers on every call. Warns on empty library name.

### Context

Internal representation changed from a plain `Vault` to dedicated slots:

```haskell
-- Old
newtype Context = Context Vault

-- New
data Context = Context
  { ctxSpanSlot    :: UMaybe Any
  , ctxBaggageSlot :: UMaybe Baggage
  , ctxVault       :: Vault
  }
```

**Why:** Span and baggage lookups are the overwhelmingly common context
operations. Dedicated slots avoid `Vault` hash lookup overhead.

**Removed exports:** `spanKey`, `baggageKey`.

**Behavior change:** `insertBaggage` now **replaces** the baggage slot instead of
merging. Merging happens via `Context`'s `Semigroup` instance.

### Attach/detach (ThreadLocal)

```haskell
-- Old
attachContext :: Context -> m (Maybe Context)     -- returns previous
detachContext :: m (Maybe Context)                 -- returns previous

-- New
attachContext :: Context -> m Token
detachContext :: Token -> m ()
```

**Why:** Token-based LIFO validation catches mismatched attach/detach (e.g.
from exception paths). Mismatched detach logs a warning and still restores.

This is:

- (a) a spec requirement
- (b) useful for consumers to detect improperly restored contexts

### Propagator / TextMap

- Carrier type changed from `RequestHeaders` to `TextMap` / `TextMapPropagator`
- `propagatorNames` renamed to `propagatorFields` (old name is deprecated alias)
- `extract` and `inject` now catch exceptions internally and log
- Export list is now explicit

**Why:** Removes `http-types` and `case-insensitive` dependencies from the API.
`TextMap` handles case-insensitive key lookup internally.

### Resource (runtime schema)

```haskell
-- Old
newtype Resource (schema :: Maybe Symbol) = Resource Attributes

-- New
data Resource = Resource
  { resourceSchemaUrl  :: Maybe Text
  , resourceAttributes :: Attributes
  }
```

- `ToResource` no longer has `type ResourceSchema a`
- `materializeResources` is an ordinary function, not a typeclass method
- Schema merge is runtime (warning on conflict) instead of compile-time

**Why:** The phantom type parameter required `DataKinds` and offered no real
safety in practice (no library actually set schema URLs in type-level instances).
Other language SDKs all use runtime schema merging.

### InstrumentationScope (new alias)

`InstrumentationScope` is a type alias for `InstrumentationLibrary`.
`instrumentationScope` is the preferred constructor. Old names still work.

### SpanStatus Ord

`compare (Error _) (Error _)` now returns `EQ` instead of `GT`.

### isRecording on FrozenSpan

`isRecording (FrozenSpan _)` now returns `False` (was `True`).

### isValid (SpanContext), bug fix

Fixed: requires both `TraceId` AND `SpanId` to be non-zero (spec). Previously
used `||` instead of `&&`.

### Baggage

- `decodeBaggageHeaderP` (Attoparsec parser) removed in favor of an extremely fast C implementation.
- `InvalidBaggage` now derives `Show, Eq`
- `mkToken` rejects empty strings
- New: `insertChecked` (enforces W3C size limits), `getValue`,
  `maxBaggageBytes` / `maxMemberBytes` / `maxMembers`

### LogRecordExporter.forceFlush

```haskell
-- Old
logRecordExporterArgumentsForceFlush :: IO ()

-- New
logRecordExporterArgumentsForceFlush :: IO FlushResult
```

### ImmutableLogRecord (internal UMaybe)

Fields `logRecordTimestamp`, `logRecordTracingDetails`, `logRecordSeverityText`,
`logRecordSeverityNumber`, and `logRecordEventName` now use `UMaybe` instead of
`Maybe`. External `LogRecordArguments` fields remain as `Maybe`.

### createLoggerProvider

Now monadic: `let provider = ...` should now be `provider <- createLoggerProvider ...`

### loggerIsEnabled

Returns `IO Bool` instead of `Bool`.

### Span post-end mutations

`addAttribute`, `addEvent`, `setStatus`, `updateName` on an ended span are now
no-ops (previously they could mutate through the `IORef`). This matches the
spec requirement.

### SemanticsConfig

- `HttpOption` renamed to `StabilityOpt`
- `SemanticsOptions` is opaque (use `getSemanticsOptions`)
- `OTEL_SEMCONV_STABILITY_OPT_IN` supports `code`, `code/dup` values

### New exception handler system

`ExceptionHandler = SomeException -> Maybe ExceptionResponse` classifies
exceptions as `ErrorException` (default), `RecordedException`, or
`IgnoredException`, optionally adding attributes. Configurable per
`TracerProvider` and per `Tracer`. Includes `exitSuccessHandler` for
`ExitSuccess`.

### Simple processors now export synchronously

`SimpleSpanProcessor` calls `spanExporterExport` in `onEnd` (synchronously on
the calling thread). `SimpleLogRecordProcessor` calls
`logRecordExporterExport` in `onEmit`. Use Batch variants for production.

### Batch processor changes

- `Async ShutdownResult` changed to `IO ShutdownResult` (synchronous wait)
- Shutdown and flush are idempotent (no deadlock on second call)
- Full queues drop silently instead of throwing an exception.
- Worker uses `unagi-chan` with bounded queue (power of two), which is significantly faster than the previous implementation.
- Warns on non-threaded RTS instead of crashing

### Dependency removals from API

`http-types`, `case-insensitive`, `binary`, `bytestring-to-vector`,
`charset`, `regex-tdfa` are no longer dependencies of `hs-opentelemetry-api`.

### Metrics (new modules)

Full metrics API in `OpenTelemetry.Metric.Core`: `MeterProvider`, `Meter`,
`Counter`, `UpDownCounter`, `Histogram`, `Gauge` (sync), observable variants
(async), `AdvisoryParameters`, `Enabled` API. Module path uses singular
`Metric` not `Metrics`.

### TraceFlags

New W3C Level 2 operations: `isRandom`, `setRandom`, `unsetRandom`.

## hs-opentelemetry-sdk

- Depends on `hs-opentelemetry-api ^>= 0.4`
- Metrics SDK: `MeterProvider`, views, exemplars, cardinality, periodic reader
- Logs SDK: `LoggerProvider`, batch/simple processors
- NaN/Inf silently dropped for all metric instrument types (was histograms only)
- Batch processor second shutdown no longer deadlocks
- `detectSpanLimits` reads correct env var names
- `OTEL_SDK_DISABLED=true` no longer disables propagators

## hs-opentelemetry-exporter-otlp

- `Retry-After` parsing supports HTTP-date format
- gRPC transport available for all three signals (traces, metrics, logs) when
  `grpc` Cabal flag is enabled
- `otlpConcurrentExports` config / `OTEL_EXPORTER_OTLP_CONCURRENT_EXPORTS` env var
- `LogRecordExporter.forceFlush` returns `FlushSuccess`
- OTLP field fixes: `droppedAttributesCount` uses dropped (not stored) count,
  `Accept` header instead of `Accept-Encoding`, `Span.flags`/`Link.flags` set
  correctly, severity `Unknown n` no longer crashes on out-of-range

## hs-opentelemetry-exporter-handle

- IDs rendered as hex, not `show`
- Metric exporter added
- Log exporter `forceFlush` returns `FlushResult`

## hs-opentelemetry-exporter-in-memory

- Metric and log exporters added
- `Assertions` module for test convenience
- Log exporter `forceFlush` returns `FlushResult`

## Propagators

### W3C
- `propagatorFields` (was `propagatorNames`)
- TextMap carrier (was `RequestHeaders`)
- Multi-header `tracestate` parsing via comma-combined lookup

### B3
- `b3` and `b3multi` as separate propagator values for registry
- Header constants as `Text` (was `HeaderName`)

### Datadog
- Uses `TextMap` carrier
- `sampling_priority` attribute handling updated

### Jaeger (new package)
- `hs-opentelemetry-propagator-jaeger`
- Trace context via `uber-trace-id`, baggage via `uberctx-*` prefix

### X-Ray (new package)
- `hs-opentelemetry-propagator-xray`
- `X-Amzn-Trace-Id` header

## Instrumentation packages

Most instrumentation packages have updated span names, attribute keys, and
error handling to align with semantic conventions v1.40.0. See individual
package changelogs for details.

## hs-opentelemetry-otlp (proto types)

Breaking wire-format changes: `AnyValue`, `KeyValue` now use proto-lens
directly; profiles protos added. Version bumped to 0.2.0.0.

## hs-opentelemetry-api-types

New leaf package for `Attribute`/`AttributeKey` types, breaking the
`semantic-conventions` ↔ `api` dependency cycle.
