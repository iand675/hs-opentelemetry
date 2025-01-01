# Changelog for hs-opentelemetry-instrumentation-http-client

## 0.1.0.1

- Support newer dependencies

### Breaking changes

- Use `managerModifyRequest` and `managerModifyResponse` to implement this instrumentation

## 0.1.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.2.0

- Added option to name an http request, falling back to the URL as the name of the span if left unnamed
