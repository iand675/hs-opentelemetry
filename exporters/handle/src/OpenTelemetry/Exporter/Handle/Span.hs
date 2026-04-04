{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Exporter.Handle.Span (
  makeHandleExporter,
  -- $
  stdoutExporter',
  stderrExporter',
  -- $
  defaultFormatter,
) where

import Data.IORef
import qualified Data.Text.Lazy as L
import Data.Text.Lazy.Builder (fromString, fromText, toLazyText)
import qualified Data.Text.Lazy.IO as L
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id (Base (..), spanIdBaseEncodedText, traceIdBaseEncodedText)
import System.IO (Handle, hFlush, stderr, stdout)


makeHandleExporter :: Handle -> (ImmutableSpan -> IO L.Text) -> SpanExporter
makeHandleExporter h f =
  SpanExporter
    { spanExporterExport = \fs -> do
        mapM_ (mapM_ (\s -> f s >>= L.hPutStrLn h >> hFlush h)) fs
        pure Success
    , spanExporterShutdown = hFlush h
    , spanExporterForceFlush = hFlush h
    }


stdoutExporter' :: (ImmutableSpan -> IO L.Text) -> SpanExporter
stdoutExporter' = makeHandleExporter stdout


stderrExporter' :: (ImmutableSpan -> IO L.Text) -> SpanExporter
stderrExporter' = makeHandleExporter stderr


defaultFormatter :: ImmutableSpan -> IO L.Text
defaultFormatter imm = do
  hot <- readIORef (spanHot imm)
  let ctx = spanContext imm
  pure $! toLazyText $
    fromText (traceIdBaseEncodedText Base16 (traceId ctx))
      <> " "
      <> fromText (spanIdBaseEncodedText Base16 (spanId ctx))
      <> " "
      <> fromString (show (spanStart imm))
      <> " "
      <> fromText (hotName hot)
