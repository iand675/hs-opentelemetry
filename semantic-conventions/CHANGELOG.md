# Changelog for hs-opentelemetry-semantic-conventions

## 1.45.0.0 - Unreleased

- Generate against Semantic Conventions 1.45.0 using Weaver 0.28.0 to resolve
  both upstream schema formats, references and inheritance.
- Add 102 attribute keys, including stable `rpc.status_code`, release candidate
  RPC header/trailer templates, Kafka namespace replacements, FaaS invocation
  renames, `system.device.name`, network endpoint and opt-in HTTP body-content keys.
- Preserve all 904 existing exports, their types and their wire names. Updated
  documentation reflects upstream stability and deprecation changes.

## 1.40.0.0 - 2026-05-29

- Generated against OpenTelemetry Semantic Conventions 1.40.0.
- Released as part of the hs-opentelemetry 1.0 release.
