# Changelog for hs-opentelemetry-instrumentation-yesod

## Unreleased

- **Fix: span name uses `{method} {route_template}` pattern.** When Yesod creates its
  own span (no WAI parent), name is now `GET /api/users/:id` instead of Haskell route
  constructor name. Falls back to just `{method}` when no route matches.
- Add `error.type` span attribute with exception type name when recording exceptions.

## 0.1.1.0

- Set exception details when using WAI and Yesod instrumentation together (#121).

## 0.1.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.1.1

- Bump version bounds for hs-opentelemetry-api to == 0.0.2.0

## 0.0.1.0

- Initial release
