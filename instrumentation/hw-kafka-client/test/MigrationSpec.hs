{-# LANGUAGE OverloadedStrings #-}

module MigrationSpec (spec, producerHelper) where

import Control.Exception (bracket, bracket_)
import Control.Monad (forM_)
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.HashMap.Strict as H
import Data.IORef (readIORef)
import Data.Int (Int64)
import qualified Data.Map.Strict as M
import Data.Text (Text)
import qualified Data.Text as T
import Kafka.Consumer (ConsumerRecord (..), Offset (..), Timestamp (..))
import Kafka.Consumer.ConsumerProperties (ConsumerProperties, clientId, groupId)
import Kafka.Consumer.Types (ConsumerGroupId (..))
import Kafka.Producer (ProducePartition (..), ProducerRecord (..))
import qualified Kafka.Producer as Kafka
import Kafka.Types (ClientId (..), PartitionId (..), TopicName (..), headersFromList)
import OpenTelemetry.Attributes (Attribute (..), AttributeMap, PrimitiveAttribute (..), getAttributeMap)
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Kafka
import OpenTelemetry.SemanticsConfig (SemanticsOptions, StabilityOpt (..), getSemanticsOptions')
import OpenTelemetry.Trace.Core
import System.Environment (getEnvironment, getExecutablePath, lookupEnv, setEnv, unsetEnv)
import System.Exit (ExitCode (..))
import System.Process (CreateProcess (..), proc, readCreateProcessWithExitCode)
import System.Timeout (timeout)
import Test.Hspec


spec :: Spec
spec = describe "Kafka 1.45 attribute migration" $ do
  forM_
    [ (Nothing, Old)
    , (Just "messaging", Stable)
    , (Just "messaging/dup", StableAndOld)
    , (Just "http/dup,unknown", Old)
    , (Just "messaging/1.450", Old)
    ]
    $ \(setting, legacy) ->
      it ("preserves existing producer and consumer maps for " ++ show setting) $
        withOptions setting $ \options -> do
          telemetry (producerAttributesWithSemantics options producer)
            `shouldBe` telemetry (producerAttributes legacy producer)
          telemetry (consumerAttributesWithSemantics options properties consumer)
            `shouldBe` telemetry (consumerAttributes legacy properties consumer)

  forM_ ["messaging/1.45", "messaging/dup,messaging/1.45"] $ \setting ->
    it ("emits only current names for " ++ setting) $
      withOptions (Just setting) $ \options -> do
        telemetry (producerAttributesWithSemantics options producer) `shouldBe` currentProducer
        telemetry (consumerAttributesWithSemantics options properties consumer) `shouldBe` currentConsumer

  forM_
    [ ("messaging/1.45/dup", Old)
    , ("messaging,messaging/1.45/dup", Stable)
    , ("messaging/dup,messaging/1.45/dup", StableAndOld)
    , ("messaging/1.45,messaging/1.45/dup", Old)
    , ("messaging/1.45/dup,messaging/1.45", Old)
    , (" http , messaging/1.45/dup , messaging ", Stable)
    ]
    $ \(setting, legacy) ->
      it ("dual emission retains the selected legacy map for " ++ setting) $
        withOptions (Just setting) $ \options -> do
          telemetry (producerAttributesWithSemantics options producer)
            `shouldBe` H.union currentProducer (telemetry (producerAttributes legacy producer))
          telemetry (consumerAttributesWithSemantics options properties consumer)
            `shouldBe` H.union currentConsumer (telemetry (consumerAttributes legacy properties consumer))

  it "omits unknown producer partitions without fabricating a value" $
    withOptions (Just "messaging/1.45/dup") $ \options -> do
      let attrs = producerAttributesWithSemantics options producer {prPartition = UnassignedPartition}
      H.lookup "messaging.destination.partition.id" attrs `shouldBe` Nothing
      H.lookup "messaging.kafka.destination.partition" attrs `shouldBe` Nothing

  forM_ ["messaging/1.45", "messaging/1.45/dup"] $ \setting -> do
    it ("omits absent and invalid UTF-8 keys in " ++ setting) $
      withOptions (Just setting) $ \options ->
        forM_ [Nothing, Just "\xff"] $ \key -> do
          let p = producerAttributesWithSemantics options producer {prKey = key}
              c = consumerAttributesWithSemantics options properties consumer {crKey = key}
          forM_ [p, c] $ \attrs -> do
            H.lookup "kafka.message.key" attrs `shouldBe` Nothing
            H.lookup "messaging.kafka.message.key" attrs `shouldBe` Nothing

    it ("keeps empty keys and distinguishes null from empty message values in " ++ setting) $
      withOptions (Just setting) $ \options -> do
        let p value = producerAttributesWithSemantics options producer {prKey = Just "", prValue = value}
            c value = consumerAttributesWithSemantics options properties consumer {crKey = Just "", crValue = value}
        forM_ [p, c] $ \build -> do
          H.lookup "kafka.message.key" (build Nothing) `shouldBe` Just (text "")
          H.lookup "kafka.message.tombstone" (build Nothing) `shouldBe` Just (AttributeValue (BoolAttribute True))
          H.lookup "messaging.message.body.size" (build Nothing) `shouldBe` Nothing
          H.lookup "kafka.message.tombstone" (build (Just "")) `shouldBe` Nothing
          H.lookup "messaging.message.body.size" (build (Just "")) `shouldBe` Just (int 0)

  it "preserves integer offset precision and omits unavailable group/cluster metadata" $
    withOptions (Just "messaging/1.45") $ \options -> do
      let attrs = consumerAttributesWithSemantics options mempty consumer {crOffset = Offset maxBound}
      H.lookup "kafka.offset" attrs `shouldBe` Just (int maxBound)
      H.lookup "messaging.consumer.group.name" attrs `shouldBe` Nothing
      H.lookup "kafka.cluster.id" attrs `shouldBe` Nothing

  forM_ [Nothing, Just "messaging", Just "messaging/dup", Just "messaging/1.45", Just "messaging/1.45/dup"] $ \setting ->
    it ("exports the selected producer and consumer attributes for " ++ show setting) $
      withOptions setting $ \options -> do
        (processor, ref) <- inMemoryListExporter
        bracket (createTracerProvider [processor] emptyTracerProviderOptions) (\tp -> shutdownTracerProvider tp Nothing) $ \tp -> do
          let tracer = makeTracer tp "kafka-migration" tracerOptions
              producerAttrs = producerAttributesWithSemantics options producer
              consumerAttrs = consumerAttributesWithSemantics options properties consumer
          inSpan'' tracer "send orders" (addAttributesToSpanArguments producerAttrs defaultSpanArguments {kind = Producer}) (\_ -> pure ())
          inSpan'' tracer "process events" (addAttributesToSpanArguments consumerAttrs defaultSpanArguments {kind = Consumer}) (\_ -> pure ())
          spans <- readIORef ref
          length spans `shouldBe` 2
          exported <- traverse (fmap (telemetry . getAttributeMap . hotAttributes) . readIORef . spanHot) spans
          exported `shouldMatchList` [telemetry producerAttrs, telemetry consumerAttrs]

  -- Each child gets a fresh memoized configuration snapshot. An oversized
  -- message is rejected locally, so this exercises the real wrapper without
  -- a broker, background delivery, or a network dependency.
  forM_ [Nothing, Just "messaging", Just "messaging/dup", Just "messaging/1.45", Just "messaging/1.45/dup"] $ \setting ->
    it ("the real producer wrapper uses the configured attributes for " ++ show setting) $ do
      executable <- getExecutablePath
      environment <- getEnvironment
      let withoutSetting = filter ((/= "OTEL_SEMCONV_STABILITY_OPT_IN") . fst) environment
          childEnv = maybe withoutSetting (\s -> ("OTEL_SEMCONV_STABILITY_OPT_IN", s) : withoutSetting) setting
      result <- timeout 10000000 $ readCreateProcessWithExitCode (proc executable ["--migration-producer-helper", "+RTS", "-N1", "-RTS"]) {env = Just childEnv} ""
      case result of
        Just (ExitSuccess, _, _) -> pure ()
        other -> expectationFailure (show other)


producerHelper :: IO ()
producerHelper = hspec $ it "exports attributes from the real produceMessage wrapper" $ do
  (processor, ref) <- inMemoryListExporter
  bracket (createTracerProvider [processor] emptyTracerProviderOptions) (\tp -> shutdownTracerProvider tp Nothing) $ \tp -> do
    setGlobalTracerProvider tp
    result <- Kafka.newProducer (Kafka.extraProps (M.fromList [("message.max.bytes", "1000"), ("message.timeout.ms", "10"), ("log_level", "0")]))
    case result of
      Left err -> expectationFailure (show err)
      Right kafka -> bracket (pure kafka) Kafka.closeProducer $ \p -> do
        let oversizedRecord = producer {prValue = Just (BS.replicate 2000 120)}
        sent <- produceMessage p oversizedRecord
        sent `shouldSatisfy` (/= Nothing)
        spans <- readIORef ref
        length spans `shouldBe` 1
        options <- getSemanticsOptions'
        exported <- traverse (fmap (telemetry . getAttributeMap . hotAttributes) . readIORef . spanHot) spans
        exported `shouldBe` [telemetry (producerAttributesWithSemantics options oversizedRecord)]


withOptions :: Maybe String -> (SemanticsOptions -> IO a) -> IO a
withOptions setting action = do
  original <- lookupEnv variable
  bracket_ (restore setting) (restore original) (getSemanticsOptions' >>= action)
  where
    variable = "OTEL_SEMCONV_STABILITY_OPT_IN"
    restore Nothing = unsetEnv variable
    restore (Just value) = setEnv variable value


telemetry :: AttributeMap -> AttributeMap
telemetry = H.filterWithKey (\key _ -> "messaging." `T.isPrefixOf` key || "kafka." `T.isPrefixOf` key)


text :: Text -> Attribute
text = AttributeValue . TextAttribute


int :: Int64 -> Attribute
int = AttributeValue . IntAttribute


currentProducer :: AttributeMap
currentProducer =
  H.fromList
    [ ("messaging.system.name", text "kafka")
    , ("messaging.operation.name", text "send")
    , ("messaging.operation.type", text "send")
    , ("messaging.destination.name", text "orders")
    , ("messaging.destination.partition.id", text "3")
    , ("kafka.message.key", text "order-123")
    , ("messaging.message.body.size", int 12)
    ]


currentConsumer :: AttributeMap
currentConsumer =
  H.fromList
    [ ("messaging.system.name", text "kafka")
    , ("messaging.operation.name", text "process")
    , ("messaging.operation.type", text "process")
    , ("messaging.destination.name", text "events")
    , ("messaging.destination.partition.id", text "1")
    , ("messaging.consumer.group.name", text "my-consumer-group")
    , ("messaging.client.id", text "my-client")
    , ("kafka.message.key", text "event-key")
    , ("kafka.offset", int 42)
    , ("messaging.message.body.size", int 15)
    ]


producer :: ProducerRecord
producer = ProducerRecord (TopicName "orders") (SpecifiedPartition 3) (Just "order-123") (Just "payload-data") (headersFromList [])


consumer :: ConsumerRecord (Maybe ByteString) (Maybe ByteString)
consumer = ConsumerRecord (TopicName "events") (PartitionId 1) (Offset 42) NoTimestamp (headersFromList []) (Just "event-key") (Just "event-body-data")


properties :: ConsumerProperties
properties = groupId (ConsumerGroupId "my-consumer-group") <> clientId (ClientId "my-client")
