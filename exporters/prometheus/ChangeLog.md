# Changelog

## Unreleased

- Emit one set of `HELP` and `TYPE` lines per metric family. If types
  conflict, keep the first type. If samples have the same exported labels,
  keep the newest sample.
- Add `otel_scope_*` labels so instrumentation scopes can have distinct
  series. The legacy `job` label is retained. Existing series will have
  new label sets after upgrading.

## 1.0.0.0 - 2026-05-29

- Support `startTimeUnixNano` on all data point types
- Comprehensive Prometheus text rendering tests
- Exponential histogram rendering (approximate `le` labels), exemplar comments on samples.

## 0.1.0.0

- Initial release: Prometheus text rendering for `ResourceMetricsExport`.
