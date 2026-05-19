{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- |
Module      : OpenTelemetry.Exporter.Handle.Span
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Export spans as text to a file handle (stdout/stderr)
Stability   : experimental

= Overview

Writes spans as human-readable text to a file handle. Useful for local
development and debugging.

= Quick example

@
import OpenTelemetry.Exporter.Handle.Span (stdoutExporter')

exporter <- stdoutExporter'
-- Spans will be printed to stdout as they complete
@
-}
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
import OpenTelemetry.Internal.Common.Types (FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id (Base (..), spanIdBaseEncodedText, traceIdBaseEncodedText)
import System.IO (Handle, hFlush, stderr, stdout)


makeHandleExporter :: Handle -> (ImmutableSpan -> IO L.Text) -> SpanExporter
makeHandleExporter h f =
  SpanExporter
    { spanExporterExport = \fs -> do
        mapM_ (mapM_ (\s -> f s >>= L.hPutStrLn h >> hFlush h)) fs
        pure Success
    , spanExporterShutdown = hFlush h >> pure ShutdownSuccess
    , spanExporterForceFlush = hFlush h >> pure FlushSuccess
    }


stdoutExporter' :: (ImmutableSpan -> IO L.Text) -> SpanExporter
stdoutExporter' = makeHandleExporter stdout


stderrExporter' :: (ImmutableSpan -> IO L.Text) -> SpanExporter
stderrExporter' = makeHandleExporter stderr


defaultFormatter :: ImmutableSpan -> IO L.Text
defaultFormatter imm = do
  hot <- readIORef (spanHot imm)
  let ctx = spanContext imm
  pure $!
    toLazyText $
      fromText (traceIdBaseEncodedText Base16 (traceId ctx))
        <> " "
        <> fromText (spanIdBaseEncodedText Base16 (spanId ctx))
        <> " "
        <> fromString (show (spanStart imm))
        <> " "
        <> fromText (hotName hot)
