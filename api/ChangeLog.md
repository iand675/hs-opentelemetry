# Changelog for hs-opentelemetry-api

## Unreleased

## 0.3.1.0

- Add `tracerIsEnabled` function to check if a Tracer is enabled (helps avoid expensive operations when tracing is disabled)
- Add `noopSpan` as an exported sentinel for use in disabled paths

### Zero-overhead inert path

When no processors are configured (i.e. the SDK is not initialized), `inSpan`,
`inSpan'`, `inSpan''`, `createSpan`, and `createSpanWithoutCallStack` now
short-circuit immediately — skipping all of:

- `callerAttributes` computation (HashMap allocation from source locations)
- `bracketError` / `mask` / `try` (RTS exception state transitions)
- Thread-local context lookup and update (`getContext`, `adjustContext` ×2)
- Span/Trace ID generation
- `SpanContext` allocation
- Vault lookups

The inert code path is now a single branch on `V.null processors` returning a
top-level CAF `noopSpan`, giving effectively zero overhead.

### Active tracing path optimizations

- `addAttribute` count tracking reduced from O(n) (`H.size`) to O(log n)
  (`H.member`) per insertion.
- Span creation avoids an intermediate HashMap allocation: `H.unions` of three
  maps replaced with `H.insert` + `H.union`.
- `SpanArguments.attributes` is now a lazy field. `callerAttributes` (which
  builds a 5-entry HashMap from source locations via `T.pack`) is deferred
  past the sampling decision — when the sampler drops a span, the HashMap is
  never constructed.

### Dependency reductions

Removed 6 non-boot dependencies from the API package:

- `memory`: replaced with vendored Base16 hex encoding via C FFI
- `attoparsec`: replaced with hand-written ByteString parser for baggage headers
- `charset`: replaced with simple byte-level predicates
- `regex-tdfa`: replaced with hand-written parser for `parseInstrumentationLibrary`
- `safe-exceptions`: replaced with `Control.Exception` equivalents
- `vector-builder`: vendored as `OpenTelemetry.Internal.VectorBuilder`

### Performance

- Base16 encoding of TraceId/SpanId now uses C FFI with a 256-entry lookup table
  and fully-unrolled loops for the fixed 16-byte and 8-byte sizes. ShortByteString
  encoding uses `keepAlive#`/`byteArrayContents#` to avoid intermediate copies.
  ~34% faster for TraceId, ~23% faster for SpanId vs the previous Haskell implementation.

### API changes

- `decodeBaggageHeaderP` now returns `Parser Baggage` (the internal parser type)
  instead of `Data.Attoparsec.ByteString.Char8.Parser Baggage`. The `Parser` type
  and its `runParser` field are exported from `OpenTelemetry.Baggage` for composition.
- `Base` type is now defined in `OpenTelemetry.Internal.Trace.Encoding` instead of
  re-exported from `memory`. Only `Base16` is supported.

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
