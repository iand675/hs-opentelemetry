# Changelog

## 1.45.0.0 - Unreleased

- Generate metric constructors and a catalogue from semantic conventions 1.45.0
  using Weaver 0.28.0. Constructors fix the metric name, unit and description;
  callers supply advisory parameters and, for observable instruments, callbacks.
- Preserve upstream integer/double annotations. Offer both numeric variants when
  upstream leaves the choice unspecified, and synchronous/observable variants
  where supported by the Haskell API.
