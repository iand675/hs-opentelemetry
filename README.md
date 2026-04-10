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

**hs-opentelemetry** is a Haskell implementation of
[OpenTelemetry](https://opentelemetry.io). It provides:

- **[Traces](#traces)** - distributed request flows across services
- **[Metrics](#metrics)** - counters, histograms, and gauges
- **[Logs](#logs)** - structured log records correlated with traces

Data can be exported to any OpenTelemetry-compatible backend (Jaeger, Honeycomb,
Datadog, Grafana, etc.).

The project follows the upstream [OpenTelemetry
specification](https://opentelemetry.io/docs/specs/otel/) and separates the
**API** (types and interfaces used by all code) from the **SDK** (initialization,
export, and configuration used by the application entry point).

## Why OpenTelemetry?

Ad-hoc observability code tends to look like this:

```haskell
handleRequest req = do
  t0 <- getCurrentTime
  putStrLn $ "Processing " <> show (requestPath req)
  result <- processRequest req
  t1 <- getCurrentTime
  putStrLn $ "Done in " <> show (diffUTCTime t1 t0)
  pure result
```

This doesn't correlate across services, can't be routed to different backends
without code changes, and mixes timing/logging code into your request handling.

With hs-opentelemetry:

```haskell
handleRequest req =
  inSpan tracer "handleRequest" defaultSpanArguments $ do
    processRequest req
```

The span records timing and a trace ID that propagates across service
boundaries. You can attach structured attributes to it. The SDK controls where
data is sent (stdout locally, OTLP to a collector in production) without
touching the call sites.

## Getting Started

There are two main packages:

| Package | When to use |
|---|---|
| [`hs-opentelemetry-api`](https://github.com/iand675/hs-opentelemetry/tree/main/api) | Creating spans, recording metrics, emitting logs. Both libraries and applications depend on this. |
| [`hs-opentelemetry-sdk`](https://github.com/iand675/hs-opentelemetry/tree/main/sdk) | Initializing providers, configuring exporters, and setting up the pipeline. Only the application entry point needs this. |

Library authors depend only on the API so their users can choose their own SDK
configuration. Application authors depend on both: the SDK for initialization,
and the API for the actual instrumentation calls (`inSpan`, `counterAdd`, etc.).

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
name, exporter endpoint, sampling rate), initializes the global provider,
and shuts it down on exit, flushing buffered spans.

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

The logging API is a bridge for existing Haskell logging libraries
(katip, co-log, monad-logger). Log records are correlated with the active
trace context automatically.

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

Or use a bridge library:

| Logger | Bridge |
|---|---|
| katip | [`hs-opentelemetry-instrumentation-katip`](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/katip) |
| co-log | [`hs-opentelemetry-instrumentation-co-log`](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/co-log) |
| monad-logger | [`hs-opentelemetry-instrumentation-monad-logger`](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/monad-logger) |

### WAI Middleware

For WAI applications, one middleware instruments all incoming HTTP requests:

```haskell
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMiddleware <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMiddleware myApp
```

Each request produces a server span with method, route, status code, and timing.
Database queries and outgoing HTTP calls nest as child spans when you use the
corresponding instrumentation libraries.

## Specification Conformance

Traces, metrics, and logs are fully implemented. See the detailed [conformance
checklist](https://github.com/iand675/hs-opentelemetry/blob/main/spec-compliance.md) for per-feature coverage against the
OpenTelemetry specification.

| Signal | API Module | SDK Module | Status |
|---|---|---|---|
| Traces | `OpenTelemetry.Trace.Core` | `OpenTelemetry.Trace` | Stable |
| Metrics | `OpenTelemetry.Metric.Core` | `OpenTelemetry.MeterProvider` | Stable |
| Logs | `OpenTelemetry.Log.Core` | `OpenTelemetry.Log` | Stable |

## Performance

When the SDK is not installed or has no processors configured, `inSpan` is a
no-op that costs **13.6 ns** and allocates **15 bytes**.

Benchmarks (GHC 9.10, aarch64-osx, `-O1 -N1 -A32m`):

| Operation | Time | Allocated |
|---|---|---|
| `inSpan` no-op (no SDK) | 13.6 ns | 15 B |
| `inSpan` active | 218-445 ns | 1.2-2.5 KB |
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
| wai | [hs-opentelemetry-instrumentation-wai](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/wai) | Traces, Metrics |
| yesod-core | [hs-opentelemetry-instrumentation-yesod](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/yesod) | Traces |
| persistent / esqueleto | [hs-opentelemetry-instrumentation-persistent](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/persistent) | Traces |
| persistent-mysql | [hs-opentelemetry-instrumentation-persistent-mysql](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/persistent-mysql) | Traces |
| postgresql-simple | [hs-opentelemetry-instrumentation-postgresql-simple](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/postgresql-simple) | Traces |
| http-client / http-conduit | [hs-opentelemetry-instrumentation-http-client](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/http-client) | Traces, Metrics |
| conduit | [hs-opentelemetry-instrumentation-conduit](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/conduit) | Traces |
| hw-kafka-client | [hs-opentelemetry-instrumentation-hw-kafka-client](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/hw-kafka-client) | Traces |
| amazonka | [hs-opentelemetry-instrumentation-amazonka](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/amazonka) | Traces |
| gogol | [hs-opentelemetry-instrumentation-gogol](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/gogol) | Traces |
| GHC runtime | [hs-opentelemetry-instrumentation-ghc-metrics](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/ghc-metrics) | Metrics |
| hspec | [hs-opentelemetry-instrumentation-hspec](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/hspec) | Traces |
| tasty | [hs-opentelemetry-instrumentation-tasty](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/tasty) | Traces |
| katip | [hs-opentelemetry-instrumentation-katip](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/katip) | Logs |
| co-log | [hs-opentelemetry-instrumentation-co-log](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/co-log) | Logs |
| monad-logger | [hs-opentelemetry-instrumentation-monad-logger](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/monad-logger) | Logs |
| cloudflare | [hs-opentelemetry-instrumentation-cloudflare](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/cloudflare) | Traces |

### Exporters

| Format | Package | Signals |
|---|---|---|
| OTLP | [hs-opentelemetry-exporter-otlp](https://github.com/iand675/hs-opentelemetry/tree/main/exporters/otlp) | Traces, Metrics, Logs |
| Handle (stdout) | [hs-opentelemetry-exporter-handle](https://github.com/iand675/hs-opentelemetry/tree/main/exporters/handle) | Traces, Metrics, Logs |
| In-Memory | [hs-opentelemetry-exporter-in-memory](https://github.com/iand675/hs-opentelemetry/tree/main/exporters/in-memory) | Traces, Metrics, Logs |
| Prometheus | [hs-opentelemetry-exporter-prometheus](https://github.com/iand675/hs-opentelemetry/tree/main/exporters/prometheus) | Metrics |

> **Tip:** For Honeycomb, Datadog, Grafana Cloud, and other OTLP-compatible backends,
> use `hs-opentelemetry-exporter-otlp` with the appropriate endpoint.

### Propagators

| Format | Package | Module |
|---|---|---|
| W3C TraceContext | [hs-opentelemetry-propagator-w3c](https://github.com/iand675/hs-opentelemetry/tree/main/propagators/w3c) | `OpenTelemetry.Propagator.W3CTraceContext` |
| W3C Baggage | [hs-opentelemetry-propagator-w3c](https://github.com/iand675/hs-opentelemetry/tree/main/propagators/w3c) | `OpenTelemetry.Propagator.W3CBaggage` |
| B3 | [hs-opentelemetry-propagator-b3](https://github.com/iand675/hs-opentelemetry/tree/main/propagators/b3) | `OpenTelemetry.Propagator.B3` |
| Jaeger | [hs-opentelemetry-propagator-jaeger](https://github.com/iand675/hs-opentelemetry/tree/main/propagators/jaeger) | `OpenTelemetry.Propagator.Jaeger` |
| Datadog | [hs-opentelemetry-propagator-datadog](https://github.com/iand675/hs-opentelemetry/tree/main/propagators/datadog) | `OpenTelemetry.Propagator.Datadog` |
| AWS X-Ray | [hs-opentelemetry-propagator-xray](https://github.com/iand675/hs-opentelemetry/tree/main/propagators/xray) | `OpenTelemetry.Propagator.XRay` |

## GHC Compatibility

| GHC | Stack resolver | Notes |
|---|---|---|
| 9.4 | lts-21.25 | No hw-kafka-client, no gogol |
| 9.6 | lts-22.44 | No gogol |
| 9.8 | lts-23.28 | No gogol |
| 9.10 | lts-24.35 | Full support |
| 9.12 | nightly-2026-04-04 | No persistent-mysql; proto-lens via allow-newer |

## Examples

See the [`examples/`](https://github.com/iand675/hs-opentelemetry/tree/main/examples) directory:

- [Yesod web application](https://github.com/iand675/hs-opentelemetry/tree/main/examples/yesod-minimal) - WAI middleware, database spans, GHC metrics

## Project Goals

- **Interface stability.** Breaking changes to public APIs require a spec
  conformance fix or a measurable performance improvement to justify them.
- **Minimal dependencies.** The API package in particular should be cheap to
  depend on.
- **Spec conformance.** We track the OTel specification as closely as Haskell
  allows. Where something isn't natively expressible (e.g. the spec assumes mutable
  thread-local storage), we document the deviation or attempt to hew as closely as possible to the intent.

## Contributing

See [CONTRIBUTING.md](https://github.com/iand675/hs-opentelemetry/blob/main/CONTRIBUTING.md).

Maintainer: [Ian Duncan](https://github.com/iand675)
