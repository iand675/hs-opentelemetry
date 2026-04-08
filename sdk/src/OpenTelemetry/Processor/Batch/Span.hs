{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

{- |
 Module      :  OpenTelemetry.Processor.Batch.Span
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Performant exporting of spans in time & space-bounded batches.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 This is an implementation of the Span Processor which create batches of finished spans and passes the export-friendly span data representations to the configured Exporter.

 Spec: <https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-processor>
-}
module OpenTelemetry.Processor.Batch.Span (
  BatchTimeoutConfig (..),
  batchTimeoutConfig,
  batchProcessor,
  batchProcessorWithMetrics,
  -- , BatchProcessorOperations
) where

import Control.Concurrent (rtsSupportsBoundThreads, threadDelay)
import Control.Concurrent.Async
import qualified Control.Concurrent.Chan.Unagi.Bounded as UChan
import Control.Concurrent.MVar
import Control.Exception
import Control.Monad (unless, void, when)
import Control.Monad.IO.Class
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.IORef (atomicWriteIORef, newIORef, readIORef)
import Data.Int (Int64)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Vector (Vector)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (
  Attributes,
  unsafeAttributesFromListIgnoringLimits,
 )
import OpenTelemetry.Exporter.Span (ExportResult (..), SpanExporter)
import qualified OpenTelemetry.Exporter.Span as SpanExporter
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Metric.Core (
  Meter (..),
  ObservableCounter (..),
  ObservableGauge (..),
  ObservableResult (..),
  defaultAdvisoryParameters,
 )
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core
import OpenTelemetry.Util (chunksOfV)
import System.Timeout (timeout)


{- | Configurable options for batch exporting frequence and size

@since 0.0.1.0
-}
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


{- | Default configuration values

@since 0.0.1.0
-}
batchTimeoutConfig :: BatchTimeoutConfig
batchTimeoutConfig =
  BatchTimeoutConfig
    { maxQueueSize = 2048
    , scheduledDelayMillis = 5000
    , exportTimeoutMillis = 30000
    , maxExportBatchSize = 512
    }


-- | Shared attributes for SDK self-telemetry on the batching span processor.
componentAttrs :: Attributes
componentAttrs =
  unsafeAttributesFromListIgnoringLimits
    [ ("otel.component.type", toAttribute ("batching_span_processor" :: Text))
    , ("otel.component.name", toAttribute ("batching_span_processor/0" :: Text))
    ]


droppedAttrs :: Attributes
droppedAttrs =
  unsafeAttributesFromListIgnoringLimits
    [ ("otel.component.type", toAttribute ("batching_span_processor" :: Text))
    , ("otel.component.name", toAttribute ("batching_span_processor/0" :: Text))
    , ("error.type", toAttribute ("queue_full" :: Text))
    ]


{- | Control channel messages. The data channel (unagi-chan) carries spans;
this small side-channel carries wake-up and lifecycle signals, keeping
STM entirely out of the picture.
-}
data CtrlMsg
  = WakeFlush
  | FlushAndNotify !(MVar ())
  | ShutdownMsg


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

@since 0.0.1.0
-}
batchProcessor :: (MonadIO m) => BatchTimeoutConfig -> SpanExporter -> m SpanProcessor
batchProcessor conf exporter = liftIO $ batchProcessorInternal conf exporter Nothing


{- | Like 'batchProcessor', but registers OpenTelemetry SDK self-telemetry metrics
 on the given 'Meter' (queue size\/capacity, processed spans by outcome, exported spans).

 Applications opt in by obtaining a meter (for example for the SDK scope) and passing it here.

@since 0.1.0.1
-}
batchProcessorWithMetrics :: (MonadIO m) => BatchTimeoutConfig -> SpanExporter -> Meter -> m SpanProcessor
batchProcessorWithMetrics conf exporter meter = liftIO $ batchProcessorInternal conf exporter (Just meter)


