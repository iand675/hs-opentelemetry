# Changelog for hs-opentelemetry-propagator-xray

## 0.0.1.0

- Initial release.
- Extract and inject `X-Amzn-Trace-Id` header (AWS X-Ray trace context).
- Converts between X-Ray trace ID format (`1-{epoch}-{unique}`) and
  standard 128-bit OpenTelemetry trace IDs.
- Registry integration under the name `"xray"`.
