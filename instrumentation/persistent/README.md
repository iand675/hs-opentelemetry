# hs-opentelemetry-instrumentation-persistent

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-persistent?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-persistent)

OpenTelemetry instrumentation for
[persistent](https://hackage.haskell.org/package/persistent) and
[esqueleto](https://hackage.haskell.org/package/esqueleto). Wraps database
operations in spans with the SQL statement and connection info as attributes,
following the
[OTel database semantic conventions](https://opentelemetry.io/docs/specs/semconv/database/).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Wire `wrapSqlBackend` into your pool's backend hooks:

```haskell
import Database.Persist.Postgresql (createPostgresqlPool)
import Database.Persist.Sql
  ( defaultSqlPoolHooks
  , runSqlPoolWithExtensibleHooks
  , setAlterBackend
  )
import OpenTelemetry.Instrumentation.Persistent (wrapSqlBackend)

main :: IO ()
main = do
  pool <- createPostgresqlPool connStr poolSize
  runSqlPoolWithExtensibleHooks myAction pool Nothing $
    setAlterBackend defaultSqlPoolHooks $ \conn ->
      wrapSqlBackend mempty conn
```

`wrapSqlBackend` uses the global tracer provider. Use `wrapSqlBackend'` to pass
a `TracerProvider` explicitly.
