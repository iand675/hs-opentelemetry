{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Control.Monad.Logger (Loc (..), LogLevel (..), LogStr, logDebugN, logErrorN, logInfoN, logWarnN, runLoggingT, toLogStr)
import Data.IORef (readIORef)
import qualified Data.Text as T
import OpenTelemetry.Exporter.InMemory.LogRecord (getExportedLogRecords, inMemoryLogRecordExporter)
import OpenTelemetry.Instrumentation.MonadLogger (makeOTelLogCallback, monadLoggerSeverity)
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Log.Core
import OpenTelemetry.Processor.Simple.LogRecord (SimpleLogRecordProcessorConfig (..), simpleLogRecordProcessor)
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = describe "MonadLogger bridge" $ do
  describe "monadLoggerSeverity" $ do
    it "maps LevelDebug to Debug" $
      fst (monadLoggerSeverity LevelDebug) `shouldBe` Debug
    it "maps LevelInfo to Info" $
      fst (monadLoggerSeverity LevelInfo) `shouldBe` Info
    it "maps LevelWarn to Warn" $
      fst (monadLoggerSeverity LevelWarn) `shouldBe` Warn
    it "maps LevelError to Error" $
      fst (monadLoggerSeverity LevelError) `shouldBe` Error
    it "maps LevelOther to Info with custom text" $ do
      let (sev, txt) = monadLoggerSeverity (LevelOther "TRACE")
      sev `shouldBe` Info
      txt `shouldBe` "TRACE"

  describe "makeOTelLogCallback" $ do
    it "emits log records to the OTel pipeline" $ do
      (exporter, ref) <- inMemoryLogRecordExporter
      proc <- simpleLogRecordProcessor (SimpleLogRecordProcessorConfig exporter 30000000)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp (instrumentationLibrary "test-monad-logger" "0.0.0")
      runLoggingT (logInfoN "hello from monad-logger") (makeOTelLogCallback logger)
      _ <- forceFlushLoggerProvider lp Nothing
      records <- getExportedLogRecords ref
      length records `shouldBe` 1
      let r = head records
      ilr <- readLogRecord r
      logRecordSeverityNumber ilr `shouldBe` Just Info
      logRecordSeverityText ilr `shouldBe` Just "INFO"
      logRecordBody ilr `shouldBe` TextValue "hello from monad-logger"

    it "preserves severity across multiple levels" $ do
      (exporter, ref) <- inMemoryLogRecordExporter
      proc <- simpleLogRecordProcessor (SimpleLogRecordProcessorConfig exporter 30000000)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp (instrumentationLibrary "test-monad-logger" "0.0.0")
          cb = makeOTelLogCallback logger
      runLoggingT (logDebugN "d" >> logInfoN "i" >> logWarnN "w" >> logErrorN "e") cb
      _ <- forceFlushLoggerProvider lp Nothing
      records <- reverse <$> getExportedLogRecords ref
      length records `shouldBe` 4
      sevs <- mapM (\r -> logRecordSeverityNumber <$> readLogRecord r) records
      sevs `shouldBe` [Just Debug, Just Info, Just Warn, Just Error]
