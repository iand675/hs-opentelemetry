{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module OpenTelemetry.Instrumentation.Kafka (produceMessage, pollMessage) where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.ByteString (ByteString)
import GHC.Stack.Types (HasCallStack)
import Kafka.Consumer (ConsumerRecord, KafkaConsumer)
import Kafka.Producer (KafkaError, KafkaProducer, ProducerRecord)
import Kafka.Types (Timeout)
import OpenTelemetry.Trace.Core (Tracer, defaultSpanArguments, detectInstrumentationLibrary, getGlobalTracerProvider, inSpan, makeTracer, tracerOptions)


rdkafkaTracer :: (MonadIO m) => m Tracer
rdkafkaTracer = do
  provider <- getGlobalTracerProvider
  return $ makeTracer provider $detectInstrumentationLibrary tracerOptions


produceMessage
  :: (MonadUnliftIO m, HasCallStack)
  => KafkaProducer
  -> ProducerRecord
  -> m (Maybe KafkaError)
produceMessage producer record = do
  tracer <- rdkafkaTracer
  inSpan tracer "produceMessage" defaultSpanArguments $ do
    produceMessage producer record


-- | Polls a single message
pollMessage
  :: (MonadUnliftIO m, HasCallStack)
  => KafkaConsumer
  -> Timeout
  -> m
      ( Either
          KafkaError
          (ConsumerRecord (Maybe ByteString) (Maybe ByteString))
      )
  -- ^ Left on error or timeout, right for success
pollMessage consumer timeout = do
  tracer <- rdkafkaTracer
  inSpan tracer "pollMessage" defaultSpanArguments $ do
    pollMessage consumer timeout
