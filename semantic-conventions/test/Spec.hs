{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Data.Int (Int64)
import Data.Text (Text)
import OpenTelemetry.Attributes.Key (AttributeKey, unkey)
import OpenTelemetry.SemanticConventions
import Test.Hspec (describe, hspec, it, shouldBe)


main :: IO ()
main = hspec $ do
  describe "1.45 names and wire types" $ do
    it "provides the stable string RPC status key" $
      textKey rpc_statusCode `shouldBe` "rpc.status_code"
    it "provides string-array RPC header and trailer templates" $ do
      arrayKey (rpc_request_header "x-request-id") `shouldBe` "rpc.request.header.x-request-id"
      arrayKey (rpc_response_header "content-type") `shouldBe` "rpc.response.header.content-type"
      arrayKey (rpc_response_trailer "grpc-status-details-bin") `shouldBe` "rpc.response.trailer.grpc-status-details-bin"
    it "provides the renamed Kafka keys and integer offset" $ do
      textKey messaging_system_name `shouldBe` "messaging.system.name"
      textKey kafka_message_key `shouldBe` "kafka.message.key"
      intKey kafka_offset `shouldBe` "kafka.offset"
      textKey kafka_cluster_id `shouldBe` "kafka.cluster.id"
    it "provides the FaaS and device replacements" $ do
      textKey faas_invocation_id `shouldBe` "faas.invocation.id"
      textKey faas_invocation_startTime `shouldBe` "faas.invocation.start_time"
      textKey system_device_name `shouldBe` "system.device.name"
    it "provides the new network and opt-in body-content keys" $ do
      intKey client_as_number `shouldBe` "client.as.number"
      textKey client_prefix `shouldBe` "client.prefix"
      textKey http_request_body_content `shouldBe` "http.request.body.content"
      textKey http_response_body_content `shouldBe` "http.response.body.content"

  describe "compatibility with existing attribute keys" $ do
    it "retains old RPC wire names and template value types" $ do
      textKey rpc_response_statusCode `shouldBe` "rpc.response.status_code"
      arrayKey (rpc_request_metadata "x-key") `shouldBe` "rpc.request.metadata.x-key"
      arrayKey (rpc_response_metadata "x-key") `shouldBe` "rpc.response.metadata.x-key"
    it "retains old Kafka wire names and types" $ do
      textKey messaging_system `shouldBe` "messaging.system"
      textKey messaging_kafka_message_key `shouldBe` "messaging.kafka.message.key"
      intKey messaging_kafka_message_offset `shouldBe` "messaging.kafka.message.offset"
      intKey messaging_kafka_destination_partition `shouldBe` "messaging.kafka.destination.partition"
    it "retains old FaaS and device wire names" $ do
      textKey faas_invocationId `shouldBe` "faas.invocation_id"
      textKey faas_time `shouldBe` "faas.time"
      textKey system_device `shouldBe` "system.device"
    it "retains deprecated keys whose successor registries moved upstream" $ do
      textKey enduser_id `shouldBe` "enduser.id"
      textKey zos_sysplex_name `shouldBe` "zos.sysplex.name"


textKey :: AttributeKey Text -> Text
textKey = unkey


arrayKey :: AttributeKey [Text] -> Text
arrayKey = unkey


intKey :: AttributeKey Int64 -> Text
intKey = unkey
