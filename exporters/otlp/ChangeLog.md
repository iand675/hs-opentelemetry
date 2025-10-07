# Changelog for hs-opentelemetry-exporter-otlp

## Unreleased

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
