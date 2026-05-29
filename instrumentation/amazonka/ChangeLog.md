# Changelog for hs-opentelemetry-instrumentation-amazonka

## 1.0.0.0 - 2026-05-29

- Promoted to 1.0.0.0 for the hs-opentelemetry 1.0 release.

## 0.1.0.0

* Initial release
* Hooks-based automatic tracing for all Amazonka `send` calls
* `instrumentEnv` to add tracing hooks to an Amazonka `Env`
* AWS SDK semantic convention attributes (rpc.system, rpc.service, rpc.method, aws.request_id)
* HTTP response attributes (http.response.status_code)
* Error recording on failed AWS calls
