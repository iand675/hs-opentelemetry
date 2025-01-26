{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module OpenTelemetry.Instrumentation.Kafka (produceMessage, pollMessage, commitAllOffsets) where

import Control.Monad (void)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import qualified Data.CaseInsensitive as CI
import GHC.Stack.Types (HasCallStack)
import Kafka.Consumer (ConsumerRecord (crHeaders), KafkaConsumer, OffsetCommit)
import qualified Kafka.Consumer as KC
import Kafka.Producer (KafkaError, KafkaProducer, ProducerRecord (prHeaders))
import qualified Kafka.Producer as KP
import Kafka.Types (Headers, Timeout, headersFromList, headersToList)
import Network.HTTP.Types (RequestHeaders)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Propagator (extract, inject)
import OpenTelemetry.Trace.Core (SpanArguments (kind), SpanKind (Consumer, Producer), Tracer, addAttributesToSpanArguments, callerAttributes, defaultSpanArguments, detectInstrumentationLibrary, getGlobalTracerProvider, getTracerProviderPropagators, inSpan'', makeTracer, tracerOptions)


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
  ctxt <- getContext
  inSpan'' tracer "produceMessage" (addAttributesToSpanArguments callerAttributes producerSpanArgs) $ \newSpan -> do
    propagator <- getTracerProviderPropagators <$> getGlobalTracerProvider
    headers <- inject propagator (Context.insertSpan newSpan ctxt) []
    let newKafkaHeaders = prHeaders record <> httpHeadersToKafkaHeaders headers
    let newKafkaRecord = record {prHeaders = newKafkaHeaders}
    -- TODO put data in span to tracep properly with otel
    KP.produceMessage producer newKafkaRecord


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
  KC.pollMessage consumer timeout >>= \case
    Left err -> pure $ Left err
    Right cr -> do
      tracer <- rdkafkaTracer
      ctxt <- getContext
      propagator <- getTracerProviderPropagators <$> getGlobalTracerProvider
      ctx <- extract propagator (kafkaHeadersToHttpHeaders $ crHeaders cr) ctxt
      void $ attachContext ctx
      inSpan'' tracer "pollMessage" (addAttributesToSpanArguments callerAttributes consumerSpanArgs) $ \newSpan -> do
        return $ Right cr


-- TODO add span argument, does it make sense to trace this?
commitAllOffsets
  :: (MonadIO m, MonadUnliftIO m)
  => OffsetCommit
  -> KafkaConsumer
  -> m (Maybe KafkaError)
commitAllOffsets offsetCommit kafka = do
  tracer <- rdkafkaTracer
  -- TODO add offsetCommit in the attributes
  inSpan'' tracer "commitAllOffsets" (addAttributesToSpanArguments callerAttributes consumerSpanArgs) $ \_span -> do
    KC.commitAllOffsets offsetCommit kafka


kafkaHeadersToHttpHeaders :: Headers -> RequestHeaders
kafkaHeadersToHttpHeaders = map (first CI.mk) . headersToList


httpHeadersToKafkaHeaders :: RequestHeaders -> Headers
httpHeadersToKafkaHeaders = headersFromList . map (first CI.foldedCase)
