# Changelog for hs-opentelemetry-propagator-w3c

## Unreleased

### Added
- Complete W3C tracestate header parsing and encoding support
- `tracestateParser` for parsing W3C tracestate headers according to specification
- `encodeTraceState` function for serializing TraceState to W3C format
- `encodeTraceStateFull` for serializing complete TraceState without HTTP header limits
- `encodeTraceStateMultiple` for splitting TraceState into multiple headers with size constraints
- `decodeTraceStateMultiple` for combining multiple tracestate headers per RFC7230
- Proper validation of tracestate keys and values per W3C spec
- Support for up to 32 tracestate entries as per specification
- Multi-tenant key format support (`tenant@vendor`)
- Automatic removal of oversized entries (>128 chars) as per W3C truncation guidance
- RFC7230-compliant header field combining with comma separation
- Comprehensive test coverage for tracestate functionality

### Changed
- `encodeSpanContext` now includes tracestate in returned tuple
- `decodeSpanContext` now properly decodes and validates tracestate headers

### Dependencies
- Added `text` dependency for tracestate text processing

## 0.0.1.4

- Support newer dependencies

## 0.0.1.1

- Update to hs-opentelemetry-api == 0.0.2.*

## 0.0.1.0

- Initial release
