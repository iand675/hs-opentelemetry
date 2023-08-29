module OpenTelemetry.Contrib.SpanTraversals (
  alterSpansUpwards,
  IterationInstruction (..),
) where

import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.Internal.Trace.Types


data IterationInstruction a = Continue a | Halt


{- | Alter traces upwards from the provides span to the highest available mutable span. Only mutable spans may be altered.

 The step value indicates whether the desired topmost span has been reached or not. This function will continue to iterate
 upwards until either a span that cannot be mutated has been reached, or there are no more parent spans remaining.
-}
alterSpansUpwards :: (MonadIO m) => Span -> st -> (st -> ImmutableSpan -> (IterationInstruction st, ImmutableSpan)) -> m st
alterSpansUpwards (Span immutableSpanRef) st f = liftIO $ do
  (step, a') <- atomicModifyIORef' immutableSpanRef (\a -> let (step, a') = f st a in (a', (step, a')))
  case step of
    Continue st' -> case spanParent a' of
      Nothing -> return st'
      Just s -> alterSpansUpwards s st' f
    Halt -> return st
alterSpansUpwards (FrozenSpan _) st _ = return st
alterSpansUpwards (Dropped _) st _ = return st
