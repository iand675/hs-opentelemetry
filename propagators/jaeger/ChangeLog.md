# Changelog for hs-opentelemetry-propagator-jaeger

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.0.1.0

- Initial release.
- Extract and inject `uber-trace-id` (Jaeger trace context) header.
- Extract and inject `uberctx-*` (Jaeger baggage) headers.
- Registry integration under the name `"jaeger"`.
