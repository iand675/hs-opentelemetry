# Changelog for hs-opentelemetry-instrumentation-monad-logger

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.1.0.0

- Initial release.
- Provides `makeOTelLogCallback` for use with `runLoggingT`.
- Severity mapping: `LevelDebug`→`Debug`, `LevelInfo`→`Info`, `LevelWarn`→`Warn`,
  `LevelError`→`Error`, `LevelOther t`→`Info` (with original level name in
  `severityText`).
- Template Haskell source location emitted as `code.filepath`, `code.function.name`,
  and `code.lineno` attributes.
- Logger source tag emitted as `log.source` attribute when non-empty.
