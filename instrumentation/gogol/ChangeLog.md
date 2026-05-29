# Changelog for hs-opentelemetry-instrumentation-gogol

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.1.0.0

- Initial release
- `tracedSend` and `tracedSendEither` wrappers for Gogol API calls
- RPC semantic convention attributes (rpc.system, rpc.service, rpc.method)
- GCP cloud provider attribute
- Error recording with HTTP status codes
