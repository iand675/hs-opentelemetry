# Changelog for hs-opentelemetry-instrumentation-ghc-metrics

## 0.1.0.0

- Initial release.
- `OpenTelemetry.Instrumentation.GHCMetrics`: registers GHC RTS statistics as
  `process.runtime.ghc.*` metrics (requires `+RTS -T`).
- `OpenTelemetry.Instrumentation.ProcessMetrics`: registers OS-level process metrics
  following OTel semantic conventions (`process.cpu.time`, `process.memory.usage`,
  `process.disk.io`, etc.). Linux-only metrics (page faults, context switches,
  file descriptor count, thread count) require `/proc` filesystem.
- Attribute keys follow OTel semantic conventions: `cpu.mode`, `disk.io.direction`,
  `system.paging.fault.type`, `process.context_switch.type`.
