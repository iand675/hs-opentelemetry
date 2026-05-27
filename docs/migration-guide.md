# Migration Guide (to 1.0)

Upgrading from 0.3.x (API) / 0.1.x (SDK) and earlier to 1.0.

## hs-opentelemetry-api

### Module renames

Update your imports:

| Old | New |
|-----|-----|
| `OpenTelemetry.Logs.Core` | `OpenTelemetry.Log.Core` |
| `OpenTelemetry.Internal.Logs.Core` | `OpenTelemetry.Internal.Log.Core` |
| `OpenTelemetry.Internal.Logs.Types` | `OpenTelemetry.Internal.Log.Types` |
| `OpenTelemetry.Internal.Metrics.Types` | `OpenTelemetry.Internal.Metric.Types` |
| `OpenTelemetry.Internal.Metrics.Export` | `OpenTelemetry.Internal.Metric.Export` |
| `OpenTelemetry.Metrics` | `OpenTelemetry.Metric.Core` |
| `OpenTelemetry.Metrics.InstrumentName` | `OpenTelemetry.Metric.InstrumentName` |

### Span internals changed

`Span` no longer has a top-level `IORef`. Mutable fields moved to `SpanHot` behind one `IORef`, identity fields sit directly on `Span`:

```haskell
-- Before
data Span = Span (IORef ImmutableSpan) | FrozenSpan SpanContext | Dropped SpanContext

-- After
data Span = Span !ImmutableSpan | FrozenSpan !SpanContext | Dropped !SpanContext
```

`ImmutableSpan` now has: `spanContext`, `spanKind`, `spanStart`, `spanParent`, `spanTracer`, `spanHot :: IORef SpanHot`. `SpanHot` carries `hotName`, `hotEnd`, `hotAttributes`, `hotLinks`, `hotEvents`, `hotStatus`.

This removes an indirection on `getSpanContext`, `isRecording`, etc. Hot-path writes go through `IORef SpanHot` with CAS; cold identity fields need no `IORef` touch.

