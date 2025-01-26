{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      : OpenTelemetry.Instrumentation.Kafka
Description : OpenTelemetry instrumentation for hw-kafka-client

This module provides OpenTelemetry instrumentation for the hw-kafka-client library.
It adds distributed tracing capabilities to Kafka producer and consumer operations,
automatically propagating context between services via Kafka message headers.
-}
module OpenTelemetry.Instrumentation.Kafka (
  -- * Producer
  produceMessage,

  -- * Consumer
  pollMessage,
) where

import Control.Monad (void)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import qualified Data.CaseInsensitive as CI
import GHC.Stack.Types (HasCallStack)
import Kafka.Consumer (ConsumerRecord (crHeaders), KafkaConsumer)
import qualified Kafka.Consumer as KC
import Kafka.Producer (KafkaError, KafkaProducer, ProducerRecord (prHeaders))
import qualified Kafka.Producer as KP
import Kafka.Types (Headers, Timeout, headersFromList, headersToList)
import Network.HTTP.Types (RequestHeaders)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Propagator (extract, inject)
import OpenTelemetry.Trace.Core (SpanArguments (kind), SpanKind (Consumer, Producer), Tracer, addAttributesToSpanArguments, callerAttributes, defaultSpanArguments, detectInstrumentationLibrary, getGlobalTracerProvider, getTracerProviderPropagators, inSpan'', makeTracer, tracerOptions)


-- | Span arguments for producer operations
producerSpanArgs :: SpanArguments
producerSpanArgs = defaultSpanArguments {kind = Producer}


-- | Span arguments for consumer operations
consumerSpanArgs :: SpanArguments
consumerSpanArgs = defaultSpanArguments {kind = Consumer}


-- | Get the tracer for rdkafka instrumentation
rdkafkaTracer :: (MonadIO m) => m Tracer
rdkafkaTracer = do
  provider <- getGlobalTracerProvider
  return $ makeTracer provider $detectInstrumentationLibrary tracerOptions


-- | Convert Kafka headers to HTTP headers format
kafkaHeadersToHttpHeaders :: Headers -> RequestHeaders
kafkaHeadersToHttpHeaders = map (first CI.mk) . headersToList


-- | Convert HTTP headers to Kafka headers format
httpHeadersToKafkaHeaders :: RequestHeaders -> Headers
httpHeadersToKafkaHeaders = headersFromList . map (first CI.foldedCase)


{- | Produce a message to Kafka with OpenTelemetry instrumentation.

This function wraps the standard Kafka producer with OpenTelemetry tracing.
It creates a new span for the produce operation and injects the current context
into the message headers.
-}
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
    KP.produceMessage producer newKafkaRecord


{- | Poll for a single message from Kafka with OpenTelemetry instrumentation.

This function wraps the standard Kafka consumer with OpenTelemetry tracing.
It creates a new span for the poll operation and extracts any tracing context
from the message headers.
-}
pollMessage
  :: (MonadUnliftIO m, HasCallStack)
  => KafkaConsumer
  -> Timeout
  -> m (Either KafkaError (ConsumerRecord (Maybe ByteString) (Maybe ByteString)))
  -- ^ Returns either an error or the consumed record
pollMessage consumer timeout = do
  KC.pollMessage consumer timeout >>= \case
    Left err -> pure $ Left err
    Right cr -> do
      tracer <- rdkafkaTracer
      ctxt <- getContext
      propagator <- getTracerProviderPropagators <$> getGlobalTracerProvider
      ctx <- extract propagator (kafkaHeadersToHttpHeaders $ crHeaders cr) ctxt
      void $ attachContext ctx
      inSpan'' tracer "pollMessage" (addAttributesToSpanArguments callerAttributes consumerSpanArgs) $ \_span -> do
        return $ Right cr
