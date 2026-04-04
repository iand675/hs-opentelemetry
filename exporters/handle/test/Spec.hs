{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Data.HashMap.Strict as HM
import qualified Data.Vector as V
import OpenTelemetry.Exporter.Handle.LogRecord (makeHandleLogRecordExporter)
import OpenTelemetry.Exporter.Handle.Span (makeHandleExporter)
import OpenTelemetry.Exporter.LogRecord (
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
 )
import OpenTelemetry.Exporter.Span (SpanExporter (..))
import OpenTelemetry.Internal.Common.Types (ExportResult (..))
import System.IO (stdout)
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = do
  describe "Handle Span exporter" $ do
    it "returns Success for empty batch" $ do
      let formatter _span = pure "test"
          exporter = makeHandleExporter stdout formatter
      result <- spanExporterExport exporter HM.empty
      case result of
        Success -> pure ()
        Failure _ -> expectationFailure "expected Success"

    it "forceFlush does not throw" $ do
      let exporter = makeHandleExporter stdout (\_ -> pure "test")
      spanExporterForceFlush exporter

    it "shutdown does not throw" $ do
      let exporter = makeHandleExporter stdout (\_ -> pure "test")
      spanExporterShutdown exporter

  describe "Handle LogRecord exporter" $ do
    it "returns Success for empty batch" $ do
      exporter <- makeHandleLogRecordExporter stdout (\_ -> pure "test")
      result <- logRecordExporterExport exporter V.empty
      case result of
        Success -> pure ()
        Failure _ -> expectationFailure "expected Success"

    it "forceFlush does not throw" $ do
      exporter <- makeHandleLogRecordExporter stdout (\_ -> pure "test")
      logRecordExporterForceFlush exporter

    it "shutdown does not throw" $ do
      exporter <- makeHandleLogRecordExporter stdout (\_ -> pure "test")
      logRecordExporterShutdown exporter
