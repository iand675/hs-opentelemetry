# Changelog for hs-opentelemetry-propagator-datadog

## Unreleased

- Fix: extractor now derives `traceFlags` from `x-datadog-sampling-priority` header.
  Previously always set `TraceFlags 1` (sampled) regardless of the priority value.
  Priority <= 0 now correctly yields unsampled `TraceFlags 0`.
- Fix: negative sampling priorities (e.g. `-1` for user reject) now parsed correctly.
  Previously `charToDigit` couldn't handle the `-` sign; replaced with `readMaybe`.
- Fix: injector now falls back to `traceFlags` when `x-datadog-sampling-priority` is
  absent from `TraceState`, emitting `"0"` for unsampled spans. Previously always
  defaulted to `"1"`.

## 0.0.1.1

- Update dependency bounds for hs-opentelemetry-api 0.3.0.0

## 0.0.1.0

- Initial release
