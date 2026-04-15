{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Log.CoreSpec where

import Control.Concurrent.Async (mapConcurrently_)
import Control.Monad (void)
import qualified Data.HashMap.Strict as H
import Data.IORef (atomicModifyIORef', newIORef, readIORef, writeIORef)
import Data.Int (Int64)
import qualified Data.Text as T
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common (Timestamp (..), mkTimestamp)
import OpenTelemetry.Context (insertSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext, getContext)
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Log.Core (getLoggerMinSeverity, setLoggerMinSeverity)
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Log.Core
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Resource
import OpenTelemetry.Resource.OperatingSystem
import OpenTelemetry.Trace.Core (SpanContext (..), defaultTraceFlags, getSpanContext, setSampled, wrapSpanContext)
import OpenTelemetry.Trace.Id (bytesToSpanId, bytesToTraceId)
import qualified OpenTelemetry.Trace.TraceState as TraceState
import Test.Hspec


newtype TestLogRecordProcessor = TestLogRecordProcessor LogRecordProcessor


instance Show TestLogRecordProcessor where
  show _ = "LogRecordProcessor {..}"


spec :: Spec
spec = describe "Core" $ do
  -- Logs Bridge API §LoggerProvider: global provider and no-op defaults
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
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
                      , osBuildId = Nothing
                      }
            , loggerProviderOptionsAttributeLimits =
                LA.AttributeLimits
                  { attributeCountLimit = Just 50
                  , attributeLengthLimit = Just 50
                  }
            , loggerProviderOptionsMinSeverity = Nothing
            }

      setGlobalLoggerProvider lp

      glp <- getGlobalLoggerProvider
      fmap TestLogRecordProcessor (loggerProviderProcessors glp) `shouldSatisfy` null
      loggerProviderResource glp `shouldBe` loggerProviderResource lp
      loggerProviderAttributeLimits glp `shouldBe` loggerProviderAttributeLimits lp
  -- Logs Bridge API §LogRecord: mutable attributes on emitted records
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
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
  -- Logs Bridge API §LogRecord: batch attribute updates
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
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
  -- Logs Bridge API §LogRecord: observed timestamp field
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
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

  -- Logs Bridge API §LoggerProvider: Shutdown and post-shutdown behavior
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
  describe "LoggerProvider shutdown" $ do
    it "emitLogRecord does not invoke processors after shutdown" $ do
      callCount <- newAtomicCounter 0
      let countingProcessor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ ->
                  void $ incrAtomicCounter callCount
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [countingProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments
      beforeShutdown <- readAtomicCounter callCount
      beforeShutdown `shouldBe` 1

      _ <- shutdownLoggerProvider lp Nothing
      _ <- emitLogRecord l emptyLogRecordArguments
      afterShutdown <- readAtomicCounter callCount
      afterShutdown `shouldBe` 1

    it "emitLogRecord still returns a LogRecord after shutdown" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- shutdownLoggerProvider lp Nothing
      lr <- emitLogRecord l emptyLogRecordArguments
      ilr <- readLogRecord lr
      let Timestamp obsNs = logRecordObservedTimestamp ilr
      obsNs `shouldSatisfy` (/= 0)

    it "loggerIsEnabled returns False after shutdown" $ do
      let countingProcessor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [countingProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled1 <- loggerIsEnabled l Nothing Nothing
      enabled1 `shouldBe` True
      _ <- shutdownLoggerProvider lp Nothing
      enabled2 <- loggerIsEnabled l Nothing Nothing
      enabled2 `shouldBe` False

    it "shutdown is idempotent (second call returns failure)" $ do
      let processor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [processor] emptyLoggerProviderOptions
      r1 <- shutdownLoggerProvider lp Nothing
      r1 `shouldBe` ShutdownSuccess
      r2 <- shutdownLoggerProvider lp Nothing
      r2 `shouldBe` ShutdownFailure

    it "loggerIsEnabled accepts severity parameter" $ do
      let processor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [processor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled <- loggerIsEnabled l (Just Warn) Nothing
      enabled `shouldBe` True

    it "loggerIsEnabled accepts eventName parameter" $ do
      let processor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [processor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled <- loggerIsEnabled l Nothing (Just "my.event")
      enabled `shouldBe` True

    it "loggerIsEnabled accepts both severity and eventName" $ do
      let processor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [processor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled <- loggerIsEnabled l (Just Error4) (Just "error.event")
      enabled `shouldBe` True

  -- Logs Bridge API §LoggerProvider: ForceFlush
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
  describe "forceFlushLoggerProvider" $ do
    it "returns FlushSuccess when processors succeed" $ do
      let processor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [processor] emptyLoggerProviderOptions
      result <- forceFlushLoggerProvider lp Nothing
      result `shouldBe` FlushSuccess

    it "returns FlushError when a processor flush throws" $ do
      let failingProcessor =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> pure ()
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = error "flush boom"
              }
      lp <- createLoggerProvider [failingProcessor] emptyLoggerProviderOptions
      result <- forceFlushLoggerProvider lp Nothing
      result `shouldBe` FlushError

    it "returns FlushSuccess with no processors" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      result <- forceFlushLoggerProvider lp Nothing
      result `shouldBe` FlushSuccess

  -- Logs data model §Trace context fields: correlate logs with traces
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
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
      toBaseMaybe (logRecordTracingDetails ilr) `shouldBe` Just (tid, sid, setSampled defaultTraceFlags)

    it "log record has no tracing details when no span is active" $ do
      adjustContext (\_ -> mempty)
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      ilr <- readLogRecord lr
      toBaseMaybe (logRecordTracingDetails ilr) `shouldBe` Nothing

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
      toBaseMaybe (logRecordTracingDetails ilr) `shouldBe` Just (tid, sid, defaultTraceFlags)

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
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [capturingProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments
      mCtx <- readIORef ctxRef
      case mCtx of
        Nothing -> expectationFailure "expected processor to receive context"
        Just _ -> pure ()

  -- Implementation-specific: concurrent mutation of LogRecord attributes
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
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

  -- Common §Attribute limits (applied to LogRecord attributes)
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute-limits
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
            , loggerProviderOptionsMinSeverity = Nothing
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
            , loggerProviderOptionsMinSeverity = Nothing
            }
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      lr <- emitLogRecord l emptyLogRecordArguments
      addAttribute lr "key" (LA.TextValue "abcdefghij")
      ilr <- readLogRecord lr
      let (_, attrs) = LA.getAttributeMap (logRecordAttributes ilr)
      case H.lookup "key" attrs of
        Just (LA.TextValue t) -> T.length t `shouldSatisfy` (<= 5)
        _ -> expectationFailure "expected TextValue"

  -- Logs SDK §LogRecordProcessor: processor pipeline ordering (implementation)
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
  describe "Multi-processor ordering" $ do
    it "processors are called in registration order" $ do
      orderRef <- newIORef ([] :: [String])
      let mkProc label =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ ->
                  atomicModifyIORef' orderRef (\xs -> (xs ++ [label], ()))
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [mkProc "A", mkProc "B"] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments
      order <- readIORef orderRef
      order `shouldBe` ["A", "B"]

  -- Logs Bridge API §Severity: Logger.isEnabled / minimum severity filtering
  -- https://opentelemetry.io/docs/specs/otel/logs/bridge-api/
  describe "Severity filtering" $ do
    it "loggerIsEnabled returns True when no minSeverity is set" $ do
      lp <- createLoggerProvider [noopProcessor] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled <- loggerIsEnabled l (Just Debug) Nothing
      enabled `shouldBe` True

    it "loggerIsEnabled returns True when severity >= threshold" $ do
      lp <- createLoggerProvider [noopProcessor] emptyLoggerProviderOptions {loggerProviderOptionsMinSeverity = Just Warn}
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      e1 <- loggerIsEnabled l (Just Warn) Nothing
      e1 `shouldBe` True
      e2 <- loggerIsEnabled l (Just Error) Nothing
      e2 `shouldBe` True
      e3 <- loggerIsEnabled l (Just Fatal) Nothing
      e3 `shouldBe` True

    it "loggerIsEnabled returns False when severity < threshold" $ do
      lp <- createLoggerProvider [noopProcessor] emptyLoggerProviderOptions {loggerProviderOptionsMinSeverity = Just Warn}
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      e1 <- loggerIsEnabled l (Just Debug) Nothing
      e1 `shouldBe` False
      e2 <- loggerIsEnabled l (Just Info) Nothing
      e2 `shouldBe` False
      e3 <- loggerIsEnabled l (Just Trace) Nothing
      e3 `shouldBe` False

    it "loggerIsEnabled returns True when severity is Nothing (unspecified)" $ do
      lp <- createLoggerProvider [noopProcessor] emptyLoggerProviderOptions {loggerProviderOptionsMinSeverity = Just Error}
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      enabled <- loggerIsEnabled l Nothing Nothing
      enabled `shouldBe` True

    it "emitLogRecord skips processors when severity < threshold" $ do
      callCount <- newAtomicCounter 0
      let counting =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> void $ incrAtomicCounter callCount
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [counting] emptyLoggerProviderOptions {loggerProviderOptionsMinSeverity = Just Warn}
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Debug}
      c1 <- readAtomicCounter callCount
      c1 `shouldBe` 0
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Warn}
      c2 <- readAtomicCounter callCount
      c2 `shouldBe` 1
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Error}
      c3 <- readAtomicCounter callCount
      c3 `shouldBe` 2

    it "emitLogRecord forwards records with no severity when threshold is set" $ do
      callCount <- newAtomicCounter 0
      let counting =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> void $ incrAtomicCounter callCount
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [counting] emptyLoggerProviderOptions {loggerProviderOptionsMinSeverity = Just Error}
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Nothing}
      c <- readAtomicCounter callCount
      c `shouldBe` 1

    it "setLoggerMinSeverity changes threshold at runtime" $ do
      callCount <- newAtomicCounter 0
      let counting =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> void $ incrAtomicCounter callCount
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [counting] emptyLoggerProviderOptions
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Debug}
      c1 <- readAtomicCounter callCount
      c1 `shouldBe` 1
      setLoggerMinSeverity lp (Just Error)
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Debug}
      c2 <- readAtomicCounter callCount
      c2 `shouldBe` 1
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Error}
      c3 <- readAtomicCounter callCount
      c3 `shouldBe` 2

    it "getLoggerMinSeverity reads the current threshold" $ do
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      s0 <- getLoggerMinSeverity lp
      s0 `shouldBe` Nothing
      setLoggerMinSeverity lp (Just Warn)
      s1 <- getLoggerMinSeverity lp
      s1 `shouldBe` Just Warn
      setLoggerMinSeverity lp Nothing
      s2 <- getLoggerMinSeverity lp
      s2 `shouldBe` Nothing

    it "setLoggerMinSeverity to Nothing disables filtering" $ do
      callCount <- newAtomicCounter 0
      let counting =
            LogRecordProcessor
              { logRecordProcessorOnEmit = \_ _ -> void $ incrAtomicCounter callCount
              , logRecordProcessorShutdown = pure ShutdownSuccess
              , logRecordProcessorForceFlush = pure FlushSuccess
              }
      lp <- createLoggerProvider [counting] emptyLoggerProviderOptions {loggerProviderOptionsMinSeverity = Just Fatal}
      let l = makeLogger lp (instrumentationLibrary "test" "1.0")
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Debug}
      c1 <- readAtomicCounter callCount
      c1 `shouldBe` 0
      setLoggerMinSeverity lp Nothing
      _ <- emitLogRecord l emptyLogRecordArguments {severityNumber = Just Debug}
      c2 <- readAtomicCounter callCount
      c2 `shouldBe` 1


noopProcessor :: LogRecordProcessor
noopProcessor =
  LogRecordProcessor
    { logRecordProcessorOnEmit = \_ _ -> pure ()
    , logRecordProcessorShutdown = pure ShutdownSuccess
    , logRecordProcessorForceFlush = pure FlushSuccess
    }
