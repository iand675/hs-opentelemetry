{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- |
Module      : OpenTelemetry.Exporter.Handle.LogRecord
Description : Handle-based log record exporter that writes log records to a file handle as text.
Stability   : experimental
-}
module OpenTelemetry.Exporter.Handle.LogRecord (
  makeHandleLogRecordExporter,
  stdoutLogRecordExporter,
  stderrLogRecordExporter,
  defaultLogRecordFormatter,
) where

import qualified Data.Text as T
import qualified Data.Text.IO as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (Builder, fromString, fromText, toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Text.Lazy.Builder.RealFloat (realFloat)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), InstrumentationLibrary (..))
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.LogAttributes (AnyValue (..), LogAttributes (..))
import OpenTelemetry.Trace.Id (Base (..), spanIdBaseEncodedText, traceIdBaseEncodedText)
import System.IO (Handle, hFlush, stderr, stdout)


makeHandleLogRecordExporter :: Handle -> (ReadableLogRecord -> IO T.Text) -> IO LogRecordExporter
makeHandleLogRecordExporter h formatter =
  mkLogRecordExporter
    LogRecordExporterArguments
      { logRecordExporterArgumentsExport = \lrs -> do
          V.mapM_ (\lr -> formatter lr >>= T.hPutStrLn h >> hFlush h) lrs
          pure Success
      , logRecordExporterArgumentsForceFlush = hFlush h >> pure FlushSuccess
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
  let sevText = case toBaseMaybe logRecordSeverityText of
        Just s -> fromText s
        Nothing -> "UNSET"
  let bodyText = case logRecordBody of
        TextValue t -> fromText t
        IntValue i -> decimal i
        DoubleValue d -> realFloat d
        BoolValue b -> if b then "true" else "false"
        NullValue -> mempty
        _ -> fromString (show logRecordBody)
  let traceInfo = case toBaseMaybe logRecordTracingDetails of
        Just (tid, sid, _flags) ->
          " trace="
            <> fromText (traceIdBaseEncodedText Base16 tid)
            <> " span="
            <> fromText (spanIdBaseEncodedText Base16 sid)
        Nothing -> mempty
  let LogAttributes {attributesCount = attrCount, attributesDropped = droppedCount} = logRecordAttributes
  let attrInfo :: Builder
      attrInfo =
        if attrCount > 0
          then " attrs=" <> decimal attrCount <> if droppedCount > 0 then " dropped=" <> decimal droppedCount else mempty
          else mempty
  let eventInfo = case toBaseMaybe logRecordEventName of
        Just en -> " event=" <> fromText en
        Nothing -> mempty
  pure $
    TL.toStrict $
      toLazyText $
        fromString (show logRecordObservedTimestamp)
          <> " "
          <> sevText
          <> " ["
          <> fromText (libraryName scope_)
          <> "]"
          <> eventInfo
          <> " "
          <> bodyText
          <> traceInfo
          <> attrInfo
