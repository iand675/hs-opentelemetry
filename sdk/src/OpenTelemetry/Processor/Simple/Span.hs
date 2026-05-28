{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Simple.Span (
  SimpleProcessorConfig (..),
  simpleProcessor,
) where

import Control.Concurrent.Async
import Control.Concurrent.STM
import Control.Exception (mask_)
import Control.Monad
import qualified Data.HashMap.Strict as HashMap
import Data.IORef
import qualified OpenTelemetry.Exporter.Span as SpanExporter
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core (spanTracer, tracerName)


data SimpleProcessorConfig = SimpleProcessorConfig
  { spanExporter :: SpanExporter.SpanExporter
  -- ^ The exporter where the spans are pushed.
  , simpleSpanExportTimeoutMicros :: !Int
  -- ^ Timeout for individual export calls in microseconds. Default: 30s.
  }


defaultSimpleQueueBound :: Int
defaultSimpleQueueBound = 2048


{- | This is an implementation of SpanProcessor which passes finished spans
 and passes the export-friendly span data representation to the configured SpanExporter,
 as soon as they are finished.

 Uses a bounded queue internally. Spans that arrive while the queue is full
 are dropped and counted per @otel.sdk.processor.span.processed@ with
 @error.type=queue_full@ (OTel SDK semconv).

 @since 0.0.1.0
-}
simpleProcessor :: SimpleProcessorConfig -> IO SpanProcessor
simpleProcessor SimpleProcessorConfig {..} = do
  queue <- newTBQueueIO (fromIntegral defaultSimpleQueueBound)
  droppedRef <- newIORef (0 :: Int)
  warnedRef <- newIORef False
  shutdownVar <- newTVarIO False
  flushReq <- newEmptyTMVarIO
  flushDone <- newEmptyTMVarIO

  let exportOne span_ =
        mask_ (spanExporter `SpanExporter.spanExporterExport` HashMap.singleton (tracerName $ spanTracer span_) (pure span_))

  let drainQueue = do
        mSpan <- atomically $ tryReadTBQueue queue
        case mSpan of
          Nothing -> pure ()
          Just span_ -> do
            _ <- exportOne span_
            drainQueue

  -- Cooperative worker: checks shutdown and flush signals via STM rather
  -- than relying on async exceptions, avoiding the race where cancel
  -- arrives between readTBQueue and mask_ and drops an in-flight span.
  let workerLoop = do
        cmd <-
          atomically $
            msum
              [ Nothing <$ (readTVar shutdownVar >>= check)
              , Just Nothing <$ takeTMVar flushReq
              , Just . Just <$> readTBQueue queue
              ]
        case cmd of
          Nothing -> do
            drainQueue
            void $ atomically $ tryPutTMVar flushDone ()
          Just Nothing -> do
            drainQueue
            atomically $ putTMVar flushDone ()
            workerLoop
          Just (Just span_) -> do
            _ <- exportOne span_
            workerLoop

  exportWorker <- async workerLoop

  pure $
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \s -> do
          written <- atomically $ do
            full <- isFullTBQueue queue
            if full then pure False else writeTBQueue queue s >> pure True
          unless written $ do
            n <- atomicModifyIORef' droppedRef (\c -> let c' = c + 1 in (c', c'))
            alreadyWarned <- atomicModifyIORef' warnedRef (\w -> (True, w))
            unless alreadyWarned $
              otelLogWarning $
                "SimpleSpanProcessor: queue full (capacity "
                  <> show defaultSimpleQueueBound
                  <> "), dropping span. Total dropped so far: "
                  <> show n
      , spanProcessorShutdown = do
          atomically $ writeTVar shutdownVar True
          wait exportWorker
          _ <- SpanExporter.spanExporterShutdown spanExporter
          pure ShutdownSuccess
      , spanProcessorForceFlush = do
          isShut <- readTVarIO shutdownVar
          unless isShut $ do
            atomically $ putTMVar flushReq ()
            atomically $ takeTMVar flushDone
          SpanExporter.spanExporterForceFlush spanExporter
      }
