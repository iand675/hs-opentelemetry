# hs-opentelemetry-instrumentation-cloudflare

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-cloudflare?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-cloudflare)

WAI middleware that captures Cloudflare-injected request headers as
OpenTelemetry span attributes. Intended to be stacked on top of
[hs-opentelemetry-instrumentation-wai](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/wai).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## What it captures

### Core headers (always on)

`CF-Connecting-IP`, `True-Client-IP`, `CF-Ray`, `CF-IPCountry`, `CF-Worker`,
`CF-Visitor`, `CDN-Loop`, `CF-EW-Via`, `CF-Connecting-IPv6`, `CF-Connecting-O2O`

### Semantic attribute mapping

| Header | Semantic attribute |
|--------|-------------------|
| `CF-Connecting-IP` / `True-Client-IP` | `client.address` (overwrites WAI's `remoteHost` value) |
| `CF-Ray` | `cloudflare.ray_id` |
| `CF-IPCountry` | `cloudflare.client.geo.country_code` |
| `CF-Worker` | `cloudflare.worker.upstream_zone` |
| `CF-Visitor` | `cloudflare.visitor.scheme` (parsed from JSON) |

All headers are also recorded as raw `http.request.header.<name>` attributes.

### Location headers (opt-in on Cloudflare dashboard)

Captured when `cfgCaptureLocationHeaders` is `True` (the default):
`CF-IPCity`, `CF-IPContinent`, `CF-IPLongitude`, `CF-IPLatitude`, `CF-Region`,
`CF-Region-Code`, `CF-Metro-Code`, `CF-Postal-Code`, `CF-Timezone`

### Bot Management headers (Enterprise)

Captured when `cfgCaptureBotHeaders` is `True` (off by default):
`CF-Bot-Score`, `CF-Verified-Bot`, `CF-JA3-Hash`, `CF-JA4`

## Usage

### Default configuration

Stack it after the OTel WAI middleware so the request span already exists:

```haskell
import OpenTelemetry.Instrumentation.Cloudflare (cloudflareInstrumentationMiddleware)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMw <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMw $ cloudflareInstrumentationMiddleware myApp
```

### Custom configuration

```haskell
import OpenTelemetry.Instrumentation.Cloudflare

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMw <- newOpenTelemetryWaiMiddleware
  let cfCfg = defaultCloudflareConfig
        { cfgCaptureBotHeaders = True    -- enable bot management headers
        , cfgSetClientAddress  = False   -- don't overwrite client.address
        }
  run 8080 $ otelMw $ cloudflareInstrumentationMiddleware' cfCfg myApp
```
