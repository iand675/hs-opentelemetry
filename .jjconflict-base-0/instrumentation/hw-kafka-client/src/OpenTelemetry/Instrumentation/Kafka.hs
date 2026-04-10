{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ViewPatterns #-}

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
import qualified Data.Map as M
import Data.String (IsString)
import Data.Text.Encoding (decodeUtf8')
import GHC.Stack.Types (HasCallStack)
import Kafka.Consumer (
  ConsumerProperties (cpProps),
  ConsumerRecord (crHeaders, crKey, crOffset, crPartition, crTopic),
  KafkaConsumer,
  Offset (unOffset),
 )
import qualified Kafka.Consumer as KC
import Kafka.Producer (
  KafkaError,
  KafkaProducer,
  ProducePartition (SpecifiedPartition, UnassignedPartition),
  ProducerRecord (prHeaders, prKey, prPartition, prTopic),
 )
import qualified Kafka.Producer as KP
import Kafka.Types (
  Headers,
  PartitionId (unPartitionId),
  Timeout,
  TopicName (unTopicName),
  headersFromList,
  headersToList,
 )
import Network.HTTP.Types (RequestHeaders)
import OpenTelemetry.Attributes.Map (AttributeMap, insertAttributeByKey)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Propagator (extract, inject)
import OpenTelemetry.SemanticConventions (
  messaging_destination_name,
  messaging_kafka_consumer_group,
  messaging_kafka_destination_partition,
  messaging_kafka_message_key,
  messaging_kafka_message_offset,
  messaging_operation,
 )
import OpenTelemetry.Trace.Core (
  SpanArguments (kind),
  SpanKind (Consumer, Producer),
  Tracer,
  addAttributesToSpanArguments,
  callerAttributes,
  defaultSpanArguments,
  detectInstrumentationLibrary,
  getGlobalTracerProvider,
  getTracerProviderPropagators,
  inSpan'',
  makeTracer,
  toAttribute,
  tracerOptions,
 )


producerOperationName :: IsString a => a
producerOperationName = "send"


consumerOperationName :: IsString a => a
consumerOperationName = "process"


-- | Span arguments for producer operations
producerSpanArgs :: SpanArguments
producerSpanArgs =
  defaultSpanArguments {kind = Producer}


rightToMaybe :: Either a b -> Maybe b
rightToMaybe (Right b) = Just b
rightToMaybe _ = Nothing


-- | Span attributes with caller information and kafka specifics
producerAttributes :: HasCallStack => ProducerRecord -> AttributeMap
producerAttributes record =
  let
    addOperationName =
      insertAttributeByKey messaging_operation producerOperationName
    addDestination =
      insertAttributeByKey messaging_destination_name $ toAttribute . unTopicName . prTopic $ record
    addPartition =
      case prPartition record of
        SpecifiedPartition p64 ->
          insertAttributeByKey messaging_kafka_destination_partition $ toAttribute $ p64
        UnassignedPartition ->
          id
    addKey =
      case prKey record >>= rightToMaybe . decodeUtf8' of
        Just key ->
          insertAttributeByKey messaging_kafka_message_key $ toAttribute key
        Nothing ->
          id
  in
    (addOperationName . addDestination . addPartition . addKey)
      callerAttributes


-- | Span arguments for consumer operations
consumerSpanArgs :: SpanArguments
consumerSpanArgs = defaultSpanArguments {kind = Consumer}


-- | Span attributes for consumer with caller information and kafka specifics
consumerAttributes
  :: HasCallStack
  => ConsumerProperties
  -> ConsumerRecord (Maybe ByteString) (Maybe ByteString)
  -> AttributeMap
consumerAttributes consumerProperties record =
  let
    addOperationName =
      insertAttributeByKey messaging_operation consumerOperationName
    addDestination =
      insertAttributeByKey messaging_destination_name $ toAttribute . unTopicName . crTopic $ record
    addConsumerGroup =
      -- NOTE: unfortunately, hw-kafka-client does not expose an API to get the consumer, this a flaky workaround
      case M.lookup "group.id" $ cpProps consumerProperties of
        Just groupId -> insertAttributeByKey messaging_kafka_consumer_group $ toAttribute groupId
        Nothing -> id
    addPartition =
      insertAttributeByKey messaging_kafka_destination_partition $ toAttribute . unPartitionId . crPartition $ record
    addOffset =
      insertAttributeByKey messaging_kafka_message_offset $ toAttribute . unOffset . crOffset $ record
    addKey =
      case crKey record >>= rightToMaybe . decodeUtf8' of
        Just key ->
          insertAttributeByKey messaging_kafka_message_key $ toAttribute key
        Nothing ->
          id
  in
    (addOperationName . addDestination . addConsumerGroup . addPartition . addOffset . addKey)
      callerAttributes


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
produceMessage producer record =
  let
    headers = prHeaders record
    topicName = prTopic record
    spanName = producerOperationName <> " " <> unTopicName topicName
    attributes = producerAttributes record
    spanArguments = addAttributesToSpanArguments attributes producerSpanArgs
  in
    do
      tracer <- rdkafkaTracer
      ctxt <- getContext
      inSpan'' tracer spanName spanArguments $ \newSpan -> do
        propagator <- getTracerProviderPropagators <$> getGlobalTracerProvider
        extraHeaders <- inject propagator (Context.insertSpan newSpan ctxt) []
        let newKafkaHeaders = headers <> httpHeadersToKafkaHeaders extraHeaders
        let newKafkaRecord = record {prHeaders = newKafkaHeaders}
        KP.produceMessage producer newKafkaRecord


{- | Poll for a single message from Kafka with OpenTelemetry instrumentation.

This function wraps the standard Kafka consumer with OpenTelemetry tracing.
It creates a new span for the poll operation and extracts any tracing context
from the message headers.
-}
pollMessage
  :: (MonadUnliftIO m, HasCallStack)
  => ConsumerProperties
  -> KafkaConsumer
  -> Timeout
  -> m (Either KafkaError (ConsumerRecord (Maybe ByteString) (Maybe ByteString)))
  -- ^ Returns either an error or the consumed record
pollMessage consumerProperties consumer timeout =
  do
    KC.pollMessage consumer timeout >>= \case
      Left err -> pure $ Left err
      Right cr ->
        let
          attributes = consumerAttributes consumerProperties cr
          topicName = crTopic cr
          spanName = consumerOperationName <> " " <> unTopicName topicName
        in
          do
            tracer <- rdkafkaTracer
            ctxt <- getContext
            propagator <- getTracerProviderPropagators <$> getGlobalTracerProvider
            ctx <- extract propagator (kafkaHeadersToHttpHeaders $ crHeaders cr) ctxt
            void $ attachContext ctx
            inSpan'' tracer spanName (addAttributesToSpanArguments attributes consumerSpanArgs) $ \_span -> do
              return $ Right cr
