# Changelog for hs-opentelemetry-instrumentation-conduit

## Unreleased

- Use `recordSomeException` in the streaming `inSpan` exception
  handler so `exception.stacktrace` is populated from the runtime-attached
  `Backtraces` annotation on GHC 9.10+. (#239)

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.1.0.2

- Relax `hs-opentelemetry-api` bounds to support 0.3.x

## 0.1.0.1

- Support newer dependencies

## 0.1.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes
