# Changelog for hs-opentelemetry-instrumentation-wai

## 0.1.1

- Bracket WAI middleware spans with detachChontext (#116).

## 0.1.0.0

### Breaking changes

- Change a type of `newOpenTelemetryWaiMiddleware'` from `TracerProvider -> IO Middleware` to `TracerProvider -> Middleware` #86
- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.1.1

- Bump version bounds for hs-opentelemetry-api to == 0.0.2.0

## 0.0.1.0

- Initial release
