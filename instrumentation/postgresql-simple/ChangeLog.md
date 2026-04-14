# Changelog for hs-opentelemetry-instrumentation-postgresql-simple

## Unreleased

- **Fix: Use `databaseOption` instead of `httpOption` for database convention selection.**
  Database attribute naming is now controlled independently via `OTEL_SEMCONV_STABILITY_OPT_IN=database`
  (or `database/dup`) rather than piggybacking on the HTTP stability setting.
- **Update stable database attributes.** `db.system` → `db.system.name`,
  `db.name` → `db.namespace`, `db.user` removed (security, per spec). `db.statement`
  uses `db.query.text` in stable mode.
- Add `db.operation.name` from first SQL keyword (e.g. `SELECT`, `INSERT`).
- Use `{operation} {db}` span name pattern (e.g. `SELECT mydb`).

## 0.2.0.1

- Fix error thrown if no rows passed in

## 0.2.0.0

- Significantly reworked implementation
