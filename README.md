<p align="center">
  <a href="https://opentelemetry.io">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/cncf/artwork/main/projects/opentelemetry/horizontal/white/opentelemetry-horizontal-white.svg">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/cncf/artwork/main/projects/opentelemetry/horizontal/color/opentelemetry-horizontal-color.svg">
      <img alt="OpenTelemetry" src="https://raw.githubusercontent.com/cncf/artwork/main/projects/opentelemetry/horizontal/color/opentelemetry-horizontal-color.svg" width="400">
    </picture>
  </a>
</p>

<h2 align="center">OpenTelemetry for Haskell</h2>

<p align="center">
  <em>Traces, metrics, and logs for Haskell applications and libraries</em>
</p>

<p align="center">
  <a href="https://hackage.haskell.org/package/hs-opentelemetry-api"><img alt="Hackage" src="https://img.shields.io/hackage/v/hs-opentelemetry-api?style=flat-square&logo=haskell&label=api"></a>
  <a href="https://hackage.haskell.org/package/hs-opentelemetry-sdk"><img alt="Hackage" src="https://img.shields.io/hackage/v/hs-opentelemetry-sdk?style=flat-square&logo=haskell&label=sdk"></a>
  <img alt="GHC" src="https://img.shields.io/badge/GHC-9.4_|_9.6_|_9.8_|_9.10_|_9.12-blue?style=flat-square&logo=haskell">
  <a href="https://github.com/iand675/hs-opentelemetry/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square"></a>
  <a href="https://github.com/sponsors/iand675"><img alt="Sponsor" src="https://img.shields.io/github/sponsors/iand675?style=flat-square&label=sponsor&color=ea4aaa"></a>
</p>

---

## In Brief

