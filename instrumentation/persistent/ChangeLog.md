# Changelog for hs-opentelemetry-persistent

## Unreleased

- **Respect `OTEL_SEMCONV_STABILITY_OPT_IN` for database query attribute.**
  Query text is now emitted as `db.query.text` (stable), `db.statement` (old),
  or both (`database/dup`), controlled by the `databaseOption` setting.
- **Fix: span name now low-cardinality.** Previously used the full SQL string as
  the span name, which is high cardinality and violates OTel naming rules. Now uses
  `{db.operation.name} {db.namespace}` pattern (e.g. `SELECT mydb`). Full SQL text
  remains available in the `db.query.text` / `db.statement` attributes.
- Add `db.operation.name` attribute in stable mode (extracted from first SQL keyword).
- `annotateBasics` emits `db.system.name` (stable) or `db.system` (old) per config.

## 0.1.0.1

- Support newer dependencies

## 0.1.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.1.0

- Initial release
