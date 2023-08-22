# Changelog for hs-opentelemetry-instrumentation-http-client

## Unreleased changes

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.2.0

- Added option to name an http request, falling back to the URL as the name of the span if left unnamed
