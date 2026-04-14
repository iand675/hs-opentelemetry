{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.LogSpec where

import Control.Monad (replicateM_)
import qualified Data.HashMap.Strict as H
import Data.IORef
import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Exporter.LogRecord (LogRecordExporterArguments (..), mkLogRecordExporter)
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Log.Core
import OpenTelemetry.LogAttributes (AnyValue (..), ToValue (..))
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Processor.Batch.LogRecord (BatchLogRecordProcessorConfig (..), batchLogRecordProcessor, defaultBatchLogRecordProcessorConfig)
import OpenTelemetry.Resource (emptyMaterializedResources)
import System.Mem.StableName (eqStableName, makeStableName)
import Test.Hspec


spec :: Spec
spec = describe "OpenTelemetry.Log (SDK)" $ do
  -- Logs SDK
  -- https://opentelemetry.io/docs/specs/otel/logs/sdk/
  describe "getLogger scope caching" $ do
    it "getLogger returns same Logger for same scope" $ do
      -- OTel Logs SDK §LoggerProvider: "Implementations SHOULD return the same
      -- Logger instance when called multiple times with the same [scope identity]."
      -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#loggerprovider
      processor <- captureProcessor
      lp <-
        createLoggerProvider [processor] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits = defaultAttributeLimits
            , loggerProviderOptionsMinSeverity = Nothing
            }
      let scope = instrumentationLibrary "test-lib" "1.0"
      l1 <- getLogger lp scope
      l2 <- getLogger lp scope
      loggerInstrumentationScope l1 `shouldBe` loggerInstrumentationScope l2
      sn1 <- makeStableName l1
      sn2 <- makeStableName l2
      eqStableName sn1 sn2 `shouldBe` True
      let scope2 = instrumentationLibrary "other-lib" "2.0"
      l3 <- getLogger lp scope2
      loggerInstrumentationScope l3 `shouldNotBe` loggerInstrumentationScope l1
      sn3 <- makeStableName l3
      eqStableName sn1 sn3 `shouldBe` False

  describe "LogRecord attribute limits" $ do
    -- Logs SDK §LogRecord limits
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecord-limits
    specify "attributes within count limit are preserved" $ do
      let limits = AttributeLimits {attributeCountLimit = Just 3, attributeLengthLimit = Nothing}
      processor <- captureProcessor
      lp <-
        createLoggerProvider [processor] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits = limits
            , loggerProviderOptionsMinSeverity = Nothing
            }
      let logger = makeLogger lp testLib
      lr <-
        emitLogRecord logger $
          emptyLogRecordArguments
            { attributes = H.fromList [("a", toValue ("1" :: T.Text)), ("b", toValue ("2" :: T.Text))]
            , severityNumber = Just Info
            }
      ilr <- readLogRecord lr
      LA.attributesCount (logRecordAttributes ilr) `shouldBe` 2
      LA.attributesDropped (logRecordAttributes ilr) `shouldBe` 0

    -- Logs SDK §LogRecord limits: dropped attributes
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecord-limits
    specify "attributes exceeding count limit are dropped" $ do
      let limits = AttributeLimits {attributeCountLimit = Just 2, attributeLengthLimit = Nothing}
      processor <- captureProcessor
      lp <-
        createLoggerProvider [processor] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits = limits
            , loggerProviderOptionsMinSeverity = Nothing
            }
      let logger = makeLogger lp testLib
      lr <-
        emitLogRecord logger $
          emptyLogRecordArguments
            { attributes = H.fromList [("a", toValue ("1" :: T.Text)), ("b", toValue ("2" :: T.Text)), ("c", toValue ("3" :: T.Text))]
            , severityNumber = Just Info
            }
      ilr <- readLogRecord lr
      LA.attributesDropped (logRecordAttributes ilr) `shouldSatisfy` (> 0)

    -- Logs SDK §LogRecord limits: attribute value length
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecord-limits
    specify "length limit truncates log record attribute values" $ do
      let limits = AttributeLimits {attributeCountLimit = Nothing, attributeLengthLimit = Just 5}
      processor <- captureProcessor
      lp <-
        createLoggerProvider [processor] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits = limits
            , loggerProviderOptionsMinSeverity = Nothing
            }
      let logger = makeLogger lp testLib
      lr <-
        emitLogRecord logger $
          emptyLogRecordArguments
            { attributes = H.fromList [("key", toValue ("hello world" :: T.Text))]
            , severityNumber = Just Info
            }
      ilr <- readLogRecord lr
      LA.lookupAttribute (logRecordAttributes ilr) "key" `shouldBe` Just (TextValue "hello")

    -- Logs SDK §LogRecord limits: unset limits
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecord-limits
    specify "no limit allows many attributes" $ do
      let limits = AttributeLimits {attributeCountLimit = Nothing, attributeLengthLimit = Nothing}
      processor <- captureProcessor
      lp <-
        createLoggerProvider [processor] $
          LoggerProviderOptions
            { loggerProviderOptionsResource = emptyMaterializedResources
            , loggerProviderOptionsAttributeLimits = limits
            , loggerProviderOptionsMinSeverity = Nothing
            }
      let logger = makeLogger lp testLib
          attrs = H.fromList [(T.pack ("k" ++ show i), toValue (T.pack (show i))) | i <- [1 :: Int .. 200]]
      lr <-
        emitLogRecord logger $
          emptyLogRecordArguments
            { attributes = attrs
            , severityNumber = Just Info
            }
      ilr <- readLogRecord lr
      LA.attributesCount (logRecordAttributes ilr) `shouldBe` 200
      LA.attributesDropped (logRecordAttributes ilr) `shouldBe` 0

  describe "Batch LogRecord Processor" $ do
    -- Logs SDK §BatchLogRecordProcessor: shutdown flushes pending records
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#batchlogrecordprocessor
    specify "shutdown exports buffered records" $ do
      exportedRef <- newIORef (0 :: Int)
      exporter <-
        mkLogRecordExporter
          LogRecordExporterArguments
            { logRecordExporterArgumentsExport = \batch -> do
                atomicModifyIORef' exportedRef (\n -> (n + V.length batch, ()))
                pure Success
            , logRecordExporterArgumentsForceFlush = pure FlushSuccess
            , logRecordExporterArgumentsShutdown = pure ()
            }
      let conf =
            (defaultBatchLogRecordProcessorConfig exporter)
              { batchLogScheduledDelayMillis = 60000
              , batchLogMaxQueueSize = 100
              }
      proc <- batchLogRecordProcessor conf
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp testLib
      replicateM_ 5 $ emitLogRecord logger emptyLogRecordArguments {severityNumber = Just Info}
      _ <- shutdownLoggerProvider lp Nothing
      exported <- readIORef exportedRef
      exported `shouldBe` 5

    -- Logs SDK §BatchLogRecordProcessor: ForceFlush exports pending records
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#batchlogrecordprocessor
    specify "forceFlush exports buffered records" $ do
      exportedRef <- newIORef (0 :: Int)
      exporter <-
        mkLogRecordExporter
          LogRecordExporterArguments
            { logRecordExporterArgumentsExport = \batch -> do
                atomicModifyIORef' exportedRef (\n -> (n + V.length batch, ()))
                pure Success
            , logRecordExporterArgumentsForceFlush = pure FlushSuccess
            , logRecordExporterArgumentsShutdown = pure ()
            }
      let conf =
            (defaultBatchLogRecordProcessorConfig exporter)
              { batchLogScheduledDelayMillis = 60000
              , batchLogMaxQueueSize = 100
              }
      proc <- batchLogRecordProcessor conf
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp testLib
      replicateM_ 3 $ emitLogRecord logger emptyLogRecordArguments {severityNumber = Just Warn}
      _ <- forceFlushLoggerProvider lp Nothing
      exported <- readIORef exportedRef
      exported `shouldBe` 3

    -- Logs SDK §LoggerProvider: Shutdown is idempotent / second shutdown fails
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#shutdown
    specify "shutdown after shutdown returns failure" $ do
      exporter <-
        mkLogRecordExporter
          LogRecordExporterArguments
            { logRecordExporterArgumentsExport = \_ -> pure Success
            , logRecordExporterArgumentsForceFlush = pure FlushSuccess
            , logRecordExporterArgumentsShutdown = pure ()
            }
      proc <- batchLogRecordProcessor (defaultBatchLogRecordProcessorConfig exporter)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      r1 <- shutdownLoggerProvider lp Nothing
      r1 `shouldBe` ShutdownSuccess
      r2 <- shutdownLoggerProvider lp Nothing
      r2 `shouldBe` ShutdownFailure

    -- Logs SDK §LoggerProvider: no telemetry after Shutdown
    -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#shutdown
    specify "records emitted after shutdown are silently dropped" $ do
      exportedRef <- newIORef (0 :: Int)
      exporter <-
        mkLogRecordExporter
          LogRecordExporterArguments
            { logRecordExporterArgumentsExport = \batch -> do
                atomicModifyIORef' exportedRef (\n -> (n + V.length batch, ()))
                pure Success
            , logRecordExporterArgumentsForceFlush = pure FlushSuccess
            , logRecordExporterArgumentsShutdown = pure ()
            }
      proc <- batchLogRecordProcessor (defaultBatchLogRecordProcessorConfig exporter)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp testLib
      _ <- emitLogRecord logger emptyLogRecordArguments {severityNumber = Just Info}
      _ <- shutdownLoggerProvider lp Nothing
      beforeCount <- readIORef exportedRef
      _ <- emitLogRecord logger emptyLogRecordArguments {severityNumber = Just Info}
      afterCount <- readIORef exportedRef
      afterCount `shouldBe` beforeCount


testLib :: InstrumentationLibrary
testLib =
  InstrumentationLibrary
    { libraryName = "test"
    , libraryVersion = "0.0.0"
    , librarySchemaUrl = ""
    , libraryAttributes = emptyAttributes
    }


captureProcessor :: IO LogRecordProcessor
captureProcessor = do
  ref <- newIORef ([] :: [ReadWriteLogRecord])
  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctx -> atomicModifyIORef' ref (\rs -> (lr : rs, ()))
      , logRecordProcessorShutdown = pure ShutdownSuccess
      , logRecordProcessorForceFlush = pure FlushSuccess
      }
