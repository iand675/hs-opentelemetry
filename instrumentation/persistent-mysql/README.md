# hs-opentelemetry-instrumentation-persistent-mysql

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-persistent-mysql?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-persistent-mysql)

MySQL-specific OpenTelemetry instrumentation for
[persistent-mysql](https://hackage.haskell.org/package/persistent-mysql).
Extends [hs-opentelemetry-instrumentation-persistent](https://github.com/iand675/hs-opentelemetry/tree/main/instrumentation/persistent) with
MySQL connection details as span attributes.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

Drop-in replacement for `createMySQLPool` that instruments all queries:

```haskell
import OpenTelemetry.Instrumentation.Persistent.MySQL (createMySQLPool)
import qualified Database.MySQL.Base as MySQL

pool <- createMySQLPool tracerProvider mempty MySQL.defaultConnectInfo 10
```

`withMySQLPool` and `withMySQLConn` are also available with the same
`TracerProvider -> AttributeMap -> ...` signature.

## GHC Compatibility

Not available on GHC 9.12 (persistent-mysql build issue).
