# Changelog for cloudflare

## 0.3.0.0

### New features

- Configuration system via `CloudflareConfig` and `cloudflareInstrumentationMiddleware'`
- Semantic attribute mapping:
  - `client.address` from `CF-Connecting-IP` / `True-Client-IP` (overrides WAI's `remoteHost`-based value)
  - `cloudflare.ray_id` from `CF-Ray`
  - `cloudflare.client.geo.country_code` from `CF-IPCountry`
  - `cloudflare.worker.upstream_zone` from `CF-Worker`
  - `cloudflare.visitor.scheme` parsed from `CF-Visitor` JSON
- Additional core headers: `CF-Visitor`, `CDN-Loop`, `CF-EW-Via`, `CF-Connecting-IPv6`, `CF-Connecting-O2O`
- Location header group (Managed Transform): `CF-IPCity`, `CF-IPContinent`, `CF-IPLongitude`, `CF-IPLatitude`, `CF-Region`, `CF-Region-Code`, `CF-Metro-Code`, `CF-Postal-Code`, `CF-Timezone`
- Bot Management header group: `CF-Bot-Score`, `CF-Verified-Bot`, `CF-JA3-Hash`, `CF-JA4`

### Non-breaking

- `cloudflareInstrumentationMiddleware` (zero-argument) still works, now uses `defaultCloudflareConfig`

## 0.2.0.1

- Support newer dependencies

## 0.2.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes
