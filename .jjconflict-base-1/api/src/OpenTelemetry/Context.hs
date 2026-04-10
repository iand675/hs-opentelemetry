{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE UnboxedSums #-}

{- |
Module      :  OpenTelemetry.Context
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Carrier for execution-scoped values across API boundaries
Stability   :  experimental

= Overview

A 'Context' carries trace state (the current 'Span') and 'Baggage' across
API boundaries and through your application. You rarely interact with it
directly; the @inSpan@ functions and propagators manage it for you.

= When you need Context directly

* __Custom propagation__: extracting\/injecting context from non-HTTP transports
* __Manual span parenting__: creating a span as a child of a specific context
* __Baggage access__: reading or modifying baggage entries

= Quick example

@
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal

-- Read the current span from thread-local context:
ctx <- getContext
case lookupSpan ctx of
  Just span -> addAttribute span "custom.key" (toAttribute "value")
  Nothing   -> pure ()

-- Attach baggage to the current context:
adjustContext (insertBaggage myBaggage)
@

= Thread-local context

In most applications, context is stored in a thread-local variable managed
by "OpenTelemetry.Context.ThreadLocal". The @inSpan@ functions automatically
push and pop spans from this thread-local context.

= Spec reference

<https://opentelemetry.io/docs/specs/otel/context/>
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


-- | @since 0.0.1.0
newKey :: (MonadIO m) => Text -> m (Key a)
newKey n = liftIO (Key n <$> V.newKey)


-- | @since 0.0.1.0
class HasContext s where
  contextL :: Lens' s Context


-- | @since 0.0.1.0
empty :: Context
empty = Context UNothing UNothing V.empty
{-# INLINE empty #-}


-- | @since 0.0.1.0
lookup :: Key a -> Context -> Maybe a
lookup (Key _ k) (Context _ _ v) = V.lookup k v
{-# INLINE lookup #-}


-- | @since 0.0.1.0
insert :: Key a -> a -> Context -> Context
insert (Key _ k) x (Context s b v) = Context s b (V.insert k x v)
{-# INLINE insert #-}


-- | @since 0.0.1.0
adjust :: (a -> a) -> Key a -> Context -> Context
adjust f (Key _ k) (Context s b v) = Context s b (V.adjust f k v)


-- | @since 0.0.1.0
delete :: Key a -> Context -> Context
delete (Key _ k) (Context s b v) = Context s b (V.delete k v)


-- | @since 0.0.1.0
union :: Context -> Context -> Context
union = (<>)


-- Span operations: O(1) via dedicated unboxed slot, no vault/hash overhead

-- | @since 0.0.1.0
lookupSpan :: Context -> Maybe Span
lookupSpan (Context s _ _) = case s of
  UNothing -> Nothing
  UJust x -> Just (unsafeCoerce x)
{-# INLINE lookupSpan #-}


-- | @since 0.0.1.0
insertSpan :: Span -> Context -> Context
insertSpan !s (Context _ b v) = Context (UJust (unsafeCoerce s)) b v
{-# INLINE insertSpan #-}


-- | @since 0.0.1.0
removeSpan :: Context -> Context
removeSpan (Context _ b v) = Context UNothing b v
{-# INLINE removeSpan #-}


-- Baggage operations: O(1) via dedicated unboxed slot

-- | @since 0.0.1.0
lookupBaggage :: Context -> Maybe Baggage
lookupBaggage (Context _ b _) = toBaseMaybe b
{-# INLINE lookupBaggage #-}


-- | @since 0.0.1.0
insertBaggage :: Baggage -> Context -> Context
insertBaggage bag (Context s _ v) = Context s (UJust bag) v
{-# INLINE insertBaggage #-}


-- | @since 0.0.1.0
removeBaggage :: Context -> Context
removeBaggage (Context s _ v) = Context s UNothing v
{-# INLINE removeBaggage #-}
