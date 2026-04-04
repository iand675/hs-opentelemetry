{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import qualified Control.Exception as E
import Data.IORef
import Data.Maybe (listToMaybe)
import qualified Data.Text as T
import Database.Redis (runRedis)
import qualified Database.Redis as Redis
import OpenTelemetry.Attributes (lookupAttribute)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Hedis
import OpenTelemetry.Trace.Core
import Test.Hspec


main :: IO ()
main = hspec spec


withTracerProvider :: (TracerProvider -> IO a) -> IO ([ImmutableSpan], a)
withTracerProvider action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  setGlobalTracerProvider tp
  result <- action tp
  shutdownTracerProvider tp
  spans <- readIORef ref
  pure (spans, result)


spec :: Spec
spec = do
  describe "RedisInstrumentationConfig" $ do
    it "extracts host and port from ConnectInfo" $ do
      let cfg = defaultRedisInstrumentationConfig defaultConnectInfo
      redisHost cfg `shouldBe` "localhost"
      redisPort cfg `shouldBe` 6379

    it "extracts database index" $ do
      let cfg = defaultRedisInstrumentationConfig defaultConnectInfo {Redis.connectDatabase = 5}
      redisDatabaseIndex cfg `shouldBe` 5

    it "handles unix socket (port = 0)" $ do
      let cfg =
            defaultRedisInstrumentationConfig
              defaultConnectInfo {Redis.connectPort = UnixSocket "/var/run/redis.sock"}
      redisPort cfg `shouldBe` 0

  describe "Integration (requires Redis)" $ beforeAll checkRedis $ do
    it "pre-traced GET creates a client span with correct attributes" $ \conn -> do
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          get "otel-test-key"
      length spans `shouldSatisfy` (>= 1)
      let Just s = listToMaybe spans
      spanName s `shouldBe` "GET"
      spanKind s `shouldBe` Client
      lookupAttrText s "db.system.name" `shouldBe` Just "redis"
      lookupAttrText s "db.operation.name" `shouldBe` Just "GET"
      lookupAttrText s "db.namespace" `shouldBe` Just "0"
      lookupAttrText s "server.address" `shouldBe` Just "localhost"

    it "pre-traced SET creates a span" $ \conn -> do
      (spans, result) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          set "otel-test-key" "otel-test-val"
      case result of
        Right _ -> pure ()
        Left reply -> expectationFailure $ "SET failed: " <> show reply
      let Just s = listToMaybe spans
      spanName s `shouldBe` "SET"
      lookupAttrText s "db.operation.name" `shouldBe` Just "SET"

    it "multiple commands create multiple spans" $ \conn -> do
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          set "otel-multi-key" "val"
          get "otel-multi-key"
      length spans `shouldBe` 2
      let names = map spanName spans
      names `shouldContain` ["SET"]
      names `shouldContain` ["GET"]

    it "hash commands produce correct span names" $ \conn -> do
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          hset "otel-hash" "field1" "val1"
          hget "otel-hash" "field1"
          hdel "otel-hash" ["field1"]
      length spans `shouldBe` 3
      let names = map spanName spans
      names `shouldContain` ["HSET"]
      names `shouldContain` ["HGET"]
      names `shouldContain` ["HDEL"]

    it "list commands produce correct span names" $ \conn -> do
      -- clean up from prior runs
      runRedis conn $ Redis.del ["otel-list"]
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          lpush "otel-list" ["a", "b"]
          lrange "otel-list" 0 (-1)
          del ["otel-list"]
      length spans `shouldBe` 3
      let names = map spanName spans
      names `shouldContain` ["LPUSH"]
      names `shouldContain` ["LRANGE"]
      names `shouldContain` ["DEL"]

    it "INCR/DECR produce correct span names" $ \conn -> do
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          set "otel-counter" "0"
          incr "otel-counter"
          decrby "otel-counter" 3
          del ["otel-counter"]
      length spans `shouldBe` 4
      let names = map spanName spans
      names `shouldContain` ["SET"]
      names `shouldContain` ["INCR"]
      names `shouldContain` ["DECRBY"]
      names `shouldContain` ["DEL"]

    it "custom traced command works" $ \conn -> do
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedis defaultConnectInfo conn $ do
          traced "PING" Redis.ping
      length spans `shouldSatisfy` (>= 1)
      let Just s = listToMaybe spans
      spanName s `shouldBe` "PING"

    it "runTracedRedisWith accepts explicit config" $ \conn -> do
      let cfg = RedisInstrumentationConfig "custom-host" 9999 7
      (spans, _) <- withTracerProvider $ \_ ->
        runTracedRedisWith cfg conn $ do
          ping
      length spans `shouldSatisfy` (>= 1)
      let Just s = listToMaybe spans
      lookupAttrText s "server.address" `shouldBe` Just "custom-host"
      lookupAttrText s "db.namespace" `shouldBe` Just "7"


checkRedis :: IO Connection
checkRedis =
  E.try (checkedConnect defaultConnectInfo) >>= \case
    Left (_ :: E.SomeException) -> pendingWith "Redis not available" >> error "unreachable"
    Right conn -> do
      _ <- runRedis conn Redis.ping
      pure conn


lookupAttrText :: ImmutableSpan -> T.Text -> Maybe T.Text
lookupAttrText s key =
  case lookupAttribute (spanAttributes s) key of
    Just (A.AttributeValue (A.TextAttribute t)) -> Just t
    _ -> Nothing
