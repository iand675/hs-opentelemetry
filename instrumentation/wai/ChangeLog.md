# Changelog for hs-opentelemetry-instrumentation-wai

## Unreleased

- **Fix: initial span name is now low-cardinality.** Previously used `{method} {raw_path}`
  which includes IDs, UUIDs, etc. Now uses just `{method}` (e.g. `GET`) until a framework
  sets the `http.route` attribute, at which point the name updates to `{method} {route}`.
- Add `error.type` attribute on 5xx responses (required by stable HTTP server conventions).
- Default `server.port` to 80/443 (based on scheme) when `Host` header omits port.

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
