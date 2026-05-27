# Changelog for hs-opentelemetry-instrumentation-katip

## 0.1.0.0

- Initial release.
- Provides a Katip `Scribe` that forwards log items to the OpenTelemetry Logs pipeline.
- Severity mapping: `DebugS`→`Debug`, `InfoS`→`Info`, `WarningS`→`Warn`,
  `ErrorS`→`Error`, `CriticalS`/`AlertS`/`EmergencyS`→`Fatal` variants.
- Structured Katip payloads serialised as `log.payload.*` attributes.
- Standard OTel attributes emitted: `thread.id`, `server.address`, `process.pid`,
  `code.filepath`, `code.function.name`, `code.lineno`, `katip.namespace`.
