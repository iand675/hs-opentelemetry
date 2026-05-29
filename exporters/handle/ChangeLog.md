# Changelog for hs-opentelemetry-exporter-handle

## Unreleased

## 1.0.0.0 - 2026-05-29

- `OpenTelemetry.Exporter.Handle` barrel now re-exports all three signals (Span, Metric, LogRecord); deprecated annotation removed
- New `OpenTelemetry.Exporter.Handle.LogRecord` module (console log exporter with default formatter)
- New `OpenTelemetry.Exporter.Handle.Metric` module (console metric exporter)

## 0.0.1.3

- Relax `hs-opentelemetry-api` bounds to support 0.3.x

## 0.0.1.2

- Support newer dependencies

## 0.0.1.1

- Cosntrained version bounds more firmly
