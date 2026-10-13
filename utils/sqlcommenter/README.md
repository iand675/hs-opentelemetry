# OpenTelemetry SqlCommenter utilities for Haskell

[![hs-opentelemetry-utils-sqlcommenter](https://img.shields.io/hackage/v/hs-opentelemetry-utils-sqlcommenter?style=flat-square&logo=haskell&label=hs-opentelemetry-utils-sqlcommenter&labelColor=5D4F85)](https://hackage.haskell.org/package/hs-opentelemetry-utils-sqlcommenter)

This package implements the [sqlcommenter specification](https://google.github.io/sqlcommenter/spec/):
it attaches structured key-value metadata to SQL queries as comments so that database
tooling can correlate queries back to the application code and distributed trace that
issued them.

```sql
SELECT * FROM users /* db_driver='postgresql',traceparent='00-...-01' */
```

See the `OpenTelemetry.Utils.SqlCommenter` module for the API:

- `sqlCommenter` / `parseFirstSqlComment` — add and parse sqlcommenter comments (independent of OpenTelemetry).
- `lookupSqlCommenterAttributes` / `getSqlCommenterAttributes` — read attributes stored in an OpenTelemetry context.
- `addTraceDataToAttributes` / `getSqlCommenterAttributesWithTraceData` — enrich attributes with W3C `traceparent`/`tracestate`.
