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

import Data.Foldable (for_, toList)
import Data.IORef
import qualified Data.Text.Lazy as L
import qualified Data.Text.Lazy.IO as L
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Trace.Core
import System.IO (Handle, hFlush, stderr, stdout)


makeHandleExporter :: Handle -> (MaterializedResourceSpans -> IO L.Text) -> SpanExporter
makeHandleExporter h formatter =
  SpanExporter
    { spanExporterExport = \spans -> do
        for_ spans $ \span -> formatter span >>= L.hPutStrLn h >> hFlush h
        pure Success
    , spanExporterShutdown = hFlush h
    }


stdoutExporter' :: (MaterializedResourceSpans -> IO L.Text) -> SpanExporter
stdoutExporter' = makeHandleExporter stdout


stderrExporter' :: (MaterializedResourceSpans -> IO L.Text) -> SpanExporter
stderrExporter' = makeHandleExporter stderr


defaultFormatter :: MaterializedResourceSpans -> L.Text
defaultFormatter resourceSpans =
  L.unlines
    [ L.intercalate " " $
      [ L.pack . show $ traceId context
      , L.pack . show $ spanId context
      , L.pack . show $ startTimeUnixNano
      , L.fromStrict name
      ]
    | scopeSpans <- toList $ materializedScopeSpans resourceSpans
    , span <- toList $ materializedSpans scopeSpans
    , let context = materializedContext span
    , let startTimeUnixNano = materializedStartTimeUnixNano span
    , let name = materializedName span
    ]
