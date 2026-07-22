# Changelog for exceptions

## Unreleased

- `inSpanM` and friends now use `recordSomeException` so that on GHC
  9.10+ the `Backtraces` annotation attached by the runtime (e.g. from
  `HasCallStack`) is recorded in `exception.stacktrace`. (#239)

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.2.0.2

- Relax `hs-opentelemetry-api` bounds to support 0.3.x

## 0.2.0.1

- Support newer dependencies

## 0.2.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes
