# Changelog for hs-opentelemetry-api

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
