{- |
Module      :  OpenTelemetry.Context.ThreadLocal.Propagation
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Description :  Primitives for carrying OpenTelemetry context across thread boundaries.
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Haskell's green threads do not inherit thread-local state. Any time you
fork a thread, directly with 'Control.Concurrent.forkIO', or indirectly
through @async@, @mapConcurrently@, etc., the child starts with an
empty 'Context'. This silently breaks trace propagation and baggage
flow.

This module provides drop-in replacements for common concurrency
primitives that capture the caller's 'Context' and install it in the
child thread before running the user action. The pattern mirrors
Go's explicit @ctx@ parameter and Java\/Python's automatic context
inheritance for child tasks.

== Quick start

@
import OpenTelemetry.Context.ThreadLocal.Propagation

-- Instead of @async work@:
a <- tracedAsync work

-- Instead of @forkIO work@:
tid <- tracedForkIO work

-- Instead of @mapConcurrently f xs@:
results <- tracedMapConcurrently f xs
@

If you need to integrate with a concurrency primitive not covered here,
use 'propagateContext' to wrap any @IO@ action so it inherits the
current thread's context:

@
myCustomFork action = customFork (propagateContext action)
@

@since 0.4.0.0
-}
module OpenTelemetry.Context.ThreadLocal.Propagation (
  -- * Core combinator
  propagateContext,

  -- * Common concurrency wrappers
  tracedForkIO,
  tracedAsync,
  tracedWithAsync,
  tracedConcurrently,
  tracedMapConcurrently,
  tracedForConcurrently,
) where

import Control.Concurrent (ThreadId, forkIO)
import Control.Concurrent.Async (Async, async, concurrently, forConcurrently, mapConcurrently, withAsync)
import OpenTelemetry.Context (Context)
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)


{- | Capture the current thread's 'Context' and return an action that,
when run in /any/ thread, installs that context before executing the
wrapped computation.

This is the fundamental building block. The other combinators in this
module are thin wrappers around it.

@since 0.4.0.0
-}
propagateContext :: IO a -> IO (IO a)
propagateContext action = do
  ctx <- getContext
  pure (installContext ctx >> action)
{-# INLINE propagateContext #-}


{- | 'forkIO' with automatic context propagation.

@since 0.4.0.0
-}
tracedForkIO :: IO () -> IO ThreadId
tracedForkIO action = do
  wrapped <- propagateContext action
  forkIO wrapped
{-# INLINE tracedForkIO #-}


{- | 'async' with automatic context propagation.

@since 0.4.0.0
-}
tracedAsync :: IO a -> IO (Async a)
tracedAsync action = do
  wrapped <- propagateContext action
  async wrapped
{-# INLINE tracedAsync #-}


{- | 'withAsync' with automatic context propagation.

@since 0.4.0.0
-}
tracedWithAsync :: IO a -> (Async a -> IO b) -> IO b
tracedWithAsync action k = do
  wrapped <- propagateContext action
  withAsync wrapped k
{-# INLINE tracedWithAsync #-}


{- | 'concurrently' with automatic context propagation for both branches.

@since 0.4.0.0
-}
tracedConcurrently :: IO a -> IO b -> IO (a, b)
tracedConcurrently left right = do
  l <- propagateContext left
  r <- propagateContext right
  concurrently l r
{-# INLINE tracedConcurrently #-}


{- | 'mapConcurrently' with automatic context propagation.

Each concurrent worker inherits the caller's context.

@since 0.4.0.0
-}
tracedMapConcurrently :: (Traversable t) => (a -> IO b) -> t a -> IO (t b)
tracedMapConcurrently f ta = do
  ctx <- getContext
  mapConcurrently (\a -> installContext ctx >> f a) ta
{-# INLINE tracedMapConcurrently #-}


{- | 'forConcurrently' with automatic context propagation.

@since 0.4.0.0
-}
tracedForConcurrently :: (Traversable t) => t a -> (a -> IO b) -> IO (t b)
tracedForConcurrently ta f = do
  ctx <- getContext
  forConcurrently ta (\a -> installContext ctx >> f a)
{-# INLINE tracedForConcurrently #-}


installContext :: Context -> IO ()
installContext ctx = do
  _ <- attachContext ctx
  pure ()
{-# INLINE installContext #-}
