{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module OpenTelemetry.Instrumentation.Kafka (produceMessage, pollMessage, commitAllOffsets) where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.ByteString (ByteString)
import GHC.Stack.Types (HasCallStack)
import Kafka.Consumer (ConsumerRecord, KafkaConsumer, OffsetCommit)
import qualified Kafka.Consumer as KC
import Kafka.Producer (KafkaError, KafkaProducer, ProducerRecord)
import qualified Kafka.Producer as KP
import Kafka.Types (Timeout)
import OpenTelemetry.Trace.Core (SpanArguments (kind), SpanKind (Consumer, Producer), Tracer, addAttributesToSpanArguments, callerAttributes, defaultSpanArguments, detectInstrumentationLibrary, getGlobalTracerProvider, inSpan'', makeTracer, tracerOptions)


producerSpanArgs :: SpanArguments
producerSpanArgs = defaultSpanArguments {kind = Producer}


consumerSpanArgs :: SpanArguments
consumerSpanArgs = defaultSpanArguments {kind = Consumer}


-- TODO see how to properly link spans, remove the root span in the app if needed
-- TODO documentation
-- TODO see how other instrumentation work
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
  inSpan'' tracer "produceMessage" (addAttributesToSpanArguments callerAttributes producerSpanArgs) $ \_span -> do
    -- TODO put data in span to tracep properly with otel
    KP.produceMessage producer record


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
  -- TODO use the message to actually reconstruct the span

  inSpan'' tracer "pollMessage" (addAttributesToSpanArguments callerAttributes consumerSpanArgs) $ \_span -> do
    KC.pollMessage consumer timeout


-- TODO add span argument
commitAllOffsets
  :: (MonadIO m, MonadUnliftIO m)
  => OffsetCommit
  -> KafkaConsumer
  -> m (Maybe KafkaError)
commitAllOffsets offsetCommit kafka = do
  tracer <- rdkafkaTracer
  -- TODO add offsetCommit in the attributes
  inSpan'' tracer "commitAllOffsets" (addAttributesToSpanArguments callerAttributes consumerSpanArgs) $ \_span -> do
    commitAllOffsets offsetCommit kafka
