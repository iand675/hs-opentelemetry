# hs-opentelemetry-instrumentation-hw-kafka-client

[![Hackage](https://img.shields.io/hackage/v/hs-opentelemetry-instrumentation-hw-kafka-client?style=flat-square)](https://hackage.haskell.org/package/hs-opentelemetry-instrumentation-hw-kafka-client)

OpenTelemetry instrumentation for
[hw-kafka-client](https://hackage.haskell.org/package/hw-kafka-client). Creates
producer and consumer spans with topic, partition, and offset attributes
following the
[OTel messaging semantic conventions](https://opentelemetry.io/docs/specs/semconv/messaging/).

Propagates trace context through Kafka message headers so traces flow from
producers to consumers.

Part of [hs-opentelemetry](https://github.com/iand675/hs-opentelemetry).

## Usage

```haskell
import OpenTelemetry.Instrumentation.Kafka
  (producerPublish, consumerSubscribeAndPoll)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  -- Producer: trace context is injected into Kafka message headers
  producerPublish producer record

  -- Consumer: trace context is extracted from headers,
  -- creating child spans linked to the producer trace
  consumerSubscribeAndPoll consumer topics callback
```

See [examples/hw-kafka-client-example](https://github.com/iand675/hs-opentelemetry/tree/main/examples/hw-kafka-client-example)
for a full producer/consumer example with Docker Compose and Jaeger.

## GHC Compatibility

Requires GHC 9.6+ (hw-kafka-client headers API is only available in LTS 22+).
