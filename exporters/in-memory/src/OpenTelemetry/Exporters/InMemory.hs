module OpenTelemetry.Exporters.InMemory where

import Control.Concurrent.Chan.Unagi
import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.Trace
import OpenTelemetry.Trace.SpanProcessor

inMemoryChannelExporter :: MonadIO m => m (SpanProcessor, OutChan Span)
inMemoryChannelExporter = undefined

inMemoryListExporter :: MonadIO m => m (SpanProcessor, IORef [Span])
inMemoryListExporter = undefined