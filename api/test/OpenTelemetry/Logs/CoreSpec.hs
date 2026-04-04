{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Logs.CoreSpec where

import Control.Concurrent.Async (async, mapConcurrently_)
import Control.Monad (void)
import qualified Data.HashMap.Strict as H
import Data.IORef (atomicModifyIORef', newIORef, readIORef, writeIORef)
import Data.Int (Int64)
import qualified Data.Text as T
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common (Timestamp (..))
import OpenTelemetry.Context (insertSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext, getContext)
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (ShutdownResult (..))
import OpenTelemetry.Internal.Logs.Types
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Logs.Core
import OpenTelemetry.Resource
import OpenTelemetry.Resource.OperatingSystem
import OpenTelemetry.Trace.Core (SpanContext (..), defaultTraceFlags, getSpanContext, setSampled, wrapSpanContext)
import OpenTelemetry.Trace.Id (bytesToSpanId, bytesToTraceId)
import qualified OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Common (Timestamp (..), mkTimestamp)
import Test.Hspec


newtype TestLogRecordProcessor = TestLogRecordProcessor LogRecordProcessor


instance Show TestLogRecordProcessor where
  show _ = "LogRecordProcessor {..}"


spec :: Spec
spec = describe "Core" $ do
  describe "The global logger provider" $ do
    it "Returns a no-op LoggerProvider when not initialized" $ do
      LoggerProvider {..} <- getGlobalLoggerProvider
      fmap TestLogRecordProcessor loggerProviderProcessors `shouldSatisfy` null
      loggerProviderResource `shouldBe` emptyMaterializedResources
      loggerProviderAttributeLimits `shouldBe` LA.defaultAttributeLimits
    it "Allows a LoggerProvider to be set and returns that with subsequent calls to getGlobalLoggerProvider" $ do
      lp <-
        createLoggerProvider [] $
          LoggerProviderOptions
            { loggerProviderOptionsResource =
                materializeResources $
                  toResource
                    OperatingSystem
                      { osType = "exampleOs"
                      , osDescription = Nothing
                      , osName = Nothing
                      , osVersion = Nothing
                      }
            , loggerProviderOptionsAttributeLimits =
                LA.AttributeLimits
                  { attributeCountLimit = Just 50
                  , attributeLengthLimit = Just 50
                  }
            }

      setGlobalLoggerProvider lp

      glp <- getGlobalLoggerProvider
      fmap TestLogRecordProcessor (loggerProviderProcessors glp) `shouldSatisfy` null
      loggerProviderResource glp `shouldBe` loggerProviderResource lp
      loggerProviderAttributeLimits glp `shouldBe` loggerProviderAttributeLimits lp
  describe "addAttribute" $ do
    it "works" $ do
      lp <- getGlobalLoggerProvider
      let l = makeLogger lp InstrumentationLibrary {libraryName = "exampleLibrary", libraryVersion = "", librarySchemaUrl = "", libraryAttributes = A.emptyAttributes}
      lr <- emitLogRecord l $ emptyLogRecordArguments {attributes = H.fromList [("something", "a thing")]}

      addAttribute lr "anotherThing" ("another thing" :: LA.AnyValue)

      (_, attrs) <- LA.getAttributeMap <$> logRecordGetAttributes lr
      attrs
        `shouldBe` H.fromList
          [ ("anotherThing", "another thing")
          , ("something", "a thing")
          ]
  describe "addAttributes" $ do
    it "works" $ do
      lp <- getGlobalLoggerProvider
      let l = makeLogger lp InstrumentationLibrary {libraryName = "exampleLibrary", libraryVersion = "", librarySchemaUrl = "", libraryAttributes = A.emptyAttributes}
      lr <- emitLogRecord l $ emptyLogRecordArguments {attributes = H.fromList [("something", "a thing")]}

      addAttributes lr $
        H.fromList
          [ ("anotherThing", "another thing" :: LA.AnyValue)
          , ("twoThing", "the second another thing")
          ]

      (_, attrs) <- LA.getAttributeMap <$> logRecordGetAttributes lr
      attrs
        `shouldBe` H.fromList
          [ ("anotherThing", "another thing")
          , ("something", "a thing")
          , ("twoThing", "the second another thing")
          ]
  describe "observed_timestamp" $ do
    it "defaults to a non-zero timestamp when not set" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      ilr <- readLogRecord lr
      let Timestamp obsNs = logRecordObservedTimestamp ilr
      obsNs `shouldSatisfy` (/= 0)

    it "uses explicit value when provided" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
          explicit = mkTimestamp 1234567890 0
      lr <- emitLogRecord l emptyLogRecordArguments {observedTimestamp = Just explicit}
      ilr <- readLogRecord lr
      logRecordObservedTimestamp ilr `shouldBe` explicit

  describe "LoggerProvider shutdown" $ do
    it "emitLogRecord does not invoke processors after shutdown" $ do
      callCount <- newAtomicCounter 0
      let countingProcessor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ ->
                  void $ incrAtomicCounter callCount
              , logRecordProcessorShutdown = async (pure ShutdownSuccess)
              , logRecordProcessorForceFlush = pure ()
              }
      lp <- createLoggerProvider [countingProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments
      beforeShutdown <- readAtomicCounter callCount
      beforeShutdown `shouldBe` 1

      shutdownLoggerProvider lp
      _ <- emitLogRecord l emptyLogRecordArguments
      afterShutdown <- readAtomicCounter callCount
      afterShutdown `shouldBe` 1

    it "emitLogRecord still returns a LogRecord after shutdown" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      shutdownLoggerProvider lp
      lr <- emitLogRecord l emptyLogRecordArguments
      ilr <- readLogRecord lr
      let Timestamp obsNs = logRecordObservedTimestamp ilr
      obsNs `shouldSatisfy` (/= 0)

    it "loggerIsEnabled returns False after shutdown" $ do
      let countingProcessor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = async (pure ShutdownSuccess)
              , logRecordProcessorForceFlush = pure ()
              }
      lp <- createLoggerProvider [countingProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled1 <- loggerIsEnabled l
      enabled1 `shouldBe` True
      shutdownLoggerProvider lp
      enabled2 <- loggerIsEnabled l
      enabled2 `shouldBe` False

  describe "log-trace correlation" $ do
    it "log record carries active span's traceId, spanId, and traceFlags" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      ilr <- readLogRecord lr
      logRecordTracingDetails ilr `shouldBe` Just (tid, sid, setSampled defaultTraceFlags)

    it "log record has no tracing details when no span is active" $ do
      adjustContext (\_ -> mempty)
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      ilr <- readLogRecord lr
      logRecordTracingDetails ilr `shouldBe` Nothing

    it "log record uses explicit context when provided" $ do
      let Right tid = bytesToTraceId "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
          Right sid = bytesToSpanId "\x01\x02\x03\x04\x05\x06\x07\x08"
          sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
          explicitCtx = insertSpan (wrapSpanContext sc) mempty
      adjustContext (\_ -> mempty)
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments {context = Just explicitCtx}
      ilr <- readLogRecord lr
      logRecordTracingDetails ilr `shouldBe` Just (tid, sid, defaultTraceFlags)

    it "processor receives the current context alongside the log record" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      ctxRef <- newIORef Nothing
      let capturingProcessor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ ctx -> writeIORef ctxRef (Just ctx)
              , logRecordProcessorShutdown = async (pure ShutdownSuccess)
              , logRecordProcessorForceFlush = pure ()
              }
      lp <- createLoggerProvider [capturingProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments
      mCtx <- readIORef ctxRef
      case mCtx of
        Nothing -> expectationFailure "expected processor to receive context"
        Just _ -> pure ()

  describe "concurrent addAttribute" $ do
    it "retains all attributes when many threads add unique keys" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      mapConcurrently_ (\i -> addAttribute lr ("key" <> T.pack (show i)) (fromIntegral i :: Int64)) [(1 :: Int) .. 100]
      ilr <- readLogRecord lr
      let (cnt, attrs) = LA.getAttributeMap (logRecordAttributes ilr)
      cnt `shouldBe` 100
      H.size attrs `shouldBe` 100

  describe "Log attribute limits" $ do
    it "enforces attributeCountLimit by dropping excess attributes" $ do
      lp <-
        createLoggerProvider [] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits =
                LA.AttributeLimits
                  { attributeCountLimit = Just 3
                  , attributeLengthLimit = Nothing
                  }
            }
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      addAttribute lr "a1" ("v1" :: LA.AnyValue)
      addAttribute lr "a2" ("v2" :: LA.AnyValue)
      addAttribute lr "a3" ("v3" :: LA.AnyValue)
      addAttribute lr "a4" ("v4" :: LA.AnyValue)
      addAttribute lr "a5" ("v5" :: LA.AnyValue)
      ilr <- readLogRecord lr
      let (cnt, _) = LA.getAttributeMap (logRecordAttributes ilr)
      cnt `shouldBe` 3

    it "enforces attributeLengthLimit by truncating string values" $ do
      lp <-
        createLoggerProvider [] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits =
                LA.AttributeLimits
                  { attributeCountLimit = Nothing
                  , attributeLengthLimit = Just 5
                  }
            }
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      addAttribute lr "key" (LA.TextValue "abcdefghij")
      ilr <- readLogRecord lr
      let (_, attrs) = LA.getAttributeMap (logRecordAttributes ilr)
      case H.lookup "key" attrs of
        Just (LA.TextValue t) -> T.length t `shouldSatisfy` (<= 5)
        _ -> expectationFailure "expected TextValue"

  describe "Multi-processor ordering" $ do
    it "processors are called in registration order" $ do
      orderRef <- newIORef ([] :: [String])
      let mkProc label =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ ->
                  atomicModifyIORef' orderRef (\xs -> (xs ++ [label], ()))
              , logRecordProcessorShutdown = async (pure ShutdownSuccess)
              , logRecordProcessorForceFlush = pure ()
              }
      lp <- createLoggerProvider [mkProc "A", mkProc "B"] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments
      order <- readIORef orderRef
      order `shouldBe` ["A", "B"]
