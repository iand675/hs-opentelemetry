{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE UnliftedFFITypes #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Context.ThreadLocal
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  State management for 'OpenTelemetry.Context.Context' on a per-thread basis.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Thread-local contexts may be attached as implicit state at a per-Haskell-thread
 level.

 This module uses a fair amount of GHC internals to enable performing
 lookups of context for any threads that are alive. Caution should be
 taken for consumers of this module to not retain ThreadId references
 indefinitely, as that could delay cleanup of thread-local state.

 Thread-local contexts have the following semantics:

 - A value 'attach'ed to a 'ThreadId' will remain alive at least as long
   as the 'ThreadId'.
 - A value may be detached from a 'ThreadId' via 'detach' by the
   library consumer without detriment.
 - No guarantees are made about when a value will be garbage-collected
   once all references to 'ThreadId' have been dropped. However, this simply
   means in practice that any unused contexts will cleaned up upon the next
   garbage collection and may not be actively freed when the program exits.
-}
module OpenTelemetry.Context.ThreadLocal (
  -- * Thread-local context
  getContext,
  lookupContext,
  attachContext,
  detachContext,
  adjustContext,
  getAndAdjustContext,

  -- * Fused context operations (single myThreadId + FFI call)
  getContextAndModify,
  getContextAndRestore,

  -- ** Generalized thread-local context functions

  -- You should not use these without using some sort of specific cross-thread coordination mechanism,
  -- as there is no guarantee of what work the remote thread has done yet.
  lookupContextOnThread,
  attachContextOnThread,
  detachContextFromThread,
  adjustContextOnThread,

  -- ** Debugging tools
  threadContextMap,
) where

import Control.Concurrent
import Control.Concurrent.Thread.Storage
import Control.Monad.IO.Class
import Data.Maybe (fromMaybe)
import OpenTelemetry.Context (Context, empty)
import System.IO.Unsafe
import Prelude hiding (lookup)


type ThreadContextMap = ThreadStorageMap Context


