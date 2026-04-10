# Changelog for hs-opentelemetry-exporter-otlp

## Unreleased

- **Spec: `Retry-After` now supports HTTP-date format in addition to delay-seconds.**
  Previous implementation only parsed integer seconds. Now handles both RFC 7231
  Section 7.1.3 formats. Applied to all three signal exporters (Span, Metric, LogRecord).
  Spec: <https://opentelemetry.io/docs/specs/otlp/#failures>
- **`LogRecordExporter.forceFlush` now returns `FlushSuccess` instead of `()`.**
  Aligns with the updated `LogRecordExporter` type in `hs-opentelemetry-api`.
- **gRPC transport wired for metrics and logs.**
  When the `grpc` Cabal flag is enabled and `OTEL_EXPORTER_OTLP_PROTOCOL=grpc`,
  all three signals (traces, metrics, logs) now use gRPC transport.
  Previously only traces supported gRPC.
- **Concurrent export configuration.**
  New `OTEL_EXPORTER_OTLP_CONCURRENT_EXPORTS` env var and
  `otlpConcurrentExports` config field (default 1).
- **Fix: `droppedAttributesCount` was reporting stored count, not dropped count.**
  All three OTLP exporters (Span, Metric, LogRecord) used `getCount` instead of
  `getDropped` for span attributes, event attributes, link attributes, resource
  attributes, and scope attributes. Now uses `getDropped` everywhere.
- **Fix: `Accept-Encoding` header set to protobuf MIME type.** Changed to `Accept`
  header, which is the correct HTTP header for content-type negotiation.
- **Fix: `Unknown n` severity number could crash with `toEnum` on out-of-range values.**
  Now falls back to `SEVERITY_NUMBER_UNSPECIFIED` for values outside 0–24.
- **Fix: `Span.flags` and `Link.flags` proto fields never set.** The sampled
  bit in W3C trace flags was always 0 in exported OTLP spans and links, even
  when the span was sampled. Now populates `flags` from `traceFlagsValue` on
  both `Span` and `Span.Link` messages (matching the existing log exporter).
- OTLP span exporter: set `schema_url` on `ResourceSpans` and `ScopeSpans`, set scope `attributes` and `droppedAttributesCount`
- `OpenTelemetry.Exporter.OTLP` barrel module now re-exports all three signals (Span, Metric, LogRecord)
- Implement `OpenTelemetry.Exporter.OTLP.LogRecord`: full OTLP HTTP/Protobuf log exporter with retry, compression, and severity/AnyValue/tracing-context serialization
- Use `startTimeUnixNano` from data points instead of hardcoded 0
- Comprehensive protobuf round-trip tests for all metric types
- OTLP metrics: exemplars on number and histogram data points; exponential histogram messages; aggregation temporality from export model.

## 0.1.1.0

- Complete `loadExporterEnvironmentVariables` implementation
- Bump `hs-opentelemetry-otlp` dependency to 0.2

## 0.1.0.1

### Added
- TraceState support in OTLP span export
- Proper encoding of traceState field in OTLP spans and span links
- Full traceState preservation without HTTP header constraints

### Changed
- Span export now includes traceState information from span context
- Span links export now includes traceState information from link context
- Switched to `encodeTraceStateFull` to preserve all traceState entries in binary format

### Dependencies
- Added `hs-opentelemetry-propagator-w3c` dependency for traceState encoding

## 0.1.0.0

- Export dropped span, link, event, and attribute counts
- Add gzip compression support
- Swallow errors from sending data to localhost

## 0.0.1.0

- Initial release
