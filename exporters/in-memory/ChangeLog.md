# Changelog for hs-opentelemetry-exporter-in-memory

## Unreleased

- `OpenTelemetry.Exporter.InMemory` barrel now re-exports all three signals (Span, Metric, LogRecord); deprecated annotation removed
- New `OpenTelemetry.Exporter.InMemory.LogRecord` module (in-memory log exporter for testing)
- New `OpenTelemetry.Exporter.InMemory.Metric` module (in-memory metric exporter for tests)

## 0.0.1.2 

- Support newer dependencies

## 0.0.1.1

- Support hs-opentelemetry-api-0.0.2.0

## 0.0.1.0

- Initial release