{- | This is a global variable that is used to store the thread-local context map.
 It is not intended to be used directly for production purposes, but is exposed for debugging purposes.
-}
threadContextMap :: ThreadContextMap
threadContextMap = unsafePerformIO newThreadStorageMap
{-# NOINLINE threadContextMap #-}


{- | Retrieve a stored 'Context' for the current thread, or an empty context if none exists.

 Warning: this can easily cause disconnected traces if libraries don't explicitly set the
 context on forked threads.

 @since 0.0.1.0
-}
getContext :: (MonadIO m) => m Context
getContext = fromMaybe empty <$> lookupContext
{-# INLINE getContext #-}


{- | Retrieve a stored 'Context' for the current thread, if it exists.

 @since 0.0.1.0
-}
lookupContext :: (MonadIO m) => m (Maybe Context)
lookupContext = lookup threadContextMap
{-# INLINE lookupContext #-}


{- | Retrieve a stored 'Context' for the provided 'ThreadId', if it exists.

 @since 0.0.1.0
-}
lookupContextOnThread :: (MonadIO m) => ThreadId -> m (Maybe Context)
lookupContextOnThread = lookupOnThread threadContextMap
{-# INLINE lookupContextOnThread #-}


{- | Store a given 'Context' for the current thread, returning any context previously stored.

 @since 0.0.1.0
-}
attachContext :: (MonadIO m) => Context -> m (Maybe Context)
attachContext = attach threadContextMap
{-# INLINE attachContext #-}


{- | Store a given 'Context' for the provided 'ThreadId', returning any context previously stored.

 @since 0.0.1.0
-}
attachContextOnThread :: (MonadIO m) => ThreadId -> Context -> m (Maybe Context)
attachContextOnThread = attachOnThread threadContextMap
{-# INLINE attachContextOnThread #-}


{- | Remove a stored 'Context' for the current thread, returning any context previously stored.

The detach functions don't generally need to be called manually, because finalizers will automatically
clean up contexts when a thread has completed and been garbage collected. If you are replacing a context
on a long-lived thread by detaching and attaching, use `adjustContext (const newContext)` instead to avoid
registering additional finalizer functions to be called on thread exit.

 @since 0.0.1.0
-}
detachContext :: (MonadIO m) => m (Maybe Context)
detachContext = detach threadContextMap
{-# INLINE detachContext #-}


{- | Remove a stored 'Context' for the provided 'ThreadId', returning any context previously stored.

The detach functions don't generally need to be called manually, because finalizers will automatically
clean up contexts when a thread has completed and been garbage collected. If you are replacing a context
on a long-lived thread by detaching and attaching, use `adjustContext (const newContext)` instead to avoid
registering additional finalizer functions to be called on thread exit.

 @since 0.0.1.0
-}
detachContextFromThread :: (MonadIO m) => ThreadId -> m (Maybe Context)
detachContextFromThread = detachFromThread threadContextMap
{-# INLINE detachContextFromThread #-}


{- | Alter the context on the current thread using the provided function.

If there is not a context associated with the current thread, the function will
be applied to an empty context and the result will be stored

 @since 0.0.1.0
-}
adjustContext :: (MonadIO m) => (Context -> Context) -> m ()
adjustContext f = update threadContextMap $ \mctx ->
  let !ctx' = f $! fromMaybe empty mctx
  in (pure ctx', ())
{-# INLINE adjustContext #-}


{- | Atomically read the current context and replace it via @f@ in a single
CAS operation, returning the old context. This fuses a @getContext@ +
@adjustContext@ pair into one thread-local round-trip.
-}
getAndAdjustContext :: (MonadIO m) => (Context -> Context) -> m Context
getAndAdjustContext f = update threadContextMap $ \mctx ->
  let !old = fromMaybe empty mctx
      !new = f old
  in (pure new, old)
{-# INLINE getAndAdjustContext #-}


{- | Read the current context, then apply a function that produces both a new
context and a result, all using a single @myThreadId@ + @getThreadId@ pair.

This is the hot path for span creation: we need to read the current context
(to find the parent span), then update the context (to insert the new span).
Doing both in one go avoids a second @myThreadId@ syscall and a second FFI
call to @rts_getThreadId@.

@
(ctx, result) <- getContextAndModify $ \ctx ->
    let !span = createSpanPure tracer ctx name args
        !ctx' = insertSpan span ctx
    in (ctx', (ctx, span))
@
-}
getContextAndModify :: (Context -> (Context, a)) -> IO a
getContextAndModify f = do
  tid <- myThreadId
  let !tidWord = getThreadId tid
  updateRaw threadContextMap tid tidWord $ \mctx ->
    let !old = fromMaybe empty mctx
    in case f old of
      (!new, !result) -> (Just new, result)
{-# INLINE getContextAndModify #-}


{- | Read the current context, run an IO action with it, then restore a
previous context. Uses a single @myThreadId@ + @getThreadId@ pair cached
across the lookup, the update-after-action, and the restoration.

This is the pattern used for span lifecycle: read context, create span,
insert span into context, run user code, then restore original context.
-}
getContextAndRestore
  :: (Context -> IO (Context, a))
  -- ^ Given the current context, produce a new context and a resource
  -> (a -> IO ())
  -- ^ Cleanup action using the resource
  -> IO Context
  -- ^ Returns the original context (before modification)
getContextAndRestore act cleanup = do
  tid <- myThreadId
  let !tidWord = getThreadId tid
  -- Read current context
  mctx <- lookupRaw threadContextMap tidWord
  let !ctx = fromMaybe empty mctx
  -- Run action to produce updated context and resource
  (!newCtx, !resource) <- act ctx
  -- Write updated context
  updateRaw threadContextMap tid tidWord $ \_ ->
    (Just newCtx, ())
  -- Run cleanup
  cleanup resource
  pure ctx
{-# INLINE getContextAndRestore #-}


{- | Alter the context

If there is not a context associated with the provided thread, the function will
be applied to an empty context and the result will be stored

 @since 0.0.1.0
-}
adjustContextOnThread :: (MonadIO m) => ThreadId -> (Context -> Context) -> m ()
adjustContextOnThread tid f = updateOnThread threadContextMap tid $ \mctx ->
  (pure $ f $ fromMaybe empty mctx, ())
{-# INLINE adjustContextOnThread #-}
