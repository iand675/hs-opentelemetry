# Kafka tracing

`produceMessage`, `produceMessage'` and `pollMessage` propagate trace context and
record Kafka span attributes. Existing attribute names remain the default.

## Migrating attributes to semantic conventions 1.45

Set `OTEL_SEMCONV_STABILITY_OPT_IN` before the first instrumented operation:

| Value | Attributes emitted |
| --- | --- |
| Unset | Existing legacy attributes, unchanged |
| `messaging` | Existing newer operation/group attributes, unchanged |
| `messaging/dup` | Both existing operation/group sets, unchanged |
| `messaging/1.45` | New 1.45 attribute names only |
| `messaging/1.45/dup` | New 1.45 names plus the existing default attributes |
| `messaging,messaging/1.45/dup` | New 1.45 names plus the existing `messaging` attributes |

The versioned values are **Haskell-specific extensions**, not upstream standard
stability categories. Messaging conventions are still in development. The word
`Stable` in the existing Haskell API predates this migration and does not indicate
upstream stability. `/dup` takes precedence when both versioned values are present.
The options are cached on first use, as with other instrumentation packages.

| Existing attribute | 1.45 attribute |
| --- | --- |
| `messaging.system` | `messaging.system.name` (`"kafka"`) |
| `messaging.kafka.message.key` | `kafka.message.key` |
| `messaging.kafka.message.offset` | `kafka.offset` (integer) |
| `messaging.kafka.destination.partition` | `messaging.destination.partition.id` (string) |
| `messaging.kafka.consumer.group` | `messaging.consumer.group.name` |
| `messaging.operation` | `messaging.operation.name` and `messaging.operation.type` |

The new mode also emits `kafka.message.tombstone=true` for null message values.
Absent or invalid UTF-8 keys remain omitted; an empty byte-string value is not a
tombstone. No cluster ID is inferred from broker addresses: the current wrapper
does not receive the broker metadata needed for `kafka.cluster.id`.

Use dual emission while updating queries and dashboards, then switch to
`messaging/1.45`. These options migrate attributes only; span lifecycle, names,
kinds and operation semantics are unchanged. They do not claim complete 1.45
messaging conformance.

For custom spans, `producerAttributesWithSemantics` and
`consumerAttributesWithSemantics` accept the options returned by
`getSemanticsOptions` or `getSemanticsOptions'`. Existing `producerAttributes`
and `consumerAttributes` retain their previous behavior for every `StabilityOpt`.
