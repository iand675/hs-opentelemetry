{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Exception (bracket)
import Data.Either.Combinators (maybeToLeft)
import Data.Text (Text, pack)
import Kafka.Consumer (ConsumerGroupId (ConsumerGroupId), ConsumerProperties, Timeout (Timeout), closeConsumer, newConsumer)
import Kafka.Consumer.ConsumerProperties (brokersList, groupId, logLevel)
import Kafka.Consumer.Subscription (Subscription, offsetReset, topics)
import Kafka.Consumer.Types (OffsetReset (Earliest))
import Kafka.Producer (KafkaLogLevel (KafkaLogInfo))
import OpenTelemetry.Instrumentation.Kafka (pollMessage)
import OpenTelemetry.Trace (Tracer, TracerOptions, initializeGlobalTracerProvider, makeTracer, shutdownTracerProvider)
import System.Environment


consumerProps :: Text -> ConsumerProperties
consumerProps consumerGroup =
  brokersList ["localhost:19092"]
    <> groupId (ConsumerGroupId consumerGroup)
    <> logLevel KafkaLogInfo


-- Subscription to topics
consumerSub :: Subscription
consumerSub = topics ["example-topic"] <> offsetReset Earliest


withTracer :: ((TracerOptions -> Tracer) -> IO a) -> IO a
withTracer f =
  bracket
    -- Install the SDK, pulling configuration from the environment
    initializeGlobalTracerProvider
    -- Ensure that any spans that haven't been exported yet are flushed
    shutdownTracerProvider
    -- Get a tracer so you can create spans
    (\tracerProvider -> f $ makeTracer tracerProvider "haskell-consumer")


main :: IO ()
main = withTracer $ const $ do
  -- NOTE: do proper args parsing
  consumerGroupText <- pack . head <$> getArgs
  let cp = consumerProps consumerGroupText
  res <- Control.Exception.bracket (mkConsumer cp) clConsumer (runHandler cp)
  case res of
    Left err -> putStrLn $ "Error consuming the message: " <> show err
    Right msg -> putStrLn $ "Message consumed: " <> show msg
  where
    mkConsumer cp = newConsumer cp consumerSub
    clConsumer (Left err) = return (Left err)
    clConsumer (Right kc) = maybeToLeft () <$> closeConsumer kc
    runHandler _ (Left err) = return (Left err)
    runHandler cp (Right kc) = pollMessage cp kc (Timeout 1000)
