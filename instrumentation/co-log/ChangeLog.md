# Changelog for hs-opentelemetry-instrumentation-co-log

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.1.0.0

- Initial release.
- Provides `otelLogAction` for co-log's standard `Message` type and
  `otelLogActionWith` for arbitrary message types.
- Severity mapping: `Debug`→`Debug`, `Info`→`Info`, `Warning`→`Warn`,
  `Error`→`Error`.
- Call-stack source location emitted as `code.filepath`, `code.function.name`,
  and `code.lineno` attributes.
