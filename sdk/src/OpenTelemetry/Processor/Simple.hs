{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Simple (
  SimpleProcessorConfig (..),
  simpleProcessor,
) where

import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Exception
import Control.Monad
import qualified Data.HashMap.Strict as HashMap
import Data.IORef
import qualified OpenTelemetry.Exporter as Exporter
import OpenTelemetry.Processor
import OpenTelemetry.Trace.Core (ImmutableSpan, spanTracer, tracerName)


newtype SimpleProcessorConfig = SimpleProcessorConfig
  { exporter :: Exporter.Exporter ImmutableSpan
  -- ^ The exporter where the spans are pushed.
  }


{- | This is an implementation of SpanProcessor which passes finished spans
 and passes the export-friendly span data representation to the configured SpanExporter,
 as soon as they are finished.

 @since 0.0.1.0
-}
simpleProcessor :: SimpleProcessorConfig -> IO Processor
simpleProcessor SimpleProcessorConfig {..} = do
  (inChan :: InChan (IORef ImmutableSpan), outChan :: OutChan (IORef ImmutableSpan)) <- newChan
  exportWorker <- async $ forever $ do
    -- TODO, masking vs bracket here, not sure what's the right choice
    spanRef <- readChanOnException outChan (>>= writeChan inChan)
    span_ <- readIORef spanRef
    mask_ (exporter `Exporter.exporterExport` HashMap.singleton (tracerName $ spanTracer span_) (pure span_))

  pure $
    Processor
      { processorOnStart = \_ _ -> pure ()
      , processorOnEnd = writeChan inChan
      , processorShutdown = async $ mask $ \restore -> do
          cancel exportWorker
          -- TODO handle timeouts
          restore $ do
            -- TODO, not convinced we should shut down processor here
            shutdownProcessor outChan `finally` Exporter.exporterShutdown exporter
          pure ShutdownSuccess
      , processorForceFlush = pure ()
      }
 where
  shutdownProcessor :: OutChan (IORef ImmutableSpan) -> IO ()
  shutdownProcessor outChan = do
    (Element m, _) <- tryReadChan outChan
    mSpan <- m
    case mSpan of
      Nothing -> pure ()
      Just spanRef -> do
        span_ <- readIORef spanRef
        _ <- exporter `Exporter.exporterExport` HashMap.singleton (tracerName $ spanTracer span_) (pure span_)
        shutdownProcessor outChan
