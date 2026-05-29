# Changelog for hs-opentelemetry-propagator-xray

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.0.1.0

- Initial release.
- Extract and inject `X-Amzn-Trace-Id` header (AWS X-Ray trace context).
- Converts between X-Ray trace ID format (`1-{epoch}-{unique}`) and
  standard 128-bit OpenTelemetry trace IDs.
- Registry integration under the name `"xray"`.
