{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE UnboxedSums #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Context
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Carrier for execution-scoped values across API boundaries
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 The ability to correlate events across service boundaries is one of the principle concepts behind distributed tracing. To find these correlations, components in a distributed system need to be able to collect, store, and transfer metadata referred to as context.

 A context will often have information identifying the current span and trace, and can contain arbitrary correlations as key-value pairs.

 Propagation is the means by which context is bundled and transferred in and across services, often via HTTP headers.

 Together, context and propagation represent the engine behind distributed tracing.
-}
module OpenTelemetry.Context (
  Key (keyName),
  newKey,
  Context,
  HasContext (..),
  empty,
  lookup,
  insert,
  -- , insertWith
  adjust,
  delete,
  union,
  insertSpan,
  lookupSpan,
  removeSpan,
  insertBaggage,
  lookupBaggage,
  removeBaggage,
) where

import Control.Monad.IO.Class
import Data.Text (Text)
import qualified Data.Vault.Strict as V
import OpenTelemetry.Baggage (Baggage)
import OpenTelemetry.Context.Types
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Internal.UnpackedMaybe
import Unsafe.Coerce (unsafeCoerce)
import Prelude hiding (lookup)


newKey :: (MonadIO m) => Text -> m (Key a)
newKey n = liftIO (Key n <$> V.newKey)


class HasContext s where
  contextL :: Lens' s Context


empty :: Context
empty = Context UNothing UNothing V.empty
{-# INLINE empty #-}


lookup :: Key a -> Context -> Maybe a
lookup (Key _ k) (Context _ _ v) = V.lookup k v
{-# INLINE lookup #-}


insert :: Key a -> a -> Context -> Context
insert (Key _ k) x (Context s b v) = Context s b (V.insert k x v)
{-# INLINE insert #-}


adjust :: (a -> a) -> Key a -> Context -> Context
adjust f (Key _ k) (Context s b v) = Context s b (V.adjust f k v)


delete :: Key a -> Context -> Context
delete (Key _ k) (Context s b v) = Context s b (V.delete k v)


union :: Context -> Context -> Context
union = (<>)


-- Span operations — O(1) via dedicated unboxed slot, no vault/hash overhead

lookupSpan :: Context -> Maybe Span
lookupSpan (Context s _ _) = case s of
  UNothing -> Nothing
  UJust x -> Just (unsafeCoerce x)
{-# INLINE lookupSpan #-}


insertSpan :: Span -> Context -> Context
insertSpan !span (Context _ b v) = Context (UJust (unsafeCoerce span)) b v
{-# INLINE insertSpan #-}


removeSpan :: Context -> Context
removeSpan (Context _ b v) = Context UNothing b v
{-# INLINE removeSpan #-}


-- Baggage operations — O(1) via dedicated unboxed slot

lookupBaggage :: Context -> Maybe Baggage
lookupBaggage (Context _ b _) = toBaseMaybe b
{-# INLINE lookupBaggage #-}


insertBaggage :: Baggage -> Context -> Context
insertBaggage bag (Context s mb v) = case mb of
  UNothing -> Context s (UJust bag) v
  UJust existing -> Context s (UJust (bag <> existing)) v
{-# INLINE insertBaggage #-}


removeBaggage :: Context -> Context
removeBaggage (Context s _ v) = Context s UNothing v
{-# INLINE removeBaggage #-}
