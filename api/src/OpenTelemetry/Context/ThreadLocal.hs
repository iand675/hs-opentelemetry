{-# LANGUAGE MagicHash #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE UnliftedFFITypes #-}
-- | A perilous implementation of thread-local storage for Haskell.
-- This module uses a fair amount of GHC internals to enable performing
-- lookups of context for any threads that are alive. Caution should be
-- taken for consumers of this module to not retain ThreadId references
-- indefinitely, as that could delay cleanup of thread-local state.
--
-- Thread-local contexts have the following semantics:
--
-- - A value 'attach'ed to a 'ThreadId' will remain alive at least as long
--   as the 'ThreadId'. 
-- - A value may be detached from a 'ThreadId' via 'detach' by the
--   library consumer without detriment.
-- - No guarantees are made about when a value will be garbage-collected
--   once all references to 'ThreadId' have been dropped. However, this simply
--   means in practice that any unused contexts will cleaned up upon the next
--   garbage collection and may not be actively freed when the program exits.
--
-- Note that this implementation of context sharing is
-- mildly expensive for the garbage collector, hard to reason about without deep
-- knowledge of the code you are instrumenting, and has limited guarantees of behavior 
-- across GHC versions due to internals usage.
--
-- Why use this implementation, then? Depending on the structure of libraries
-- that you are attempting to instrument, this may be the only way to smuggle
-- a 'Context' in without significant breaking changes to the existing library
-- interface.
--
-- The rule of thumb:
-- - Where possible, use OpenTelemetry.Context.Class
-- - When all else fails, use this instead.
module OpenTelemetry.Context.ThreadLocal 
  ( 
  -- $ Thread-local context
    lookupContext
  , attachContext
  , detachContext
  , adjustContext
  -- $$ Generalized thread-local context functions
  , lookupContextOnThread
  , attachContextOnThread
  , detachContextFromThread
  , adjustContextOnThread
  ) where
import OpenTelemetry.Context.Types (Context)
import Control.Concurrent
import Control.Concurrent.Async
import Control.Concurrent.Thread.Storage
import Control.Monad.IO.Class
import Control.Monad
import System.IO.Unsafe
import Prelude hiding (lookup)

type ThreadContextMap = ThreadStorageMap Context

threadContextMap :: ThreadContextMap
threadContextMap = unsafePerformIO newThreadStorageMap
{-# NOINLINE threadContextMap #-}

lookupContext :: MonadIO m => m (Maybe Context)
lookupContext = lookup threadContextMap

lookupContextOnThread :: MonadIO m => ThreadId -> m (Maybe Context)
lookupContextOnThread = lookupOnThread threadContextMap

attachContext :: MonadIO m => Context -> m (Maybe Context)
attachContext = attach threadContextMap

attachContextOnThread :: MonadIO m => ThreadId -> Context -> m (Maybe Context)
attachContextOnThread = attachOnThread threadContextMap

detachContext :: MonadIO m => m (Maybe Context)
detachContext = detach threadContextMap

detachContextFromThread :: MonadIO m => ThreadId -> m (Maybe Context)
detachContextFromThread = detachFromThread threadContextMap

adjustContext :: MonadIO m => (Context -> Context) -> m ()
adjustContext = adjust threadContextMap

adjustContextOnThread :: MonadIO m => ThreadId -> (Context -> Context) -> m ()
adjustContextOnThread = adjustOnThread threadContextMap

