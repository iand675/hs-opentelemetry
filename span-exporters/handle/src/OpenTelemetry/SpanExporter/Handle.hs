{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.SpanExporter.Handle (
  makeHandleExporter,
  -- $
  stdoutExporter',
  stderrExporter',
  -- $
  defaultFormatter,
) where

import Data.IORef
import qualified Data.Text.Lazy as L
import qualified Data.Text.Lazy.IO as L
import OpenTelemetry.SpanExporter
import OpenTelemetry.Trace.Core
import System.IO (Handle, hFlush, stderr, stdout)


makeHandleExporter :: Handle -> (ImmutableSpan -> IO L.Text) -> SpanExporter
makeHandleExporter h f =
  SpanExporter
    { spanExporterExport = \fs -> do
        mapM_ (mapM_ (\s -> f s >>= L.hPutStrLn h >> hFlush h)) fs
        pure Success
    , spanExporterShutdown = hFlush h
    }


stdoutExporter' :: (ImmutableSpan -> IO L.Text) -> SpanExporter
stdoutExporter' = makeHandleExporter stdout


stderrExporter' :: (ImmutableSpan -> IO L.Text) -> SpanExporter
stderrExporter' = makeHandleExporter stderr


defaultFormatter :: ImmutableSpan -> L.Text
defaultFormatter ImmutableSpan {..} =
  L.intercalate
    " "
    [ L.pack $ show $ traceId spanContext
    , L.pack $ show $ spanId spanContext
    , L.pack $ show spanStart
    , L.fromStrict spanName
    ]
