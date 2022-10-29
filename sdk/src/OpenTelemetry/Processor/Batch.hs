{-# LANGUAGE RecordWildCards #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Processor.Batch
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Performant exporting of spans in time & space-bounded batches.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 This is an implementation of the Span Processor which create batches of finished spans and passes the export-friendly span data representations to the configured Exporter.
-}
module OpenTelemetry.Processor.Batch (
  BatchTimeoutConfig (..),
  batchTimeoutConfig,
  batchProcessor,
  -- , BatchProcessorOperations
) where

import Control.Concurrent.Async
import Control.Concurrent.STM
import Control.Exception
import Control.Monad
import Control.Monad.IO.Class
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.IORef (atomicModifyIORef', newIORef, readIORef)
import Data.Vector (Vector)
import OpenTelemetry.Exporter (Exporter)
import qualified OpenTelemetry.Exporter as Exporter
import OpenTelemetry.Processor
import OpenTelemetry.Trace.Core
import VectorBuilder.Builder as Builder
import VectorBuilder.Vector as Builder


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
    { maxQueueSize = 1024
    , scheduledDelayMillis = 5000
    , exportTimeoutMillis = 30000
    , maxExportBatchSize = 512
    }


-- type BatchProcessorOperations = ()

--  A multi-producer single-consumer green/blue buffer.
-- Write requests that cannot fit in the live chunk will be dropped
--
-- TODO, would be cool to use AtomicCounters for this if possible
-- data GreenBlueBuffer a = GreenBlueBuffer
--   { gbReadSection :: !(TVar Word)
--   , gbWriteGreenOrBlue :: !(TVar Word)
--   , gbPendingWrites :: !(TVar Word)
--   , gbSectionSize :: !Int
--   , gbVector :: !(M.IOVector a)
--   }

{- brainstorm: Single Word64 state sketch

  63 (high bit): green or blue
  32-62: read section
  0-32: write count
-}

{-

Green
    512       512       512       512
\|---------|---------|---------|---------|
     0         1         2         3

Blue
    512       512       512       512
\|---------|---------|---------|---------|
     0         1         2         3

The current read section denotes one chunk of length gbSize, which gets flushed
to the span exporter. Once the vector has been copied for export, gbReadSection
will be incremented.

-}

-- newGreenBlueBuffer
--   :: Int  --  Max queue size (2048)
--   -> Int  --  Export batch size (512)
--   -> IO (GreenBlueBuffer a)
-- newGreenBlueBuffer maxQueueSize batchSize = do
--   let logBase2 = finiteBitSize maxQueueSize - 1 - countLeadingZeros maxQueueSize

--   let closestFittingPowerOfTwo = 2 * if (1 `shiftL` logBase2) == maxQueueSize
--         then maxQueueSize
--         else 1 `shiftL` (logBase2 + 1)

--   readSection <- newTVarIO 0
--   writeSection <- newTVarIO 0
--   writeCount <- newTVarIO 0
--   buf <- M.new closestFittingPowerOfTwo
--   pure $ GreenBlueBuffer
--     { gbSize = maxQueueSize
--     , gbVector = buf
--     , gbReadSection = readSection
--     , gbPendingWrites = writeCount
--     }

-- isEmpty :: GreenBlueBuffer a -> STM Bool
-- isEmpty = do
--   c <- readTVar gbPendingWrites
--   pure (c == 0)

-- data InsertResult = ValueDropped | ValueInserted

-- tryInsert :: GreenBlueBuffer a -> a -> IO InsertResult
-- tryInsert GreenBlueBuffer{..} x = atomically $ do
--   c <- readTVar gbPendingWrites
--   if c == gbMaxLength
--     then pure ValueDropped
--     else do
--       greenOrBlue <- readTVar gbWriteGreenOrBlue
--       let i = c + ((M.length gbVector `shiftR` 1) `shiftL` (greenOrBlue `mod` 2))
--       M.write gbVector i x
--       writeTVar gbPendingWrites (c + 1)
--       pure ValueInserted

-- Caution, single writer means that this can't be called concurrently
-- consumeChunk :: GreenBlueBuffer a -> IO (V.Vector a)
-- consumeChunk GreenBlueBuffer{..} = atomically $ do
--   r <- readTVar gbReadSection
--   w <- readTVar gbWriteSection
--   c <- readTVar gbPendingWrites
--   when (r == w) $ do
--     modifyTVar gbWriteSection (+ 1)
--     setTVar gbPendingWrites 0
--   -- TODO slice and freeze appropriate section
-- M.slice (gbSectionSize * (r .&. gbSectionMask)

-- TODO, counters for dropped spans, exported spans

data BoundedMap a = BoundedMap
  { itemBounds :: !Int
  , itemCount :: !Int
  , itemMap :: HashMap InstrumentationLibrary (Builder.Builder a)
  }


boundedMap :: Int -> BoundedMap a
boundedMap bounds = BoundedMap bounds 0 mempty


push :: ImmutableSpan -> BoundedMap ImmutableSpan -> Maybe (BoundedMap ImmutableSpan)
push s m =
  if itemCount m + 1 >= itemBounds m
    then Nothing
    else
      Just $!
        m
          { itemCount = itemCount m + 1
          , itemMap =
              HashMap.insertWith
                (<>)
                (tracerName $ spanTracer s)
                (Builder.singleton s)
                $ itemMap m
          }


buildExport :: BoundedMap a -> (BoundedMap a, HashMap InstrumentationLibrary (Vector a))
buildExport m =
  ( m {itemCount = 0, itemMap = mempty}
  , Builder.build <$> itemMap m
  )


data ProcessorMessage = Flush | Shutdown


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
-}
batchProcessor :: MonadIO m => BatchTimeoutConfig -> Exporter ImmutableSpan -> m Processor
batchProcessor BatchTimeoutConfig {..} exporter = liftIO $ do
  batch <- newIORef $ boundedMap maxQueueSize
  workSignal <- newEmptyTMVarIO
  shutdownSignal <- newEmptyTMVarIO
  let workerAction = do
        delay <- registerDelay (millisToMicros scheduledDelayMillis)
        req <- atomically $ do
          msum
            [ const Flush <$> do
                continue <- readTVar delay
                check continue
            , const Flush <$> takeTMVar workSignal
            , const Shutdown <$> takeTMVar shutdownSignal
            ]
        batchToProcess <- atomicModifyIORef' batch buildExport
        -- we mask async exceptions in this, so that a buggy exporter that
        -- catches async exceptions won't swallow them. since we use
        -- an interruptible mask, blocking calls can still be killed, like
        -- `threadDelay` or `putMVar` or most file I/O operations.
        --
        -- if we've received a shutdown, then we should be expecting
        -- a `cancel` anytime now.
        res <- mask_ $ Exporter.exporterExport exporter batchToProcess

        -- if we were asked to shutdown, quit cleanly after this batch
        -- FIXME: this could lose batches if there's more than one in queue?
        case req of
          Shutdown ->
            pure res
          _ ->
            workerAction
  -- see note [Unmasking Asyncs]
  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure $
    Processor
      { processorOnStart = \_ _ -> pure ()
      , processorOnEnd = \s -> do
          span_ <- readIORef s
          appendFailed <- atomicModifyIORef' batch $ \builder ->
            case push span_ builder of
              Nothing -> (builder, True)
              Just b' -> (b', False)
          when appendFailed $ void $ atomically $ tryPutTMVar workSignal ()
      , processorForceFlush = void $ atomically $ tryPutTMVar workSignal ()
      , -- TODO where to call restore, if anywhere?
        processorShutdown =
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
              void $ atomically $ putTMVar shutdownSignal ()

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
                    , const Nothing <$> do
                        shouldStop <- readTVar delay
                        check shouldStop
                    ]

              -- make sure the worker comes down. does not wait for the
              -- worker thread to complete. wraps in SomeAsyncException to
              -- ensure that any exception handler in the worker know sit
              -- is an async exception.
              throwTo (asyncThreadId worker) (SomeAsyncException AsyncCancelled)
              -- TODO, not convinced we should shut down processor here

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

{-
buffer <- newGreenBlueBuffer _ _
batchProcessorAction <- async $ forever $ do
  -- It would be nice to do an immediate send when possible
  chunk <- if (sendDelay == 0)
    else consumeChunk
    then threadDelay sendDelay >> consumeChunk
  timeout _ $ export exporter chunk
pure $ Processor
  { onStart = \_ _ -> pure ()
  , onEnd = \s -> void $ tryInsert buffer s
  , shutdown = do
      gracefullyShutdownBatchProcessor

  , forceFlush = pure ()
  }
where
  sendDelay = scheduledDelayMilis * 1_000
-}
