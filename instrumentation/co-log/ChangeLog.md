# Changelog for hs-opentelemetry-instrumentation-co-log

## 0.1.0.0

- Initial release.
- Provides `otelLogAction` for co-log's standard `Message` type and
  `otelLogActionWith` for arbitrary message types.
- Severity mapping: `Debug`→`Debug`, `Info`→`Info`, `Warning`→`Warn`,
  `Error`→`Error`.
- Call-stack source location emitted as `code.filepath`, `code.function.name`,
  and `code.lineno` attributes.
