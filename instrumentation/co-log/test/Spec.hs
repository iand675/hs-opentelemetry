{-# LANGUAGE OverloadedStrings #-}

module Main where

import Colog.Core (LogAction (..), (<&))
import Colog.Core.Severity (Severity (..))
import qualified Colog.Core.Severity as CS
import Colog.Message (Message, Msg (..))
import Data.IORef (readIORef)
import qualified Data.Text as T
import GHC.Stack (emptyCallStack)
import OpenTelemetry.Exporter.InMemory.LogRecord (getExportedLogRecords, inMemoryLogRecordExporter)
import OpenTelemetry.Instrumentation.CoLog (coLogSeverity, otelLogAction, otelLogActionWith)
import OpenTelemetry.Internal.Common.Types (AnyValue (..), ToValue (..))
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Log.Core
import OpenTelemetry.Processor.Simple.LogRecord (SimpleLogRecordProcessorConfig (..), simpleLogRecordProcessor)
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = describe "co-log bridge" $ do
  describe "coLogSeverity" $ do
    it "maps Debug to Debug" $
      fst (coLogSeverity CS.Debug) `shouldBe` OpenTelemetry.Internal.Log.Types.Debug
    it "maps Info to Info" $
      fst (coLogSeverity CS.Info) `shouldBe` OpenTelemetry.Internal.Log.Types.Info
    it "maps Warning to Warn" $
      fst (coLogSeverity CS.Warning) `shouldBe` Warn
    it "maps Error to Error" $
      fst (coLogSeverity CS.Error) `shouldBe` OpenTelemetry.Internal.Log.Types.Error

  describe "otelLogAction" $ do
    it "emits log records to the OTel pipeline" $ do
      (exporter, ref) <- inMemoryLogRecordExporter
      proc <- simpleLogRecordProcessor (SimpleLogRecordProcessorConfig exporter 30000000)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp (instrumentationLibrary "test-co-log" "0.0.0")
          action = otelLogAction logger
          msg = Msg CS.Info emptyCallStack "hello from co-log"
      action <& msg
      _ <- forceFlushLoggerProvider lp Nothing
      records <- getExportedLogRecords ref
      length records `shouldBe` 1
      let r = head records
      ilr <- readLogRecord r
      logRecordSeverityNumber ilr `shouldBe` Just OpenTelemetry.Internal.Log.Types.Info
      logRecordBody ilr `shouldBe` TextValue "hello from co-log"

  describe "otelLogActionWith" $ do
    it "converts custom messages via the supplied function" $ do
      (exporter, ref) <- inMemoryLogRecordExporter
      proc <- simpleLogRecordProcessor (SimpleLogRecordProcessorConfig exporter 30000000)
      lp <- createLoggerProvider [proc] emptyLoggerProviderOptions
      let logger = makeLogger lp (instrumentationLibrary "test-co-log" "0.0.0")
          action = otelLogActionWith logger $ \txt ->
            emptyLogRecordArguments
              { severityNumber = Just Warn
              , body = toValue (txt :: T.Text)
              }
      action <& "custom message"
      _ <- forceFlushLoggerProvider lp Nothing
      records <- getExportedLogRecords ref
      length records `shouldBe` 1
      ilr <- readLogRecord (head records)
      logRecordSeverityNumber ilr `shouldBe` Just Warn
      logRecordBody ilr `shouldBe` TextValue "custom message"
