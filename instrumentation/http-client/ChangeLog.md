# Changelog for hs-opentelemetry-instrumentation-http-client

## Unreleased

- **Fix: stable attribute `http.host` → `server.address`.** The stable
  HTTP semantic conventions use `server.address` and `server.port` instead
  of the legacy `http.host`.
- Add `error.type` attribute on HTTP error responses (status >= 400).
- Fix span name to use HTTP method (low-cardinality) instead of full URL.

## 0.1.0.1

- Support newer dependencies

## 0.1.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.2.0

- Added option to name an http request, falling back to the URL as the name of the span if left unnamed
