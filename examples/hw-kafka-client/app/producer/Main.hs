{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Exception (bracket)
import Control.Monad (forM_)
import Data.ByteString (ByteString)
import Kafka.Producer (
  KafkaError,
  KafkaLogLevel (KafkaLogDebug),
  KafkaProducer,
  ProducePartition (UnassignedPartition),
  ProducerProperties,
  ProducerRecord (..),
  TopicName,
  brokersList,
  closeProducer,
  logLevel,
  newProducer,
 )
import OpenTelemetry.Instrumentation.Kafka (produceMessage)
import OpenTelemetry.Trace (Tracer, TracerOptions, initializeGlobalTracerProvider, makeTracer, shutdownTracerProvider)


-- Global producer properties
producerProps :: ProducerProperties
producerProps =
  brokersList ["localhost:19092"]
    <> logLevel KafkaLogDebug


-- Topic to send messages to
targetTopic :: TopicName
targetTopic = "example-topic"


sendMessages :: KafkaProducer -> IO (Either KafkaError ())
sendMessages prod = do
  err1 <- produceMessage prod (mkMessage (Just "mykey") "test from producer")
  forM_ err1 print
  return $ Right ()


mkMessage :: Maybe ByteString -> ByteString -> ProducerRecord
mkMessage k v =
  ProducerRecord
    { prTopic = targetTopic
    , prPartition = UnassignedPartition
    , prKey = k
    , prValue = Just v
    , prHeaders = mempty
    }


withTracer :: ((TracerOptions -> Tracer) -> IO a) -> IO a
withTracer f =
  bracket
    -- Install the SDK, pulling configuration from the environment
    initializeGlobalTracerProvider
    -- Ensure that any spans that haven't been exported yet are flushed
    shutdownTracerProvider
    -- Get a tracer so you can create spans
    (\tracerProvider -> f $ makeTracer tracerProvider "haskell-producer")


main :: IO ()
main = withTracer $ const $ do
  res <- Control.Exception.bracket mkProducer clProducer runHandler
  case res of
    Left err -> putStrLn $ "Error producing the message: " <> show err
    Right () -> putStrLn "Message produced!"
  where
    mkProducer = newProducer producerProps
    clProducer (Left _) = return ()
    clProducer (Right prod) = closeProducer prod
    runHandler (Left err) = return $ Left err
    runHandler (Right prod) = sendMessages prod
