# Changelog for otlp

## Unreleased

- Switch protobuf code generation from `proto-lens` to
  [`wireform-proto`](https://github.com/iand675/wireform-). The generated
  modules are now plain Haskell records (with `default<Type>` values) rather
  than the lens-based `proto-lens` API, and live under the
  `Proto.OpenTelemetry.Proto.*` module hierarchy. Encoding/decoding is provided
  by `Proto.Encode`/`Proto.Decode`.
- Because `wireform-proto` (via `wireform-core`) requires `base >= 4.18`, this
  package now requires GHC 9.6 or newer.
- The regeneration workflow no longer needs `protoc`/`proto-lens-protoc`; the
  bundled `hs-opentelemetry-otlp-gen` executable (behind the `codegen` flag)
  drives `wireform-proto`'s code generator.

## 1.0.0.0 - 2026-05-29

- Update to OTLP specification v1.10.0 (profiles: reference-based attributes, common: ref→strindex rename)
- Fix `generate-modules.sh` for macOS compatibility (BSD tar/sed/xargs)

## 0.2.0.0

- Support OTLP specification v1.9.0

## 0.1.1.0

- Support OTLP specification v1.7

## 0.1.0.0

Support OTLP specification v1.0.0

## 0.0.1.2

Support additional status codes (408, 5xx) as transient & able to retry

## 0.0.1.0

Initial release
