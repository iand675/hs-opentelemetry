{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module OpenTelemetry.Exporters.Handle
  ( makeHandleExporter
  -- $ Typical handle exporters
  , stdoutExporter
  , stderrExporter
  -- $ Formatters
  , defaultFormatter
  ) where

import Data.IORef
import qualified Data.Text.Lazy as L
import OpenTelemetry.Trace.SpanExporter
import OpenTelemetry.Trace
import qualified Data.Text.Lazy.IO as L
import System.IO (Handle, hFlush, stdout, stderr)

makeHandleExporter :: Handle -> (ImmutableSpan -> L.Text) -> SpanExporter
makeHandleExporter h f = SpanExporter
  { export = \fs -> do
      mapM_ (\s -> L.hPutStrLn h (f s) >> hFlush h) fs 
      pure Success
  , shutdown = hFlush h
  }

stdoutExporter :: (ImmutableSpan -> L.Text) -> SpanExporter
stdoutExporter = makeHandleExporter stdout

stderrExporter :: (ImmutableSpan -> L.Text) -> SpanExporter
stderrExporter = makeHandleExporter stderr

defaultFormatter :: ImmutableSpan -> L.Text
defaultFormatter ImmutableSpan{..} = L.intercalate " "
  [ L.pack $ show $ traceId spanContext
  , L.pack $ show $ spanId spanContext
  , L.pack $ show spanStart
  , L.fromStrict spanName
  ]