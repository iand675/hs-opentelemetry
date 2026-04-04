{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Processor.Batch.Span
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Performant exporting of spans in time & space-bounded batches.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 This is an implementation of the Span Processor which create batches of finished spans and passes the export-friendly span data representations to the configured Exporter.
-}
module OpenTelemetry.Processor.Batch.Span (
  BatchTimeoutConfig (..),
  batchTimeoutConfig,
  batchProcessor,
  -- , BatchProcessorOperations
) where

import Control.Concurrent (rtsSupportsBoundThreads)
import Control.Concurrent.Async
import qualified Control.Concurrent.Chan.Unagi.Bounded as UChan
import Control.Concurrent.STM
import Control.Exception
import Control.Monad (msum, unless, void, when)
import Control.Monad.IO.Class
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.IORef (atomicWriteIORef, newIORef, readIORef)
import Data.List (foldl')
import Data.Maybe (fromMaybe)
import Data.Vector (Vector)
import qualified Data.Vector as V
import OpenTelemetry.Exporter.Span (ExportResult (..), SpanExporter)
import qualified OpenTelemetry.Exporter.Span as SpanExporter
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core
import System.Timeout (timeout)


-- | Configurable options for batch exporting frequence and size
data BatchTimeoutConfig = BatchTimeoutConfig
  { maxQueueSize :: Int
  -- ^ The maximum queue size. After the size is reached, spans are dropped.
  , scheduledDelayMillis :: Int
  -- ^ The delay interval in milliseconds between two consective exports.
  -- The default value is 5000.
  , exportTimeoutMillis :: Int
  -- ^ How long the export can run before it is cancelled.
  -- The default value is 30000.
  , maxExportBatchSize :: Int
  -- ^ The maximum batch size of every export. It must be
  -- smaller or equal to 'maxQueueSize'. The default value is 512.
  }
  deriving (Show)


-- | Default configuration values
batchTimeoutConfig :: BatchTimeoutConfig
batchTimeoutConfig =
  BatchTimeoutConfig
    { maxQueueSize = 2048
    , scheduledDelayMillis = 5000
    , exportTimeoutMillis = 30000
    , maxExportBatchSize = 512
    }


data ProcessorMessage = ScheduledFlush | MaxExportFlush | Shutdown


-- note: [Unmasking Asyncs]
--
-- It is possible to create unkillable asyncs. Behold:
--
-- ```
-- a <- uninterruptibleMask_ $ do
--     async $ do
--         forever $ do
--             threadDelay 10_000
--             putStrLn "still alive"
-- cancel a
-- ```
--
-- The prior code block will never successfully cancel `a` and will be
-- blocked forever. The reason is that `cancel` sends an async exception to
-- the thread performing the action, but the `uninterruptibleMask` state is
-- inherited by the forked thread. This means that *no async exceptions*
-- can reach it, and `cancel` will therefore run forever.
--
-- This also affects `timeout`, which uses an async exception to kill the
-- running job. If the action is done in an uninterruptible masked state,
-- then the timeout will not successfully kill the running action.

{- |
 The batch processor accepts spans and places them into batches. Batching helps better compress the data and reduce the number of outgoing connections
 required to transmit the data. This processor supports both size and time based batching.

NOTE: this processor works best when compiled with the @-threaded@ GHC option.
On the single-threaded RTS, blocking FFI calls in the exporter (e.g. HTTP
requests) will block all Haskell threads. A warning is emitted if @-threaded@
is not detected.
-}
batchProcessor :: (MonadIO m) => BatchTimeoutConfig -> SpanExporter -> m SpanProcessor
batchProcessor BatchTimeoutConfig {..} exporter = liftIO $ do
  unless rtsSupportsBoundThreads $
    otelLogWarning "Batch span processor running without -threaded; blocking exporter calls may stall the application"
  (inChan, outChan) <- UChan.newChan maxQueueSize
  droppedSpans <- newAtomicCounter 0
  exportedSpans <- newAtomicCounter 0
  workSignal <- newEmptyTMVarIO
  shutdownSignal <- newEmptyTMVarIO
  flushGen <- newTVarIO (0 :: Int)
  shutdownRef <- newIORef False
  let publish batchToProcess = do
        mResult <-
          timeout (millisToMicros exportTimeoutMillis) $
            mask_ $
              SpanExporter.spanExporterExport exporter batchToProcess
        pure $ fromMaybe (Failure Nothing) mResult

      publishChunked spans = do
        let chunks = chunksOfV maxExportBatchSize spans
        mapConcurrently_
          ( \chunk -> do
              let grouped = groupByTracer chunk
              result <- try @SomeException $ publish grouped
              case result of
                Right Success -> void $ addAtomicCounter (V.length chunk) exportedSpans
                _ -> pure ()
          )
          chunks

      -- Drain up to n items from the channel. Uses estimatedLength to
      -- avoid blocking on readChan when the channel is empty. Since
      -- there is a single consumer, the estimate is accurate or
      -- slightly under (if a producer is mid-write, readChan blocks
      -- for nanoseconds until the write completes).
      drainUpTo :: Int -> IO (Vector ImmutableSpan)
      drainUpTo n = do
        est <- UChan.estimatedLength inChan
        let toRead = min n (max 0 est)
        V.replicateM toRead (UChan.readChan outChan)

      flushQueueImmediately ret = do
        batch <- drainUpTo maxQueueSize
        if V.null batch
          then pure ret
          else do
            publishChunked batch
            flushQueueImmediately ret

      waiting = do
        delay <- registerDelay (millisToMicros scheduledDelayMillis)
        atomically $ do
          msum
            [ ScheduledFlush <$ do
                continue <- readTVar delay
                check continue
            , MaxExportFlush <$ takeTMVar workSignal
            , Shutdown <$ takeTMVar shutdownSignal
            ]

      workerAction = do
        req <- waiting
        batch <- drainUpTo maxExportBatchSize
        unless (V.null batch) $ publishChunked batch
        atomically $ modifyTVar' flushGen (+ 1)

        case req of
          Shutdown -> do
            flushQueueImmediately Success
          _ ->
            workerAction
  -- see note [Unmasking Asyncs]
  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure $
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \imm -> do
          isShutdown <- readIORef shutdownRef
          unless isShutdown $ do
            ok <- UChan.tryWriteChan inChan imm
            if ok
              then do
                len <- UChan.estimatedLength inChan
                when (len >= maxExportBatchSize) $
                  void $
                    atomically $
                      tryPutTMVar workSignal ()
              else void $ incrAtomicCounter droppedSpans
      , spanProcessorForceFlush = do
          gen <- readTVarIO flushGen
          void $ atomically $ tryPutTMVar workSignal ()
          void $
            timeout (millisToMicros exportTimeoutMillis) $
              atomically $ do
                current <- readTVar flushGen
                check (current > gen)
          SpanExporter.spanExporterForceFlush exporter
      , spanProcessorShutdown =
          asyncWithUnmask $ \unmask -> unmask $ do
            -- we call asyncWithUnmask here because the shutdown action is
            -- likely to happen inside of a `finally` or `bracket`. the
            -- @safe-exceptions@ pattern (followed by unliftio as well)
            -- will use uninterruptibleMask in an exception cleanup. the
            -- uninterruptibleMask state means that the `timeout` call
            -- below will never exit, because `wait worker` will be in the
            -- `uninterruptibleMasked` state, and the timeout async
            -- exception will not be delivered.
            --
            -- see note [Unmasking Asyncs]
            mask $ \_restore -> do
              -- is it a little silly that we unmask and remask? seems
              -- silly! but the `mask` here is doing an interruptible mask.
              -- which means that async exceptions can still be delivered
              -- if a process is blocking.

              -- flush remaining messages and signal the worker to shutdown
              atomicWriteIORef shutdownRef True
              void $ atomically $ tryPutTMVar shutdownSignal ()

              -- gracefully wait for the worker to stop. we may be in
              -- a `bracket` or responding to an async exception, so we
              -- must be very careful not to wait too long. the following
              -- STM action will block, so we'll be susceptible to an async
              -- exception.
              delay <- registerDelay (millisToMicros exportTimeoutMillis)
              shutdownResult <-
                atomically $
                  msum
                    [ Just <$> waitCatchSTM worker
                    , Nothing <$ do
                        shouldStop <- readTVar delay
                        check shouldStop
                    ]

              -- make sure the worker comes down if we timed out.
              cancel worker
              SpanExporter.spanExporterShutdown exporter

              pure $ case shutdownResult of
                Nothing ->
                  ShutdownTimeout
                Just er ->
                  case er of
                    Left _ ->
                      ShutdownFailure
                    Right _ ->
                      ShutdownSuccess
      }
  where
    millisToMicros = (* 1000)


groupByTracer :: Vector ImmutableSpan -> HashMap InstrumentationLibrary (Vector ImmutableSpan)
groupByTracer =
  fmap V.fromList
    . V.foldl' (\acc s -> HashMap.insertWith (++) (tracerName $ spanTracer s) [s] acc) HashMap.empty


chunksOfV :: Int -> Vector a -> [Vector a]
chunksOfV n v
  | V.null v = []
  | otherwise =
      let (chunk, rest) = V.splitAt n v
      in chunk : chunksOfV n rest
