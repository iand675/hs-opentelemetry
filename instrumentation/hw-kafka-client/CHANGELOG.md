# Revision history for hs-opentelemetry-instrumentation-hw-kafka-client

## Unreleased

* Add required `messaging.system` attribute (`"kafka"`).
* Add `messaging.operation.name` and `messaging.operation.type` (stable convention names).
* Add `messaging.consumer.group.name` (generic, alongside kafka-specific key).
* Add `messaging.client.id` from consumer properties.
* Add `messaging.message.body.size` from message value length.
* Set `error.type` and span error status on produce failures.

## 0.1.0.0 -- 2025-01-26

* First version. Released on an unsuspecting world.
