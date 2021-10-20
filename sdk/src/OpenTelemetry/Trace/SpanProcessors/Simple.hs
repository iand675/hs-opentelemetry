{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
module OpenTelemetry.Trace.SpanProcessors.Simple
  ( SimpleProcessorConfig(..)
  , simpleProcessor
  ) where

import Control.Exception
import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Monad
import Data.Functor.Identity
import Data.IORef
import OpenTelemetry.Trace.SpanProcessor
import "otel-api" OpenTelemetry.Trace (Span, ImmutableSpan, spanTracer, tracerName)
import qualified OpenTelemetry.Trace.SpanExporter as Exporter
import qualified Data.HashMap.Strict as HashMap

newtype SimpleProcessorConfig = SimpleProcessorConfig
  { exporter :: Exporter.SpanExporter
  }

simpleProcessor :: SimpleProcessorConfig -> IO SpanProcessor
simpleProcessor SimpleProcessorConfig{..} = do
  (inChan :: InChan (IORef ImmutableSpan), outChan :: OutChan (IORef ImmutableSpan)) <- newChan
  exportWorker <- async $ forever $ do
    -- TODO, masking vs bracket here, not sure what's the right choice
    spanRef <- readChanOnException outChan (>>= writeChan inChan)
    span <- readIORef spanRef
    mask_ (exporter `Exporter.export` HashMap.singleton (tracerName $ spanTracer span) (pure span))

  pure $ SpanProcessor
    { onStart = \_ _ -> pure ()
    , onEnd = writeChan inChan 
    , shutdown = async $ mask $ \restore -> do
        cancel exportWorker
        -- TODO handle timeouts
        restore $ do
          shutdownProcessor outChan `finally` Exporter.shutdown exporter
        pure ShutdownSuccess
    , forceFlush = pure ()
    }

  where
    shutdownProcessor :: OutChan (IORef ImmutableSpan) -> IO ()
    shutdownProcessor outChan = do
      (Element m, _) <- tryReadChan outChan
      mSpan <- m
      case mSpan of 
        Nothing -> pure ()
        Just spanRef -> do
          span <- readIORef spanRef
          exporter `Exporter.export` HashMap.singleton (tracerName $ spanTracer span) (pure span)
          shutdownProcessor outChan

