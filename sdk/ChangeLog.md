# Changelog for hs-opentelemetry-sdk

## Unreleased

## 0.1.1.0

- Remove `vector-builder` dependency; use vendored `OpenTelemetry.Internal.VectorBuilder` from the API package
- Remove `random` dependency; ID generation now uses C implementation
- Update dependency bounds for hs-opentelemetry-api 0.3.1.0

### Performance

- Default ID generator replaced with C SplitMix64 using `__thread` TLS. Each OS
  thread gets its own PRNG state, eliminating all contention. ~5x faster
  single-threaded (21ns vs 108ns), ~1200x faster under 4-thread contention
  (163μs vs 195ms for 40k IDs). Seeded from RDRAND or getrandom(2).
- Batch processor: `BoundedMap.itemMap` is now strict, preventing thunk
  accumulation in the IORef across CAS retries. Export data is forced before
  leaving the atomicModifyIORef' swap to avoid retaining old batch contents.

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
