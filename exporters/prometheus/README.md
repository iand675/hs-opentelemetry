# hs-opentelemetry-exporter-prometheus

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-exporter-prometheus?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-exporter-prometheus)

Renders OpenTelemetry metric export batches as
[Prometheus text exposition format](https://prometheus.io/docs/instrumenting/exposition_formats/).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

### WAI middleware

Serve a `/metrics` endpoint alongside your application. Place the Prometheus
middleware outside the OTel WAI middleware so scrape requests don't create
spans:

```haskell
import OpenTelemetry.Exporter.Prometheus.WAI (prometheusMiddleware)

app collect innerApp =
  prometheusMiddleware collect (otelMiddleware innerApp)
```

### Standalone server

Start a dedicated Prometheus scrape server (reads `OTEL_EXPORTER_PROMETHEUS_HOST`
and `OTEL_EXPORTER_PROMETHEUS_PORT`, defaulting to `0.0.0.0:9464`):

```haskell
import OpenTelemetry.Exporter.Prometheus.WAI (startPrometheusServer)

startPrometheusServer collect
```

### Push gateway

```haskell
import OpenTelemetry.Exporter.Prometheus.PushGateway

startPushGateway
  PushGatewayConfig
    { pushGatewayEndpoint = "http://pushgateway:9091"
    , pushGatewayJob = "my-service"
    , pushGatewayIntervalSeconds = 15
    }
  manager
  collect
```

## Modules

| Module | Purpose |
|---|---|
| `OpenTelemetry.Exporter.Prometheus` | Core rendering (`renderPrometheusText`) |
| `OpenTelemetry.Exporter.Prometheus.WAI` | WAI middleware and standalone server |
| `OpenTelemetry.Exporter.Prometheus.PushGateway` | Push to a Prometheus Pushgateway |
