{-# LANGUAGE RecordWildCards #-}
module OpenTelemetry.Trace.SpanProcessors.Batch 
  -- ( BatchTimeoutConfig(..)
  -- , batchProcessor
  -- , BatchProcessorOperations
  -- ) where
  where
import Control.Concurrent.STM
import Control.Monad.IO.Class
import Data.Bits
import qualified Data.Vector as V
import qualified Data.Vector.Mutable as M
import OpenTelemetry.Trace.SpanProcessor
import OpenTelemetry.Trace.SpanExporter (SpanExporter)
import qualified OpenTelemetry.Trace.SpanExporter as Exporter

-- data BatchTimeoutConfig = BatchTimeoutConfig
  -- { exporter :: SpanExporter 
  --  The exporter where spans are pushed.
  -- , maxQueueSize :: Int
  --  The maximum queue size. After the size is reached, spans are dropped.
  -- , scheduledDelayMilis :: Int 
  --  The delay interval in milliseconds between two consective exports.
  -- The default value is 5000.
  -- , exportTimeoutMillis :: Int
  --  How long the export can run before it is cancelled.
  -- The default value is 30000.
  -- , maxExportBatchSize :: Int
  --  the maximum batch size of every export. It must be
  -- smaller or equal to 'maxQueueSize'. The default value is 512.
  -- }

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
    


-- TODO, graceful shutdown
-- TODO, forceFlush
-- batchProcessor :: MonadIO m => BatchTimeoutConfig -> m SpanProcessor
-- batchProcessor BatchTimeoutConfig{..} = do
--   undefined
  {-
  buffer <- newGreenBlueBuffer _ _
  batchProcessorAction <- async $ forever $ do
    -- It would be nice to do an immediate send when possible
    chunk <- if (sendDelay == 0) 
      else consumeChunk
      then threadDelay sendDelay >> consumeChunk
    timeout _ $ export exporter chunk
  pure $ SpanProcessor
    { onStart = \_ _ -> pure ()
    , onEnd = \s -> void $ tryInsert buffer s
    , shutdown = do
        gracefullyShutdownBatchProcessor
        

    , forceFlush = pure ()
    }
  where
    sendDelay = scheduledDelayMilis * 1_000
  -}