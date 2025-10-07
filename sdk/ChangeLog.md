# Changelog for hs-opentelemetry-sdk

## Unreleased

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
