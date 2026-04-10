# hs-opentelemetry-propagator-jaeger

Jaeger trace context propagation for the
[hs-opentelemetry](https://github.com/iand675/hs-opentelemetry) suite.

Implements the `uber-trace-id` header format and `uberctx-*` baggage
headers as described in the
[Jaeger propagation format](https://www.jaegertracing.io/docs/1.21/client-libraries/#propagation-format).

> **Note:** The Jaeger propagation format is deprecated in favor of
> [W3C Trace Context](https://www.w3.org/TR/trace-context/). Use this
> package for interoperability with legacy systems only.