**hs-opentelemetry** is a native Haskell implementation of
[OpenTelemetry](https://opentelemetry.io), the vendor-neutral observability
standard backed by the CNCF. It lets you instrument your Haskell code to emit

- **[Traces](#traces)** — distributed request flows across services
- **[Metrics](#metrics)** — counters, histograms, and gauges
- **[Logs](#logs)** — structured log records correlated with traces

and export them to any OpenTelemetry-compatible backend (Jaeger, Honeycomb,
Datadog, Grafana, etc.) without coupling your code to a specific vendor.

The project follows the upstream [OpenTelemetry
specification](https://opentelemetry.io/docs/specs/otel/) closely, with a clean
separation between the **API** (for library authors) and the **SDK** (for
application authors) — the same split used by the official Go, Python, and Java
implementations.

## Why Instrument with OpenTelemetry?

If you've ever added `putStrLn`-based debugging to track down why a request was
slow, or scattered ad-hoc metrics across your codebase, you've felt the problem
OpenTelemetry solves.

**Without OpenTelemetry**, observability in Haskell tends to look like:

```haskell
handleRequest req = do
  t0 <- getCurrentTime
  putStrLn $ "Processing " <> show (requestPath req)
  result <- processRequest req
  t1 <- getCurrentTime
  putStrLn $ "Done in " <> show (diffUTCTime t1 t0)
  pure result
```

This doesn't compose. It doesn't correlate across services. It doesn't let you
switch from stdout to Datadog to Honeycomb without rewriting your code. And it
pollutes your business logic with observability concerns.

**With hs-opentelemetry**, the same intent becomes:

```haskell
handleRequest req =
  inSpan tracer "handleRequest" defaultSpanArguments $ do
    processRequest req
```

One line. The span carries timing, a unique trace ID that correlates across
service boundaries, and you can attach structured attributes to it. The SDK
decides *where* the data goes — stdout in development, OTLP to your collector in
production — and your application code doesn't change.

## Getting Started

There are two packages to know about:

| You are... | Use |
|---|---|
| **Instrumenting a library** (e.g., a database driver, HTTP client wrapper) | [`hs-opentelemetry-api`](api/) |
| **Building an application** that configures and exports telemetry | [`hs-opentelemetry-sdk`](sdk/) |

Library authors depend on the API so their users aren't forced into a particular
SDK configuration. Application authors pull in the SDK, which initializes
providers, installs exporters, and wires everything together.

### Traces

Traces represent the path of a request through your system. Each unit of work
is a **span**; spans nest to form a tree.

```haskell
import OpenTelemetry.Trace (withTracerProvider, getTracer, tracerOptions)
import OpenTelemetry.Trace.Core (inSpan, defaultSpanArguments)

main :: IO ()
main = withTracerProvider $ \tp -> do
  let tracer = getTracer tp "my-service" tracerOptions
  inSpan tracer "main" defaultSpanArguments $ do
    inSpan tracer "step-1" defaultSpanArguments $
      putStrLn "doing work"
    inSpan tracer "step-2" defaultSpanArguments $
      putStrLn "more work"
```

`withTracerProvider` reads standard `OTEL_*` environment variables (service
name, exporter endpoint, sampling rate, etc.), initializes the global provider,
and shuts it down cleanly on exit — including flushing any buffered spans.

Use `inSpan'` when you need access to the `Span` handle, for example to attach
attributes during execution:

```haskell
inSpan' tracer "fetchUser" defaultSpanArguments $ \span -> do
  user <- lookupUser uid
  addAttribute span "user.id" (toAttribute uid)
  pure user
```

### Metrics

Metrics capture measurements over time: request counts, latencies, queue depths.

```haskell
import OpenTelemetry.Metric.Core

main :: IO ()
main = do
  mp    <- getGlobalMeterProvider
  meter <- getMeter mp "my-service"

  counter <- meterCreateCounterInt64 meter
    "http.requests" "" Nothing defaultAdvisoryParameters
  latency <- meterCreateHistogram meter
    "http.request.duration" "ms" Nothing defaultAdvisoryParameters

  -- In your request handler:
  counterAdd counter 1 [("method", toAttribute ("GET" :: Text))]
  histogramRecord latency 42.5 [("method", toAttribute ("GET" :: Text))]
```

The SDK supports synchronous instruments (counters, histograms, up-down
counters) and asynchronous/observable instruments for system-level metrics like
GHC runtime statistics:

```haskell
import OpenTelemetry.Instrumentation.GHCMetrics (registerGHCMetrics)

meter <- getMeter mp "ghc-metrics"
registerGHCMetrics meter
-- GC pause times, allocation rates, thread counts, etc. are now exported
```

### Logs

The logging API is a *bridge*: it lets existing Haskell logging libraries
(katip, co-log, monad-logger) emit structured log records that are
automatically correlated with the active trace context.

```haskell
import OpenTelemetry.Log (withLoggerProvider, makeLogger)
import OpenTelemetry.Log.Core (emitLogRecord, LogRecordArguments(..), SeverityNumber(..))

main :: IO ()
main = withLoggerProvider $ \lp -> do
  let logger = makeLogger lp "my-app"
  emitLogRecord logger $ emptyLogRecordArguments
    { body           = Just (toValue ("Application started" :: Text))
    , severityNumber = Just SeverityNumberInfo
    }
```

Or use one of the bridge libraries to connect your existing logging framework:

| Logger | Bridge |
|---|---|
| katip | [`hs-opentelemetry-instrumentation-katip`](instrumentation/katip) |
| co-log | [`hs-opentelemetry-instrumentation-co-log`](instrumentation/co-log) |
| monad-logger | [`hs-opentelemetry-instrumentation-monad-logger`](instrumentation/monad-logger) |

### WAI Middleware

For web applications, a single line of middleware instruments every incoming
HTTP request:

```haskell
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMiddleware <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMiddleware myApp
```

Each request gets a server span with method, route, status code, and timing.
Downstream calls (database queries, HTTP clients) automatically nest as child
spans when you use the corresponding instrumentation libraries.

## Specification Conformance

Traces, metrics, and logs are fully implemented. See the detailed [conformance
checklist](spec-compliance.md) for per-feature coverage against the
OpenTelemetry specification.

| Signal | API Module | SDK Module | Status |
|---|---|---|---|
| Traces | `OpenTelemetry.Trace.Core` | `OpenTelemetry.Trace` | Stable |
| Metrics | `OpenTelemetry.Metric.Core` | `OpenTelemetry.MeterProvider` | Stable |
| Logs | `OpenTelemetry.Log.Core` | `OpenTelemetry.Log` | Stable |

## Performance

The library is designed for minimal overhead in instrumented applications. When
the SDK is not installed or has no processors configured, `inSpan` is a no-op
that costs **13.6 ns** and allocates **15 bytes**.

Benchmarks (GHC 9.10, aarch64-osx, `-O1 -N1 -A32m`):

| Operation | Time | Allocated |
|---|---|---|
| `inSpan` no-op (no SDK) | 13.6 ns | 15 B |
| `inSpan` active | 218–445 ns | 1.2–2.5 KB |
| bare span (create+end) | 209 ns | 1.2 KB |
| HTTP span (3 attrs) | 410 ns | 2.5 KB |
| DB span (5 attrs) | 520 ns | 3.3 KB |
| `getContext` | 2.9 ns | 15 B |
| `lookupSpan` | 0.6 ns | 0 B |

For comparison, bare span create+end on the same workload (no attributes,
AlwaysSample) is ~279 ns in the [Go
SDK](https://github.com/open-telemetry/opentelemetry-go/pull/6730) and ~349 ns
in the [Rust
SDK](https://github.com/open-telemetry/opentelemetry-rust/pull/1101).
Cross-language numbers are from different machines, so ratios are approximate.

<details>
<summary><strong>Key design choices for low overhead</strong></summary>

- Unboxed `Word64` trace/span IDs (no heap-allocated byte arrays)
- Thread-local xoshiro256++ RNG in C (no contention, no syscalls after seed)
- Direct `clock_gettime` FFI for timestamps (no `alloca`/`errno` overhead)
- Dedicated context slots for span and baggage (O(1), no `Vault` lookup)
- No-op fast path skips `mask`, context writes, and ID generation entirely
- `INLINE` on hot-path functions with case-of-case optimization for samplers

Run `make bench.save` to establish a baseline on your machine, then
`make bench.check` after changes to catch regressions above 20%.

</details>

## Package Ecosystem

### Instrumentation Libraries

| Library | Package | Signals |
|---|---|---|
| wai | [hs-opentelemetry-instrumentation-wai](instrumentation/wai) | Traces, Metrics |
| yesod-core | [hs-opentelemetry-instrumentation-yesod](instrumentation/yesod) | Traces |
| persistent / esqueleto | [hs-opentelemetry-instrumentation-persistent](instrumentation/persistent) | Traces |
| persistent-mysql | [hs-opentelemetry-instrumentation-persistent-mysql](instrumentation/persistent-mysql) | Traces |
| postgresql-simple | [hs-opentelemetry-instrumentation-postgresql-simple](instrumentation/postgresql-simple) | Traces |
| http-client / http-conduit | [hs-opentelemetry-instrumentation-http-client](instrumentation/http-client) | Traces, Metrics |
| conduit | [hs-opentelemetry-instrumentation-conduit](instrumentation/conduit) | Traces |
| hw-kafka-client | [hs-opentelemetry-instrumentation-hw-kafka-client](instrumentation/hw-kafka-client) | Traces |
| amazonka | [hs-opentelemetry-instrumentation-amazonka](instrumentation/amazonka) | Traces |
| gogol | [hs-opentelemetry-instrumentation-gogol](instrumentation/gogol) | Traces |
| GHC runtime | [hs-opentelemetry-instrumentation-ghc-metrics](instrumentation/ghc-metrics) | Metrics |
| hspec | [hs-opentelemetry-instrumentation-hspec](instrumentation/hspec) | Traces |
| tasty | [hs-opentelemetry-instrumentation-tasty](instrumentation/tasty) | Traces |
| katip | [hs-opentelemetry-instrumentation-katip](instrumentation/katip) | Logs |
| co-log | [hs-opentelemetry-instrumentation-co-log](instrumentation/co-log) | Logs |
| monad-logger | [hs-opentelemetry-instrumentation-monad-logger](instrumentation/monad-logger) | Logs |
| cloudflare | [hs-opentelemetry-instrumentation-cloudflare](instrumentation/cloudflare) | Traces |

### Exporters

| Format | Package | Signals |
|---|---|---|
| OTLP | [hs-opentelemetry-exporter-otlp](exporters/otlp) | Traces, Metrics, Logs |
| Handle (stdout) | [hs-opentelemetry-exporter-handle](exporters/handle) | Traces, Metrics, Logs |
| In-Memory | [hs-opentelemetry-exporter-in-memory](exporters/in-memory) | Traces, Metrics, Logs |
| Prometheus | [hs-opentelemetry-exporter-prometheus](exporters/prometheus) | Metrics |

> **Tip:** For Honeycomb, Datadog, Grafana Cloud, and other OTLP-compatible backends,
> use `hs-opentelemetry-exporter-otlp` with the appropriate endpoint.

### Propagators

| Format | Package | Module |
|---|---|---|
| W3C TraceContext | [hs-opentelemetry-propagator-w3c](propagators/w3c) | `OpenTelemetry.Propagator.W3CTraceContext` |
| W3C Baggage | [hs-opentelemetry-propagator-w3c](propagators/w3c) | `OpenTelemetry.Propagator.W3CBaggage` |
| B3 | [hs-opentelemetry-propagator-b3](propagators/b3) | `OpenTelemetry.Propagator.B3` |
| Jaeger | [hs-opentelemetry-propagator-jaeger](propagators/jaeger) | `OpenTelemetry.Propagator.Jaeger` |
| Datadog | [hs-opentelemetry-propagator-datadog](propagators/datadog) | `OpenTelemetry.Propagator.Datadog` |
| AWS X-Ray | [hs-opentelemetry-propagator-xray](propagators/xray) | `OpenTelemetry.Propagator.XRay` |

## GHC Compatibility

| GHC | Stack resolver | Notes |
|---|---|---|
| 9.4 | lts-21.25 | No hw-kafka-client, no gogol |
| 9.6 | lts-22.44 | No gogol |
| 9.8 | lts-23.28 | No gogol |
| 9.10 | lts-24.35 | Full support |
| 9.12 | nightly-2026-04-04 | No persistent-mysql; proto-lens via allow-newer |

## Examples

Working application examples are in the [`examples/`](examples/) directory:

- [Yesod web application](examples/yesod-minimal) — WAI middleware, database spans, GHC metrics

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

Maintainer: [Ian Duncan](https://github.com/iand675)
