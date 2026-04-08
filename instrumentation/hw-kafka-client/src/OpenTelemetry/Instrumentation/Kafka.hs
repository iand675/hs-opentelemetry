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

  -- * Attribute builders (exported for testing)
  producerAttributes,
  consumerAttributes,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Int (Int64)
import qualified Data.Map as M
import Data.String (IsString)
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8')
import qualified Data.Text.Encoding as TE
import GHC.Stack.Types (HasCallStack)
import Kafka.Consumer (
  ConsumerProperties (cpProps),
  ConsumerRecord (crHeaders, crKey, crOffset, crPartition, crTopic, crValue),
  KafkaConsumer,
  Offset (unOffset),
 )
import qualified Kafka.Consumer as KC
import Kafka.Producer (
  KafkaError,
  KafkaProducer,
  ProducePartition (SpecifiedPartition, UnassignedPartition),
  ProducerRecord (prHeaders, prKey, prPartition, prTopic, prValue),
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
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Attributes.Map (AttributeMap, insertAttributeByKey)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Propagator (TextMap, emptyTextMap, extract, getGlobalTextMapPropagator, inject, textMapFromList, textMapToList)
import OpenTelemetry.SemanticConventions (
  error_type,
  messaging_client_id,
  messaging_consumer_group_name,
  messaging_destination_name,
  messaging_kafka_consumer_group,
  messaging_kafka_destination_partition,
  messaging_kafka_message_key,
  messaging_kafka_message_offset,
  messaging_message_body_size,
  messaging_operation,
  messaging_operation_name,
  messaging_operation_type,
  messaging_system,
 )
import OpenTelemetry.Trace.Core (
  SpanArguments (kind),
  SpanKind (Consumer, Producer),
  SpanStatus (Error),
  Tracer,
  addAttribute,
  addAttributesToSpanArguments,
  callerAttributes,
  defaultSpanArguments,
  detectInstrumentationLibrary,
  getGlobalTracerProvider,
  inSpan'',
  makeTracer,
  setStatus,
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


producerAttributes :: HasCallStack => ProducerRecord -> AttributeMap
producerAttributes record =
  let
    addSystem =
      insertAttributeByKey messaging_system (toAttribute ("kafka" :: T.Text))
    addOperationName =
      insertAttributeByKey messaging_operation producerOperationName
        . insertAttributeByKey messaging_operation_name (toAttribute (producerOperationName :: T.Text))
    addOperationType =
      insertAttributeByKey messaging_operation_type (toAttribute ("send" :: T.Text))
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
    addBodySize =
      case prValue record of
        Just v -> insertAttributeByKey messaging_message_body_size (toAttribute (fromIntegral (BS.length v) :: Int64))
        Nothing -> id
  in
    (addSystem . addOperationName . addOperationType . addDestination . addPartition . addKey . addBodySize)
      callerAttributes


-- | Span arguments for consumer operations
consumerSpanArgs :: SpanArguments
consumerSpanArgs = defaultSpanArguments {kind = Consumer}


consumerAttributes
  :: HasCallStack
  => ConsumerProperties
  -> ConsumerRecord (Maybe ByteString) (Maybe ByteString)
  -> AttributeMap
consumerAttributes consumerProperties record =
  let
    addSystem =
      insertAttributeByKey messaging_system (toAttribute ("kafka" :: T.Text))
    addOperationName =
      insertAttributeByKey messaging_operation consumerOperationName
        . insertAttributeByKey messaging_operation_name (toAttribute (consumerOperationName :: T.Text))
    addOperationType =
      insertAttributeByKey messaging_operation_type (toAttribute ("process" :: T.Text))
    addDestination =
      insertAttributeByKey messaging_destination_name $ toAttribute . unTopicName . crTopic $ record
    addConsumerGroup =
      case M.lookup "group.id" $ cpProps consumerProperties of
        Just groupId ->
          insertAttributeByKey messaging_kafka_consumer_group (toAttribute groupId)
            . insertAttributeByKey messaging_consumer_group_name (toAttribute groupId)
        Nothing -> id
    addClientId =
      case M.lookup "client.id" $ cpProps consumerProperties of
        Just cid -> insertAttributeByKey messaging_client_id (toAttribute cid)
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
    addBodySize =
      case crValue record of
        Just v -> insertAttributeByKey messaging_message_body_size (toAttribute (fromIntegral (BS.length v) :: Int64))
        Nothing -> id
  in
    ( addSystem
        . addOperationName
        . addOperationType
        . addDestination
        . addConsumerGroup
        . addClientId
        . addPartition
        . addOffset
        . addKey
        . addBodySize
    )
      callerAttributes


-- | Get the tracer for rdkafka instrumentation
rdkafkaTracer :: (MonadIO m) => m Tracer
rdkafkaTracer = do
  provider <- getGlobalTracerProvider
  return $ makeTracer provider $detectInstrumentationLibrary tracerOptions


kafkaHeadersToTextMap :: Headers -> TextMap
kafkaHeadersToTextMap = textMapFromList . map (\(k, v) -> (TE.decodeUtf8 k, TE.decodeUtf8 v)) . headersToList


textMapToKafkaHeaders :: TextMap -> Headers
textMapToKafkaHeaders = headersFromList . map (\(k, v) -> (TE.encodeUtf8 k, TE.encodeUtf8 v)) . textMapToList


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
        propagator <- liftIO getGlobalTextMapPropagator
        extraTm <- inject propagator (Context.insertSpan newSpan ctxt) emptyTextMap
        let newKafkaHeaders = headers <> textMapToKafkaHeaders extraTm
        let newKafkaRecord = record {prHeaders = newKafkaHeaders}
        result <- KP.produceMessage producer newKafkaRecord
        case result of
          Just err -> do
            let errText = T.pack $ show err
            addAttribute newSpan (unkey error_type) errText
            setStatus newSpan (Error errText)
          Nothing -> pure ()
        pure result


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
            propagator <- liftIO getGlobalTextMapPropagator
            ctx <- extract propagator (kafkaHeadersToTextMap $ crHeaders cr) ctxt
            _ <- attachContext ctx
            inSpan'' tracer spanName (addAttributesToSpanArguments attributes consumerSpanArgs) $ \_span -> do
              return $ Right cr
