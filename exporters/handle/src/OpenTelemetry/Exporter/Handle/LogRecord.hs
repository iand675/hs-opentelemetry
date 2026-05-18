{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Exporter.Handle.LogRecord (
  makeHandleLogRecordExporter,
  stdoutLogRecordExporter,
  stderrLogRecordExporter,
  defaultLogRecordFormatter,
) where

import qualified Data.Text as T
import qualified Data.Text.IO as T
import qualified Data.Text.Lazy as LT
import qualified Data.Text.Lazy.Builder as LB
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Text.Lazy.Builder.RealFloat (realFloat)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), InstrumentationLibrary (..))
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.LogAttributes (AnyValue (..), LogAttributes (..))
import System.IO (Handle, hFlush, stderr, stdout)


builderText :: LB.Builder -> T.Text
builderText = LT.toStrict . LB.toLazyText


textIntegral :: (Integral n) => n -> T.Text
textIntegral = builderText . decimal


textDouble :: Double -> T.Text
textDouble = builderText . realFloat


makeHandleLogRecordExporter :: Handle -> (ReadableLogRecord -> IO T.Text) -> IO LogRecordExporter
makeHandleLogRecordExporter h formatter =
  mkLogRecordExporter
    LogRecordExporterArguments
      { logRecordExporterArgumentsExport = \lrs -> do
          V.mapM_ (\lr -> formatter lr >>= T.hPutStrLn h >> hFlush h) lrs
          pure Success
      , logRecordExporterArgumentsForceFlush = hFlush h
      , logRecordExporterArgumentsShutdown = hFlush h
      }


stdoutLogRecordExporter :: IO LogRecordExporter
stdoutLogRecordExporter = makeHandleLogRecordExporter stdout defaultLogRecordFormatter


stderrLogRecordExporter :: IO LogRecordExporter
stderrLogRecordExporter = makeHandleLogRecordExporter stderr defaultLogRecordFormatter


defaultLogRecordFormatter :: ReadableLogRecord -> IO T.Text
defaultLogRecordFormatter lr = do
  ImmutableLogRecord {..} <- readLogRecord lr
  let scope_ = readLogRecordInstrumentationScope lr
  let sevText = case logRecordSeverityText of
        Just s -> s
        Nothing -> "UNSET"
  let bodyText = case logRecordBody of
        TextValue t -> t
        IntValue i -> textIntegral i
        DoubleValue d -> textDouble d
        BoolValue b -> if b then "true" else "false"
        NullValue -> ""
        _ -> T.pack (show logRecordBody)
  let traceInfo = case logRecordTracingDetails of
        Just (tid, sid, _flags) -> " trace=" <> T.pack (show tid) <> " span=" <> T.pack (show sid)
        Nothing -> ""
  let LogAttributes {attributesCount = attrCount, attributesDropped = droppedCount} = logRecordAttributes
  let attrInfo =
        if attrCount > 0
          then " attrs=" <> textIntegral attrCount <> if droppedCount > 0 then " dropped=" <> textIntegral droppedCount else ""
          else ""
  let eventInfo = case logRecordEventName of
        Just en -> " event=" <> en
        Nothing -> ""
  pure $
    T.concat
      [ T.pack (show logRecordObservedTimestamp)
      , " "
      , sevText
      , " ["
      , libraryName scope_
      , "]"
      , eventInfo
      , " "
      , bodyText
      , traceInfo
      , attrInfo
      ]
