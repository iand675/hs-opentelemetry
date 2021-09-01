{-# LANGUAGE DuplicateRecordFields #-}
module OpenTelemetry.Exporters.Handle
  ( HandleExporter
  , makeHandleExporter
  , outputHandle
  -- $ Typical handle exporters
  , stdoutExporter
  , stderrExporter
  ) where

import Data.IORef
import OpenTelemetry.Trace.SpanExporter
import OpenTelemetry.Trace.Types
import System.IO

newtype HandleExporter = HandleExporter
  { outputHandle :: Handle
  }

makeHandleExporter :: Handle -> SpanExporter
makeHandleExporter h = SpanExporter
  { export = \fs -> mapM_ (\(Span s) -> readIORef s >>= hPutStrLn h . undefined) fs >> pure Success
  , shutdown = hFlush h
  }


stdoutExporter :: SpanExporter
stdoutExporter = makeHandleExporter stdout

stderrExporter :: SpanExporter
stderrExporter = makeHandleExporter stderr

