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


{- | Retrieve a stored 'Context' for the current thread, if it exists.

 @since 0.0.1.0
-}
lookupContext :: (MonadIO m) => m (Maybe Context)
lookupContext = lookup threadContextMap


{- | Retrieve a stored 'Context' for the provided 'ThreadId', if it exists.

 @since 0.0.1.0
-}
lookupContextOnThread :: (MonadIO m) => ThreadId -> m (Maybe Context)
lookupContextOnThread = lookupOnThread threadContextMap


{- | Store a given 'Context' for the current thread, returning any context previously stored.

 @since 0.0.1.0
-}
attachContext :: (MonadIO m) => Context -> m (Maybe Context)
attachContext = attach threadContextMap


{- | Store a given 'Context' for the provided 'ThreadId', returning any context previously stored.

 @since 0.0.1.0
-}
attachContextOnThread :: (MonadIO m) => ThreadId -> Context -> m (Maybe Context)
attachContextOnThread = attachOnThread threadContextMap


{- | Remove a stored 'Context' for the current thread, returning any context previously stored.

The detach functions don't generally need to be called manually, because finalizers will automatically
clean up contexts when a thread has completed and been garbage collected. If you are replacing a context
on a long-lived thread by detaching and attaching, use `adjustContext (const newContext)` instead to avoid
registering additional finalizer functions to be called on thread exit.

 @since 0.0.1.0
-}
detachContext :: (MonadIO m) => m (Maybe Context)
detachContext = detach threadContextMap


{- | Remove a stored 'Context' for the provided 'ThreadId', returning any context previously stored.

The detach functions don't generally need to be called manually, because finalizers will automatically
clean up contexts when a thread has completed and been garbage collected. If you are replacing a context
on a long-lived thread by detaching and attaching, use `adjustContext (const newContext)` instead to avoid
registering additional finalizer functions to be called on thread exit.

 @since 0.0.1.0
-}
detachContextFromThread :: (MonadIO m) => ThreadId -> m (Maybe Context)
detachContextFromThread = detachFromThread threadContextMap


{- | Alter the context on the current thread using the provided function.

If there is not a context associated with the current thread, the function will
be applied to an empty context and the result will be stored

 @since 0.0.1.0
-}
adjustContext :: (MonadIO m) => (Context -> Context) -> m ()
adjustContext f = update threadContextMap $ \mctx ->
  (pure $ f $ fromMaybe empty mctx, ())


{- | Alter the context

If there is not a context associated with the provided thread, the function will
be applied to an empty context and the result will be stored

 @since 0.0.1.0
-}
adjustContextOnThread :: (MonadIO m) => ThreadId -> (Context -> Context) -> m ()
adjustContextOnThread tid f = updateOnThread threadContextMap tid $ \mctx ->
  (pure $ f $ fromMaybe empty mctx, ())
