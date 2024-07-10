{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.LogRecordProcessorSpec where

import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Exporter.LogRecord
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.LogRecordExporter
import OpenTelemetry.LogRecordProcessor.Simple
import OpenTelemetry.Logs.Core
import Test.Hspec


getTestExporter :: IO (IORef Int, LogRecordExporter)
getTestExporter = do
  numExportsRef <- newIORef 0
  shutdownRef <- newIORef False

  let logRecordExporterExportInternal logRecordsByLibrary = do
        shutdown <- readIORef shutdownRef
        if shutdown
          then pure (Failure Nothing)
          else do
            let numLogRecords = foldr (\lrs n -> n + V.length lrs) 0 logRecordsByLibrary
            modifyIORef numExportsRef (+ numLogRecords)

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

      emitLogRecord l (emptyLogRecordArguments "something")

      pending

    it "Force flushes correctly" $ do
      pending
    it "Shuts down correctly" $ do
      pending
