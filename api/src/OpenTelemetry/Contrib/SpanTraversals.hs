module OpenTelemetry.Contrib.SpanTraversals (
  alterSpansUpwards,
  IterationInstruction (..),
) where

import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.Internal.Trace.Types


data IterationInstruction a = Continue a | Halt


{- | Alter traces upwards from the provided span to the highest available mutable span.

The callback receives the 'ImmutableSpan' (for reading cold fields like parent)
and the current 'SpanHot' (for reading\/modifying mutable fields). It returns an
'IterationInstruction' and the (possibly modified) 'SpanHot'.

Iteration continues upward until a non-mutable span is reached, there are no
more parents, or the callback returns 'Halt'.
-}
alterSpansUpwards :: (MonadIO m) => Span -> st -> (st -> ImmutableSpan -> SpanHot -> (IterationInstruction st, SpanHot)) -> m st
alterSpansUpwards (Span imm) st f = liftIO $ do
  step <- atomicModifyIORef' (spanHot imm) $ \h ->
    let (step, h') = f st imm h in (h', step)
  case step of
    Continue st' -> case spanParent imm of
      Nothing -> return st'
      Just s -> alterSpansUpwards s st' f
    Halt -> return st
alterSpansUpwards (FrozenSpan _) st _ = return st
alterSpansUpwards (Dropped _) st _ = return st
