# Changelog for hs-opentelemetry-propagator-b3

## Unreleased

- Fix: B3 multi-header extraction now gives `X-B3-Flags` (debug) precedence over
  `X-B3-Sampled`. Previously `sampled <|> debug` meant `X-B3-Sampled: 0` overrode
  `X-B3-Flags: 1`, violating Zipkin's "debug implies accept" rule.

## 0.0.1.3

- Update dependency bounds for hs-opentelemetry-api 0.3.0.0

## 0.0.1.2

- Support newer dependencies
