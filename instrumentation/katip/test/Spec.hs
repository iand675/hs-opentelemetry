{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Data.IORef (readIORef)
import qualified Data.Text as T
import Katip
import OpenTelemetry.Exporter.InMemory.LogRecord (getExportedLogRecords, inMemoryLogRecordExporter)
import OpenTelemetry.Instrumentation.Katip (katipSeverity, makeOTelScribe)
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Log.Core
import OpenTelemetry.Processor.Simple.LogRecord (SimpleLogRecordProcessorConfig (..), simpleLogRecordProcessor)
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = describe "Katip bridge" $ do
  describe "katipSeverity" $ do
    it "maps DebugS to Debug" $
      fst (katipSeverity DebugS) `shouldBe` Debug
    it "maps InfoS to Info" $
      fst (katipSeverity InfoS) `shouldBe` Info
    it "maps WarningS to Warn" $
      fst (katipSeverity WarningS) `shouldBe` Warn
    it "maps ErrorS to Error" $
      fst (katipSeverity ErrorS) `shouldBe` Error
    it "maps CriticalS to Fatal" $
      fst (katipSeverity CriticalS) `shouldBe` Fatal

  describe "makeOTelScribe" $ do
    it "emits log records to the OTel pipeline" $ do
      (exporter, ref) <- inMemoryLogRecordExporter
      proc <- simpleLogRecordProcessor (SimpleLogRecordProcessorConfig exporter 30000000)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let otelLogger = makeLogger lp (instrumentationLibrary "test-katip" "0.0.0")
      scribe <- makeOTelScribe otelLogger InfoS V2
      le <- registerScribe "otel" scribe defaultScribeSettings =<< initLogEnv "TestApp" "test"
      runKatipContextT le () "main" $
        $(logTM) InfoS "hello from katip"
      closeScribes le
      _ <- forceFlushLoggerProvider lp Nothing
      records <- getExportedLogRecords ref
      length records `shouldBe` 1
      let r = head records
      ilr <- readLogRecord r
      logRecordSeverityNumber ilr `shouldBe` Just Info
      logRecordSeverityText ilr `shouldBe` Just "INFO"

    it "filters by severity" $ do
      (exporter, ref) <- inMemoryLogRecordExporter
      proc <- simpleLogRecordProcessor (SimpleLogRecordProcessorConfig exporter 30000000)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let otelLogger = makeLogger lp (instrumentationLibrary "test-katip" "0.0.0")
      scribe <- makeOTelScribe otelLogger WarningS V2
      le <- registerScribe "otel" scribe defaultScribeSettings =<< initLogEnv "TestApp" "test"
      runKatipContextT le () "main" $ do
        $(logTM) DebugS "debug"
        $(logTM) InfoS "info"
        $(logTM) WarningS "warning"
        $(logTM) ErrorS "error"
      closeScribes le
      _ <- forceFlushLoggerProvider lp Nothing
      records <- reverse <$> getExportedLogRecords ref
      length records `shouldBe` 2
      sevs <- mapM (\r -> logRecordSeverityNumber <$> readLogRecord r) records
      sevs `shouldBe` [Just Warn, Just Error]
