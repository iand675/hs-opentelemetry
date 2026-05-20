# Changelog for hs-opentelemetry-instrumentation-yesod

## Unreleased

- **Breaking: `http.framework` attribute renamed to `webengine.name`.**
  Uses the standard OTel semantic convention (`webengine.name = "yesod"`) instead of
  the custom `http.framework` key. Update any dashboards or alerts that reference
  `http.framework`.
- **Fix: span name uses `{method} {route_template}` pattern.** When Yesod creates its
  own span (no WAI parent), name is now `GET /api/users/:id` instead of Haskell route
  constructor name. Falls back to just `{method}` when no route matches.
- Add `error.type` span attribute with exception type name when recording exceptions.

## 0.1.1.1

- Relax `hs-opentelemetry-api` bounds to support 0.3.x

## 0.1.1.0

- Set exception details when using WAI and Yesod instrumentation together (#121).

## 0.1.0.0

### Breaking changes

- Use `HashMap Text Attribute` instead of `[(Text, Attribute)]` as attributes

## 0.0.1.1

- Bump version bounds for hs-opentelemetry-api to == 0.0.2.0

## 0.0.1.0

- Initial release
