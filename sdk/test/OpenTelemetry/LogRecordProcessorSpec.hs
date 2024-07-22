{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.LogRecordProcessorSpec where

import Data.IORef
import qualified Data.Text as T
import qualified Data.Vector as V
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.LogRecord
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Logs.Core
import OpenTelemetry.Processor.LogRecord
import OpenTelemetry.Processor.Simple.LogRecord
import System.IO.Unsafe
import Test.Hspec


getTestExporter :: IO (IORef Int, LogRecordExporter)
getTestExporter = do
  numExportsRef <- newIORef 0
  shutdownRef <- newIORef False

  let logRecordExporterExportInternal logRecords = do
        shutdown <- readIORef shutdownRef
        if shutdown
          then pure (Failure Nothing)
          else do
            modifyIORef numExportsRef $ (+) $ V.length logRecords

            pure Success

      logRecordExporterForceFlushInternal = pure FlushSuccess

      logRecordExporterShutdownInternal = do
        writeIORef shutdownRef True
        pure ShutdownSuccess
  testExporter <-
    mkLogRecordExporter $
      LogRecordExporterInternal
        { logRecordExporterExportInternal
        , logRecordExporterForceFlushInternal
        , logRecordExporterShutdownInternal
        }
  pure
    ( numExportsRef
    , testExporter
    )


getTestExporterWithoutShutdown :: IO (IORef Int, LogRecordExporter)
getTestExporterWithoutShutdown = do
  numExportsRef <- newIORef 0

  let logRecordExporterExportInternal logRecords = do
        modifyIORef numExportsRef $ (+) $ V.length $ logRecords

        pure Success

      logRecordExporterForceFlushInternal = pure FlushSuccess

      logRecordExporterShutdownInternal = pure ShutdownSuccess

  testExporter <-
    mkLogRecordExporter $
      LogRecordExporterInternal
        { logRecordExporterExportInternal
        , logRecordExporterForceFlushInternal
        , logRecordExporterShutdownInternal
        }
  pure
    ( numExportsRef
    , testExporter
    )


spec :: Spec
spec = describe "LogRecordProcessor" $ do
  describe "Simple Processor" $ do
    it "Sends LogRecords to the Exporter" $ do
      (numExportsRef, testExporter) <- getTestExporter
      processor <- simpleProcessor testExporter

      let lp = createLoggerProvider [processor] emptyLoggerProviderOptions
          l = makeLogger lp "Test Library"

      emitLogRecord l emptyLogRecordArguments
      emitLogRecord l emptyLogRecordArguments
      emitLogRecord l emptyLogRecordArguments

      -- WARNING: There might be a better way to ensure exporting than forceFlush
      forceFlushLoggerProvider Nothing lp

      numExports <- readIORef numExportsRef
      numExports `shouldBe` 3
    it "Shuts down correctly" $ do
      (numExportsRef, testExporter) <- getTestExporter
      (numExportsNoShutdownRef, testExporterNoShutdown) <- getTestExporterWithoutShutdown
      processor <- simpleProcessor testExporter
      processorNoShutdown <- simpleProcessor testExporterNoShutdown

      let lp = createLoggerProvider [processor, processorNoShutdown] emptyLoggerProviderOptions
          l = makeLogger lp "Test Library"

      emitLogRecord l emptyLogRecordArguments
      emitLogRecord l emptyLogRecordArguments
      emitLogRecord l emptyLogRecordArguments

      -- WARNING: There might be a better way to ensure exporting than forceFlush
      shutdownLoggerProvider Nothing lp

      numExports <- readIORef numExportsRef
      numExports `shouldBe` 3

      exportRes <- logRecordExporterExport testExporter V.empty
      exportRes `shouldSatisfy` \case
        Success -> False
        Failure _ -> True

      lr <- emitLogRecord l emptyLogRecordArguments
      logRecordProcessorOnEmit processorNoShutdown lr Context.empty
      numExportsNoShutdown <- readIORef numExportsNoShutdownRef
      numExportsNoShutdown `shouldBe` 3
