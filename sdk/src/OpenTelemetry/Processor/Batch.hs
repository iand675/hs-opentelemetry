{-# LANGUAGE RecordWildCards #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Processor.Batch
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Performant exporting of spans in time & space-bounded batches.
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- This is an implementation of the Span Processor which create batches of finished spans and passes the export-friendly span data representations to the configured Exporter.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Processor.Batch
  ( BatchTimeoutConfig(..)
  , batchTimeoutConfig
  , batchProcessor
  -- , BatchProcessorOperations
  ) where
import Control.Monad.IO.Class
import OpenTelemetry.Processor
import OpenTelemetry.Exporter (Exporter)
import qualified OpenTelemetry.Exporter as Exporter
import VectorBuilder.Builder as Builder
import VectorBuilder.Vector as Builder
import Data.IORef (atomicModifyIORef', readIORef, newIORef)
import Control.Concurrent.Async
import Control.Concurrent.MVar (newEmptyMVar, takeMVar, tryPutMVar)
import Control.Monad
import Control.Monad.Trans.Except
import System.Timeout
import Control.Exception
import Data.HashMap.Strict (HashMap)
import OpenTelemetry.Trace.Core
import qualified Data.HashMap.Strict as HashMap
import Data.Vector (Vector)

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
  } deriving (Show)

-- | Default configuration values
batchTimeoutConfig :: BatchTimeoutConfig
batchTimeoutConfig = BatchTimeoutConfig
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
|---------|---------|---------|---------|
     0         1         2         3

Blue
    512       512       512       512
|---------|---------|---------|---------|
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
push s m = if itemCount m + 1 >= itemBounds m
  then Nothing
  else Just $! m
    { itemCount = itemCount m + 1
    , itemMap = HashMap.insertWith
        (<>)
        (tracerName $ spanTracer s)
        (Builder.singleton s) $
        itemMap m
    }

buildExport :: BoundedMap a -> (BoundedMap a, HashMap InstrumentationLibrary (Vector a))
buildExport m =
  ( m { itemCount = 0, itemMap = mempty }
  , Builder.build <$> itemMap m
  )

-- | Exitable forever loop
loop :: Monad m => ExceptT e m a -> m e
loop = liftM (either id id) . runExceptT . forever

data ProcessorMessage = Flush | Shutdown

-- |
-- The batch processor accepts spans and places them into batches. Batching helps better compress the data and reduce the number of outgoing connections
-- required to transmit the data. This processor supports both size and time based batching.
--
batchProcessor :: MonadIO m => BatchTimeoutConfig -> Exporter ImmutableSpan -> m Processor
batchProcessor BatchTimeoutConfig{..} exporter = liftIO $ do
  batch <- newIORef $ boundedMap maxQueueSize
  workSignal <- newEmptyMVar
  worker <- async $ loop $ do
    req <- liftIO $ timeout (millisToMicros scheduledDelayMillis)
      $ takeMVar workSignal
    batchToProcess <- liftIO $ atomicModifyIORef' batch buildExport
    res <- liftIO $ Exporter.exporterExport exporter batchToProcess

    -- if we were asked to shutdown, quit cleanly after this batch
    -- FIXME: this could lose batches if there's more than one in queue?
    case req of
      Just Shutdown -> throwE res
      _ -> pure ()

  pure $ Processor
    { processorOnStart = \_ _ -> pure ()
    , processorOnEnd = \s -> do
        span_ <- readIORef s
        appendFailed <- atomicModifyIORef' batch $ \builder ->
          case push span_ builder of
            Nothing -> (builder, True)
            Just b' -> (b', False)
        when appendFailed $ void $ tryPutMVar workSignal Flush

    , processorForceFlush = void $ tryPutMVar workSignal Flush
    -- TODO where to call restore, if anywhere?
    , processorShutdown = async $ mask $ \_restore -> do
        -- flush remaining messages
        void $ tryPutMVar workSignal Shutdown

        shutdownResult <- timeout (millisToMicros exportTimeoutMillis) $
          wait worker
        -- make sure the worker comes down
        uninterruptibleCancel worker
        -- TODO, not convinced we should shut down processor here

        case shutdownResult of
          Nothing -> pure ShutdownFailure
          Just _ -> pure ShutdownSuccess
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
