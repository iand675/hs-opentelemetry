{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString as BS
import qualified Data.HashMap.Strict as H
import Kafka.Consumer (ConsumerRecord (..), Offset (..), Timestamp (..))
import Kafka.Consumer.ConsumerProperties (ConsumerProperties, clientId, groupId)
import Kafka.Consumer.Types (ConsumerGroupId (..))
import Kafka.Producer (ProducePartition (..), ProducerRecord (..))
import Kafka.Types (ClientId (..), PartitionId (..), TopicName (..), headersFromList)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Instrumentation.Kafka (consumerAttributes, producerAttributes)
import Test.Hspec


main :: IO ()
main = hspec spec


testProducerRecord :: ProducerRecord
testProducerRecord =
  ProducerRecord
    { prTopic = TopicName "orders"
    , prPartition = SpecifiedPartition 3
    , prKey = Just "order-123"
    , prValue = Just "payload-data"
    , prHeaders = headersFromList []
    }


testConsumerRecord :: ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)
testConsumerRecord =
  ConsumerRecord
    { crTopic = TopicName "events"
    , crPartition = PartitionId 1
    , crOffset = Offset 42
    , crTimestamp = NoTimestamp
    , crHeaders = headersFromList []
    , crKey = Just "event-key"
    , crValue = Just "event-body-data"
    }


testConsumerProps :: ConsumerProperties
testConsumerProps =
  groupId (ConsumerGroupId "my-consumer-group")
    <> clientId (ClientId "my-client")


spec :: Spec
spec = do
  describe "producerAttributes" $ do
    let attrs = producerAttributes testProducerRecord

    it "sets messaging.system to kafka" $
      H.lookup "messaging.system" attrs `shouldBe` Just (AttributeValue (TextAttribute "kafka"))

    it "sets messaging.operation to send" $
      H.lookup "messaging.operation" attrs `shouldBe` Just (AttributeValue (TextAttribute "send"))

    it "sets messaging.operation.name to send" $
      H.lookup "messaging.operation.name" attrs `shouldBe` Just (AttributeValue (TextAttribute "send"))

    it "sets messaging.operation.type to send" $
      H.lookup "messaging.operation.type" attrs `shouldBe` Just (AttributeValue (TextAttribute "send"))

    it "sets messaging.destination.name to topic" $
      H.lookup "messaging.destination.name" attrs `shouldBe` Just (AttributeValue (TextAttribute "orders"))

    it "sets messaging.kafka.destination.partition" $
      H.lookup "messaging.kafka.destination.partition" attrs `shouldSatisfy` (/= Nothing)

    it "sets messaging.kafka.message.key" $
      H.lookup "messaging.kafka.message.key" attrs `shouldBe` Just (AttributeValue (TextAttribute "order-123"))

    it "sets messaging.message.body.size for non-empty value" $
      H.lookup "messaging.message.body.size" attrs `shouldBe` Just (AttributeValue (IntAttribute 12))

    it "does not set body size when value is Nothing" $ do
      let noValueRecord = testProducerRecord {prValue = Nothing}
          noValueAttrs = producerAttributes noValueRecord
      H.lookup "messaging.message.body.size" noValueAttrs `shouldBe` Nothing

  describe "consumerAttributes" $ do
    let attrs = consumerAttributes testConsumerProps testConsumerRecord

    it "sets messaging.system to kafka" $
      H.lookup "messaging.system" attrs `shouldBe` Just (AttributeValue (TextAttribute "kafka"))

    it "sets messaging.operation to process" $
      H.lookup "messaging.operation" attrs `shouldBe` Just (AttributeValue (TextAttribute "process"))

    it "sets messaging.operation.name to process" $
      H.lookup "messaging.operation.name" attrs `shouldBe` Just (AttributeValue (TextAttribute "process"))

    it "sets messaging.operation.type to process" $
      H.lookup "messaging.operation.type" attrs `shouldBe` Just (AttributeValue (TextAttribute "process"))

    it "sets messaging.destination.name to topic" $
      H.lookup "messaging.destination.name" attrs `shouldBe` Just (AttributeValue (TextAttribute "events"))

    it "sets messaging.consumer.group.name from consumer properties" $
      H.lookup "messaging.consumer.group.name" attrs `shouldBe` Just (AttributeValue (TextAttribute "my-consumer-group"))

    it "sets messaging.client.id from consumer properties" $
      H.lookup "messaging.client.id" attrs `shouldBe` Just (AttributeValue (TextAttribute "my-client"))

    it "sets messaging.kafka.message.offset" $
      H.lookup "messaging.kafka.message.offset" attrs `shouldSatisfy` (/= Nothing)

    it "sets messaging.message.body.size for non-empty value" $
      H.lookup "messaging.message.body.size" attrs `shouldBe` Just (AttributeValue (IntAttribute 15))

    it "sets messaging.kafka.message.key" $
      H.lookup "messaging.kafka.message.key" attrs `shouldBe` Just (AttributeValue (TextAttribute "event-key"))