> [!IMPORTANT]
> If you have custom `SpanProcessor` implementations, update your `onStart`/`onEnd` handlers (see [SpanProcessor](#spanprocessor) below).

### TraceId / SpanId (unboxed)

```haskell
-- Before
newtype TraceId = TraceId ShortByteString
newtype SpanId  = SpanId  ShortByteString

-- After
data TraceId = TraceId !Word64 !Word64
data SpanId  = SpanId  !Word64
```

Two unpacked `Word64`s in registers vs a heap byte array significantly reduces allocation overhead and GC pressure. Hex encoding now uses a C FFI encoder (`hs_otel_hex.c`).

Use `traceIdBytes`, `spanIdBytes`, `bytesToTraceId`, `bytesToSpanId` for raw-byte conversions. `Base` is now `data Base = Base16` only (non-hex encodings removed—file an issue if you need them).

> [!IMPORTANT]
> If you store `TraceId`/`SpanId` in databases or caches, verify your serialization. The `Show` instance still produces hex, but internal representation changed.

### IdGenerator (ADT)

```haskell
-- Before (record)
data IdGenerator = IdGenerator
  { generateSpanIdBytes  :: IO ByteString
  , generateTraceIdBytes :: IO ByteString
  }

-- After (ADT)
data IdGenerator
  = DefaultIdGenerator     -- thread-local xoshiro256++ (zero contention)
  | CustomIdGenerator
      !(IO ShortByteString)  -- 8 bytes for span ID
      !(IO ShortByteString)  -- 16 bytes for trace ID
```

Pattern-matching on `DefaultIdGenerator` lets GHC inline the fast path. The default uses thread-local xoshiro256++ seeded from the platform CSPRNG (no syscalls after seed).

> [!IMPORTANT]
> If you use a custom `IdGenerator`, replace the record constructor:
> ```haskell
> -- Before
> let gen = IdGenerator { generateSpanIdBytes = mySpanGen, generateTraceIdBytes = myTraceGen }
>
> -- After
> let gen = customIdGenerator mySpanGen myTraceGen
> ```

### Timestamp (Word64 nanoseconds)

```haskell
-- Before
newtype Timestamp = Timestamp TimeSpec    -- from clock package

-- After
newtype Timestamp = Timestamp Word64      -- nanoseconds since Unix epoch
```

OTLP uses `fixed64` nanoseconds; this is zero-cost to serialize. FFI call (`hs_otel_gettime_ns`) is ~15ns faster than `System.Clock.getTime` on macOS.

New helpers: `mkTimestamp`, `timestampToNanoseconds`, `OptionalTimestamp`.

### Sampler (ADT with InstrumentationScope)

```haskell
-- Before (record)
data Sampler = Sampler
  { getDescription :: Text
  , shouldSample :: Context -> TraceId -> Text -> SpanArguments
                 -> IO (SamplingResult, AttributeMap, TraceState)
  }

-- After (ADT)
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

Key changes:
- `shouldSample` and `getDescription` are top-level functions, not fields
- `shouldSample` takes an additional `InstrumentationLibrary` parameter (spec requirement)
- Return is `SamplingDecision` (record with `samplingOutcome`, `samplingAttributes`, `samplingTraceState`) instead of a 3-tuple
- Built-in samplers (`alwaysOn`, `alwaysOff`, `traceIdRatioBased`, `parentBased`) still work as smart constructors

> [!IMPORTANT]
> **Custom samplers:**
> 1. Replace `Sampler { ... }` with `CustomSampler description yourFunction`
> 2. Add `InstrumentationLibrary` parameter to your sampling function
> 3. Return `SamplingDecision` instead of `(SamplingResult, AttributeMap, TraceState)`:
>    ```haskell
>    -- Before
>    return (Drop, emptyAttributes, tracestate)
>    
>    -- After
>    return SamplingDecision { samplingOutcome = Drop, samplingAttributes = emptyAttributes, samplingTraceState = tracestate }
>    ```

`traceIdRatioBased` behavior change: now uses lower 63 bits of trace ID (bytes 8-15, big-endian), matching Go/Java/Python SDKs. Description always follows `TraceIdRatioBased{ratio}` format (previously `traceIdRatioBased 1.0` returned `alwaysOn` with description `"AlwaysOnSampler"`).

### SpanProcessor

```haskell
-- Before
spanProcessorOnStart   :: IORef ImmutableSpan -> Context -> IO ()
spanProcessorOnEnd     :: IORef ImmutableSpan -> IO ()
spanProcessorShutdown  :: IO (Async ShutdownResult)
spanProcessorForceFlush :: IO ()

-- After
spanProcessorOnStart   :: ImmutableSpan -> Context -> IO ()
spanProcessorOnEnd     :: ImmutableSpan -> IO ()
spanProcessorShutdown  :: IO ShutdownResult
spanProcessorForceFlush :: IO FlushResult
```

Follows from the `Span` representation change (no top-level `IORef`). Synchronous shutdown/flush return values allow proper result aggregation.

> [!IMPORTANT]
> Update your `SpanProcessor` record definitions. The `onStart`/`onEnd` handlers no longer receive `IORef ImmutableSpan`—use `ImmutableSpan` directly. Change `Async ShutdownResult` to `IO ShutdownResult` and `IO ()` to `IO FlushResult`.

### SpanExporter

```haskell
-- Before
spanExporterShutdown :: IO ()
-- no forceFlush field

-- After
spanExporterShutdown   :: IO ShutdownResult
spanExporterForceFlush :: IO FlushResult   -- new required field
```

> [!IMPORTANT]
> Add a `spanExporterForceFlush` field to your `SpanExporter` records.

### TracerProviderOptions

```haskell
-- Before
tracerProviderOptionsPropagators :: Propagator Context RequestHeaders RequestHeaders

-- After
tracerProviderOptionsPropagators :: TextMapPropagator
```

`TextMap` replaces `RequestHeaders` as the carrier type, dropping the `http-types` dependency from API. Matches spec guidance.

> [!IMPORTANT]
> If you construct `TracerProviderOptions` manually, use `TextMapPropagator` instead of `Propagator Context RequestHeaders RequestHeaders`. The built-in propagators (W3C, B3, etc.) already have `TextMap` variants.

New field: `tracerProviderOptionsExceptionHandlers :: [ExceptionHandler]`

Exception handlers classify exceptions as Error / Recorded / Ignored per span, with configurable attribute enrichment.

### TracerOptions

```haskell
-- Before
newtype TracerOptions = TracerOptions { tracerSchema :: Maybe Text }

-- After
data TracerOptions = TracerOptions
  { tracerSchema :: Maybe Text
  , tracerExceptionHandlerOptions :: [ExceptionHandler]
  }
```

> [!TIP]
> Use `tracerOptions` (smart constructor) for defaults rather than constructing the record directly.

### shutdownTracerProvider

```haskell
-- Before
shutdownTracerProvider :: TracerProvider -> m ()

-- After
shutdownTracerProvider :: TracerProvider -> Maybe Int -> m ShutdownResult
```

`Maybe Int` is timeout in microseconds (default 5 seconds). Subsequent calls are idempotent.

> [!IMPORTANT]
> Add timeout argument to all `shutdownTracerProvider` calls:
> ```haskell
> -- Before
> shutdownTracerProvider provider
>
> -- After
> shutdownTracerProvider provider (Just 5000000)  -- 5 seconds
> ```

### getTracer

```haskell
-- Before (pure)
getTracer :: TracerProvider -> InstrumentationLibrary -> TracerOptions -> Tracer

-- After (monadic, cached)
getTracer :: MonadIO m => TracerProvider -> InstrumentationLibrary -> TracerOptions -> m Tracer
```

Per-scope caching avoids re-resolving attribute limits and exception handlers on every call. Warns on empty library name.

> [!IMPORTANT]
> Change `let` to `<-` and add `MonadIO` constraint:
> ```haskell
> -- Before
> let tracer = getTracer provider lib tracerOptions
>
> -- After
> tracer <- getTracer provider lib tracerOptions
> ```

### Context

Internal representation changed from plain `Vault` to dedicated slots:

```haskell
-- Before
newtype Context = Context Vault

-- After
data Context = Context
  { ctxSpanSlot    :: UMaybe Any
  , ctxBaggageSlot :: UMaybe Baggage
  , ctxVault       :: Vault
  }
```

Span and baggage lookups are the hot paths. Dedicated slots avoid `Vault` hash lookup overhead.

> [!CAUTION]
> **Removed exports:** `spanKey`, `baggageKey`.
>
> **Behavior change:** `insertBaggage` now **replaces** the baggage slot instead of merging. Merging happens via `Context`'s `Semigroup` instance.

> [!IMPORTANT]
> If you were relying on `insertBaggage` merging behavior, use `<>` (the `Semigroup` instance) instead:
> ```haskell
> -- Before (implicitly merged)
> let ctx' = insertBaggage newBaggage ctx
>
> -- After (explicit merge)
> let ctx' = ctx <> insertBaggage newBaggage emptyContext
> ```

### Attach/detach (Token-based)

```haskell
-- Before
attachContext :: Context -> m (Maybe Context)     -- returns previous
detachContext :: m (Maybe Context)                 -- returns previous

-- After
attachContext :: Context -> m Token
detachContext :: Token -> m ()
```

Token-based LIFO validation catches mismatched attach/detach (e.g. from exception paths). Mismatched detach logs a warning and still restores. Spec requirement; helps detect improper context restoration.

> [!IMPORTANT]
> Update all attach/detach call sites to use the token pattern:
> ```haskell
> -- Before
> prev <- attachContext ctx
> -- ... do work ...
> detachContext
>
> -- After
> token <- attachContext ctx
> -- ... do work ...
> detachContext token
> ```
>
> If you were using the returned `Maybe Context` for context switching, you now need to track previous context separately.

### Propagator / TextMap

- Carrier type changed from `RequestHeaders` to `TextMap` / `TextMapPropagator`
- `propagatorNames` renamed to `propagatorFields` (old name deprecated alias)
- `extract` and `inject` now catch exceptions internally and log
- Export list is now explicit

Removes `http-types` and `case-insensitive` dependencies. `TextMap` handles case-insensitive key lookup internally.

> [!IMPORTANT]
> If you have custom propagators using `RequestHeaders`, change to `TextMap`. If you use `propagatorNames`, rename to `propagatorFields`.

### Resource (runtime schema)

```haskell
-- Before
newtype Resource (schema :: Maybe Symbol) = Resource Attributes

-- After
data Resource = Resource
  { resourceSchemaUrl  :: Maybe Text
  , resourceAttributes :: Attributes
  }
```

- `ToResource` no longer has `type ResourceSchema a`
- `materializeResources` is an ordinary function, not a typeclass method
- Schema merge is runtime (warning on conflict) instead of compile-time

The phantom type parameter required `DataKinds` and offered no real safety (no library actually set schema URLs in type-level instances). Other language SDKs use runtime schema merging.

> [!IMPORTANT]
> If you have `ToResource` instances, remove the `ResourceSchema` type synonym. Use `materializeResources` directly instead of as a typeclass method.

### InstrumentationScope (new alias)

`InstrumentationScope` is a type alias for `InstrumentationLibrary`. `instrumentationScope` is the preferred constructor. Old names still work.

### SpanStatus Ord

`compare (Error _) (Error _)` now returns `EQ` instead of `GT`.

### isRecording on FrozenSpan

`isRecording (FrozenSpan _)` now returns `False` (was `True`).

### isValid (SpanContext) - bug fix

Now requires both `TraceId` AND `SpanId` to be non-zero (spec). Previously used `||` instead of `&&`.

> [!IMPORTANT]
> If you were creating `SpanContext` with only one ID set, it will now be invalid. Ensure both trace and span IDs are non-zero.

### Baggage

- `decodeBaggageHeaderP` (Attoparsec parser) removed; now uses a fast C implementation
- `InvalidBaggage` now derives `Show, Eq`
- `mkToken` rejects empty strings
- New: `insertChecked` (enforces W3C size limits), `getValue`, `maxBaggageBytes` / `maxMemberBytes` / `maxMembers`

### LogRecordExporter.forceFlush

```haskell
-- Before
logRecordExporterArgumentsForceFlush :: IO ()

-- After
logRecordExporterArgumentsForceFlush :: IO FlushResult
```

> [!IMPORTANT]
> Update your `LogRecordExporter` records to return `FlushResult` instead of `()`.

### ImmutableLogRecord (internal UMaybe)

Fields `logRecordTimestamp`, `logRecordTracingDetails`, `logRecordSeverityText`, `logRecordSeverityNumber`, and `logRecordEventName` now use `UMaybe` instead of `Maybe`. External `LogRecordArguments` fields remain as `Maybe`.

### createLoggerProvider

Now monadic: `let provider = ...` should become `provider <- createLoggerProvider ...`

> [!IMPORTANT]
> Add `MonadIO` constraint and use bind syntax.

### loggerIsEnabled

Returns `IO Bool` instead of `Bool`.

> [!TIP]
> Add `liftIO` or use in `IO` context.

### Span post-end mutations

`addAttribute`, `addEvent`, `setStatus`, `updateName` on an ended span are now no-ops (previously they could mutate through the `IORef`). Matches spec requirement.

### SemanticsConfig

- `HttpOption` renamed to `StabilityOpt`
- `SemanticsOptions` is opaque (use `getSemanticsOptions`)
- `OTEL_SEMCONV_STABILITY_OPT_IN` supports `code`, `code/dup` values

### Exception handler system

`ExceptionHandler = SomeException -> Maybe ExceptionResponse` classifies exceptions as `ErrorException` (default), `RecordedException`, or `IgnoredException`, optionally adding attributes. Configurable per `TracerProvider` and per `Tracer`. Includes `exitSuccessHandler` for `ExitSuccess`.

### Simple processors now export synchronously

`SimpleSpanProcessor` calls `spanExporterExport` in `onEnd` (synchronously on the calling thread). `SimpleLogRecordProcessor` calls `logRecordExporterExport` in `onEmit`. Use Batch variants for production.

> [!TIP]
> If you need async export, switch to `BatchSpanProcessor`.

### Batch processor changes

- `Async ShutdownResult` changed to `IO ShutdownResult` (synchronous wait)
- Shutdown and flush are idempotent (no deadlock on second call)
- Full queues drop silently instead of throwing
- Worker uses `unagi-chan` with bounded queue (power of two), faster than previous implementation
- Warns on non-threaded RTS instead of crashing

### Dependency removals from API

`http-types`, `case-insensitive`, `binary`, `bytestring-to-vector`, `charset`, `regex-tdfa` are no longer dependencies of `hs-opentelemetry-api`.

> [!IMPORTANT]
> If you used any of these through the `hs-opentelemetry-api` package, add them as direct dependencies to your cabal/stack files.

### Metrics (new modules)

Full metrics API in `OpenTelemetry.Metric.Core`: `MeterProvider`, `Meter`, `Counter`, `UpDownCounter`, `Histogram`, `Gauge` (sync), observable variants (async), `AdvisoryParameters`, `Enabled` API. Module path uses singular `Metric` not `Metrics`.

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
- gRPC transport available for all three signals (traces, metrics, logs) when `grpc` Cabal flag is enabled
- `otlpConcurrentExports` config / `OTEL_EXPORTER_OTLP_CONCURRENT_EXPORTS` env var
- `LogRecordExporter.forceFlush` returns `FlushSuccess`
- OTLP field fixes: `droppedAttributesCount` uses dropped (not stored) count, `Accept` header instead of `Accept-Encoding`, `Span.flags`/`Link.flags` set correctly, severity `Unknown n` no longer crashes on out-of-range

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

All instrumentation updated to OpenTelemetry semantic conventions v1.40.0. This section covers attribute renames and the `OTEL_SEMCONV_STABILITY_OPT_IN` compatibility mechanism.

### `OTEL_SEMCONV_STABILITY_OPT_IN`

Several signals (HTTP, database, code source location, messaging) renamed attributes between the "old" semconv era and the stabilized v1.x names. Instrumentation libraries check this env var so backends and dashboards can migrate independently.

```
# Values are comma-separated; /dup suffix emits both old and new
OTEL_SEMCONV_STABILITY_OPT_IN=http,database,code
```

| Value | Meaning |
|-------|---------|
| *(unset)* | Old (legacy) attribute names — **default** |
| `http` | Stable HTTP attribute names only |
| `http/dup` | Both old and stable HTTP names (for gradual dashboard migration) |
| `database` | Stable database attribute names only |
| `database/dup` | Both old and stable database names |
| `code` | Stable code source-location attribute names only |
| `code/dup` | Both old and stable code names |
| `messaging` | Stable messaging attribute names only |
| `messaging/dup` | Both old and stable messaging names |

Combine values: `OTEL_SEMCONV_STABILITY_OPT_IN=http/dup,database`.

The env var is read once at startup (cached). In tests use `getSemanticsOptions'` for per-call evaluation.

> [!TIP]
> **Migration strategy:**
> 1. Start with `OTEL_SEMCONV_STABILITY_OPT_IN=http/dup,database,code,messaging` to emit both old and new names
> 2. Update your dashboards, alerts, and aggregations to use the stable names (check attribute tables below)
> 3. Once fully migrated, switch to `OTEL_SEMCONV_STABILITY_OPT_IN=http,database,code,messaging` for stable names only
> 4. Eventually remove the env var entirely once all consumers are updated

### HTTP attribute renames (`wai`, `http-client`)

| Old (default) | Stable (`http` / `http/dup`) | Packages |
|---------------|------------------------------|----------|
| `http.method` | `http.request.method` | wai, http-client |
| `http.url` | `url.full` | http-client |
| `http.target` | `url.path` + `url.query` | wai, http-client |
| `http.host` | `server.address` | http-client |
| `http.scheme` | `url.scheme` | wai, http-client |
| `http.flavor` | `network.protocol.version` | wai, http-client |
| `http.status_code` | `http.response.status_code` | wai, http-client |
| `net.peer.ip` / `net.peer.name` | `client.address` | wai |
| `net.peer.port` | `client.port` | wai |
| *(not emitted)* | `server.address`, `server.port` | wai |
| *(not emitted)* | `error.type` (on 5xx) | wai |

WAI and http-client **metrics** modules always use stable attribute names (metrics are new—no legacy metric names to migrate from).

> [!TIP]
> **Dashboard updates needed:** If you query `http.method`, `http.url`, `http.target`, `http.host`, `http.scheme`, `http.flavor`, `http.status_code`, `net.peer.ip`, `net.peer.name`, or `net.peer.port`, update to the stable equivalents.

### Database attribute renames (`postgresql-simple`, `persistent`, `persistent-mysql`)

| Old (default) | Stable (`database` / `database/dup`) | Packages |
|---------------|--------------------------------------|----------|
| `db.system` | `db.system.name` | all |
| `db.name` | `db.namespace` | all |
| `db.statement` | `db.query.text` | postgresql-simple, persistent |
| `db.user` | *(dropped — security)* | postgresql-simple |
| `net.peer.name` / `net.peer.ip` | `server.address` | postgresql-simple |
| `net.peer.port` | `server.port` | postgresql-simple |
| *(not emitted)* | `db.operation.name` | postgresql-simple, persistent |

> [!TIP]
> **Dashboard updates needed:** Update queries for `db.system` → `db.system.name`, `db.name` → `db.namespace`, `db.statement` → `db.query.text`. The `db.user` attribute is removed entirely (security consideration). New `db.operation.name` attribute available in stable mode.

### Messaging attribute renames (`hw-kafka-client`)

| Old (default) | Stable (`messaging` / `messaging/dup`) |
|---------------|----------------------------------------|
| `messaging.operation` | `messaging.operation.name` + `messaging.operation.type` |
| `messaging.kafka.consumer.group` | `messaging.consumer.group.name` |

The Kafka-specific `messaging.kafka.*` attributes (`messaging.kafka.message.key`, `messaging.kafka.destination.partition`, `messaging.kafka.message.offset`) are emitted under both schemes as they have no generic equivalents.

> [!TIP]
> **Dashboard updates needed:** If you group/filter by `messaging.operation`, update to use both `messaging.operation.name` and `messaging.operation.type`. Update `messaging.kafka.consumer.group` references to `messaging.consumer.group.name`.

### Code source-location attribute renames (all spans)

The `callerAttributes` call site injection (used by `inSpan`, `inSpan'`, etc.) and logging bridges (`katip`, `co-log`, `monad-logger`) respect `code` / `code/dup`:

| Old (default) | Stable (`code` / `code/dup`) |
|---------------|------------------------------|
| `code.function` + `code.namespace` | `code.function.name` |
| `code.filepath` | `code.file.path` |
| `code.lineno` | `code.line.number` |

> [!TIP]
> **Dashboard updates needed:** The separate `code.function` and `code.namespace` fields merge into a single `code.function.name` in stable mode. Update `code.filepath` → `code.file.path` and `code.lineno` → `code.line.number`.

### Yesod — `http.framework` → `webengine.name` (breaking)

Yesod emitted `http.framework = "yesod"` in the old semconv era. The stable equivalent is `webengine.name = "yesod"`. This rename is gated on `httpOption`:

- Default (unset `http`): `http.framework = "yesod"`
- `http` opt-in: `webengine.name = "yesod"`
- `http/dup`: both attributes emitted

> [!TIP]
> If you filter or alert on `http.framework`, set `OTEL_SEMCONV_STABILITY_OPT_IN=http/dup` during transition and update dashboards to use `webengine.name` before switching to `http`.

## hs-opentelemetry-otlp (proto types)

Breaking wire-format changes: `AnyValue`, `KeyValue` now use proto-lens directly; profiles protos added. Version bumped to 0.2.0.0.

## hs-opentelemetry-api-types

New leaf package for `Attribute`/`AttributeKey` types, breaking the `semantic-conventions` <-> `api` dependency cycle.
