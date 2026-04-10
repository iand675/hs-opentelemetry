# hs-opentelemetry-instrumentation-postgresql-simple

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-postgresql-simple?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-postgresql-simple)

OpenTelemetry instrumentation for
[postgresql-simple](https://hackage.haskell.org/package/postgresql-simple).
Drop-in replacements for query functions that create spans with the SQL
statement and connection attributes following the
[OTel database semantic conventions](https://opentelemetry.io/docs/specs/semconv/database/).

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Import from `OpenTelemetry.Instrumentation.PostgresqlSimple` instead of
`Database.PostgreSQL.Simple`. The SDK must be initialized so spans have
somewhere to go:

```haskell
import Database.PostgreSQL.Simple (connectPostgreSQL)
import OpenTelemetry.Instrumentation.PostgresqlSimple (query)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  conn <- connectPostgreSQL "host=localhost dbname=mydb"
  rows <- query conn "SELECT id, name FROM users WHERE active = ?" (Only True)
  -- A span is created for the query with the SQL statement,
  -- db.system, server.address, etc. as attributes
  print rows
```

The module re-exports everything from `Database.PostgreSQL.Simple`, so it can
be used as a drop-in replacement import.