batchProcessorInternal :: BatchTimeoutConfig -> SpanExporter -> Maybe Meter -> IO SpanProcessor
batchProcessorInternal BatchTimeoutConfig {..} exporter mMeter = do
  unless rtsSupportsBoundThreads $
    otelLogWarning "Batch span processor running without -threaded; blocking exporter calls may stall the application"
  (dataIn, dataOut) <- UChan.newChan maxQueueSize
  (ctrlIn, ctrlOut) <- UChan.newChan 64
  droppedSpans <- newAtomicCounter 0
  exportedSpans <- newAtomicCounter 0
  shutdownRef <- newIORef False

  case mMeter of
    Nothing -> pure ()
    Just meter -> do
      let noAdv = defaultAdvisoryParameters
      ogQ <-
        meterCreateObservableGaugeInt64
          meter
          "otel.sdk.processor.span.queue.size"
          (Just "{span}")
          (Just "The number of spans in the queue of a given instance of an SDK span processor")
          noAdv
          []
      void $
        observableGaugeRegisterCallback ogQ $ \res -> do
          len <- UChan.estimatedLength dataIn
          observe res (fromIntegral len :: Int64) componentAttrs
      ogCap <-
        meterCreateObservableGaugeInt64
          meter
          "otel.sdk.processor.span.queue.capacity"
          (Just "{span}")
          (Just "The maximum number of spans the queue can hold")
          noAdv
          []
      void $
        observableGaugeRegisterCallback ogCap $ \res ->
          observe res (fromIntegral maxQueueSize :: Int64) componentAttrs
      ocProc <-
        meterCreateObservableCounterInt64
          meter
          "otel.sdk.processor.span.processed"
          (Just "{span}")
          (Just "The number of spans for which processing has finished")
          noAdv
          []
      void $
        observableCounterRegisterCallback ocProc $ \res -> do
          exported <- readAtomicCounter exportedSpans
          dropped <- readAtomicCounter droppedSpans
          observe res (fromIntegral exported) componentAttrs
          when (dropped > 0) $
            observe res (fromIntegral dropped) droppedAttrs
      ocExp <-
        meterCreateObservableCounterInt64
          meter
          "otel.sdk.exporter.span.exported"
          (Just "{span}")
          (Just "The number of spans for which the export has finished")
          noAdv
          []
      void $
        observableCounterRegisterCallback ocExp $ \res -> do
          exported <- readAtomicCounter exportedSpans
          observe res (fromIntegral exported) componentAttrs

  -- Periodic wake-up: poke the control channel on each tick so the
  -- consumer drains even when no burst threshold is crossed.
  timerThread <-
    async $
      let loop = do
            threadDelay (millisToMicros scheduledDelayMillis)
            void $ UChan.tryWriteChan ctrlIn WakeFlush
            shut <- readIORef shutdownRef
            unless shut loop
      in loop

  let publish batchToProcess = do
        mResult <-
          timeout (millisToMicros exportTimeoutMillis) $
            mask_ $
              SpanExporter.spanExporterExport exporter batchToProcess
        pure $ fromMaybe (Failure Nothing) mResult

      -- Spec: "The processor MUST synchronize calls to SpanExporter's
      -- Export to make sure that they are not invoked concurrently."
      publishChunked spans = do
        let chunks = chunksOfV maxExportBatchSize spans
        mapM_
          ( \chunk -> do
              let !grouped = groupByTracer chunk
              result <- try @SomeException $ publish grouped
              case result of
                Right Success -> void $ addAtomicCounter (V.length chunk) exportedSpans
                Left ex ->
                  otelLogWarning $ "Batch span export failed: " <> show ex
                Right (Failure mex) ->
                  otelLogWarning $
                    "Batch span export failed: "
                      <> maybe "timeout or unspecified" show mex
          )
          chunks

      drainUpTo :: Int -> IO (Vector ImmutableSpan)
      drainUpTo n = do
        est <- UChan.estimatedLength dataIn
        let !toRead = min n (max 0 est)
        V.replicateM toRead (UChan.readChan dataOut)

      -- Tight drain loop: keep pulling maxExportBatchSize chunks while
      -- the queue has items, avoiding a round-trip through the control
      -- channel between each batch under burst load.
      drainLoop = do
        batch <- drainUpTo maxExportBatchSize
        unless (V.null batch) $ do
          publishChunked batch
          est <- UChan.estimatedLength dataIn
          when (est > 0) drainLoop

      flushQueueImmediately ret = do
        batch <- drainUpTo maxQueueSize
        if V.null batch
          then pure ret
          else do
            publishChunked batch
            flushQueueImmediately ret

      workerAction = do
        msg <- UChan.readChan ctrlOut
        drainLoop
        -- Check shutdown flag as a fallback in case ShutdownMsg was
        -- dropped by tryWriteChan (control channel full).
        shut <- readIORef shutdownRef
        if shut
          then flushQueueImmediately Success
          else case msg of
            ShutdownMsg -> flushQueueImmediately Success
            FlushAndNotify mv -> do
              void $ tryPutMVar mv ()
              workerAction
            WakeFlush -> workerAction

  -- see note [Unmasking Asyncs]
  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure $
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \imm -> do
          isShutdown <- readIORef shutdownRef
          unless isShutdown $
            when (isSampled (traceFlags (spanContext imm))) $ do
              ok <- UChan.tryWriteChan dataIn imm
              if ok
                then do
                  len <- UChan.estimatedLength dataIn
                  when (len >= maxExportBatchSize) $
                    void $
                      UChan.tryWriteChan ctrlIn WakeFlush
                else void $ incrAtomicCounter droppedSpans
      , spanProcessorForceFlush = do
          mv <- newEmptyMVar
          ok <- UChan.tryWriteChan ctrlIn (FlushAndNotify mv)
          if ok
            then do
              mDone <- timeout (millisToMicros exportTimeoutMillis) (takeMVar mv)
              _ <- SpanExporter.spanExporterForceFlush exporter
              pure $ case mDone of
                Nothing -> FlushTimeout
                Just () -> FlushSuccess
            else do
              _ <- SpanExporter.spanExporterForceFlush exporter
              pure FlushSuccess
      , spanProcessorShutdown = do
          atomicWriteIORef shutdownRef True
          void $ UChan.tryWriteChan ctrlIn ShutdownMsg

          mResult <- timeout (millisToMicros exportTimeoutMillis) (waitCatch worker)
          cancel worker
          cancel timerThread
          flushRes <- SpanExporter.spanExporterForceFlush exporter
          shutRes <- SpanExporter.spanExporterShutdown exporter

          let !workerResult = case mResult of
                Nothing -> ShutdownTimeout
                Just (Left _) -> ShutdownFailure
                Just (Right _) -> ShutdownSuccess
              !exporterResult = case (flushRes, shutRes) of
                (FlushError, _) -> ShutdownFailure
                (_, ShutdownFailure) -> ShutdownFailure
                (_, ShutdownTimeout) -> ShutdownTimeout
                (FlushTimeout, _) -> ShutdownTimeout
                _ -> ShutdownSuccess
          pure $! worstShutdown workerResult exporterResult
      }
  where
    millisToMicros = (* 1000)


groupByTracer :: Vector ImmutableSpan -> HashMap InstrumentationLibrary (Vector ImmutableSpan)
groupByTracer spans
  | V.null spans = HashMap.empty
  | otherwise =
      let !first = V.unsafeIndex spans 0
          !firstLib = tracerName (spanTracer first)
          -- Fast path: if every span comes from the same tracer (common case),
          -- skip the HashMap entirely.
          allSame = V.all (\s -> tracerName (spanTracer s) == firstLib) spans
      in if allSame
          then HashMap.singleton firstLib spans
          else
            fmap V.fromList $
              V.foldl' (\acc s -> HashMap.insertWith (flip (++)) (tracerName (spanTracer s)) [s] acc) HashMap.empty spans
