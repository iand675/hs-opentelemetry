{-# LANGUAGE BangPatterns #-}

{- |
Module      : OpenTelemetry.Context.ThreadLocal
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Thread-local context storage with token-based attach\/detach
Stability   : experimental

= Overview

Manages the implicit 'Context' that flows through your application. The
@inSpan@ functions automatically push\/pop context here, so you rarely
need to use this module directly.

= Common operations

@
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Context (insertBaggage, lookupSpan)

-- Read the current context (contains active span + baggage):
ctx <- getContext

-- Modify the current context (e.g. attach baggage):
adjustContext (insertBaggage myBaggage)

-- Attach context extracted from incoming headers:
tok <- attachContext extractedCtx
-- ... later ...
detachContext tok
@

= Token semantics

Per the OpenTelemetry specification, 'attachContext' returns an opaque 'Token'
that must be passed to 'detachContext' to restore the previous context. Tokens
enforce __LIFO ordering__: if you attach contexts A then B, you must detach B
before A. Detaching out of order logs a diagnostic error.

= When to use this module

* Reading the current span: @lookupSpan \<$\> getContext@
* Setting\/reading baggage on the current thread
* Manually attaching context after propagator extraction
* Implementing custom instrumentation middleware
-}
module OpenTelemetry.Context.ThreadLocal (
  -- * Thread-local context

  -- ** Opaque token (spec-mandated attach\/detach handle)
  Token,
  getContext,
  lookupContext,
  attachContext,
  detachContext,
  adjustContext,
  getAndAdjustContext,

  -- * Active baggage (implicit context)
  getActiveBaggage,
  setActiveBaggage,
  clearActiveBaggage,

  -- * Fused ref-based operations (zero CAS on hot path)

  --
  -- These operations use a per-thread IORef for direct reads and writes,
  -- eliminating all CAS contention from the span lifecycle hot path.
  ContextEntry (ceContext),
  emptyEntry,
  ensureContextRef,
  ensureContextRefFast,
  lookupContextRefFast,
  readContextRef,
  writeContextRef,

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
import Control.Monad (when)
import Control.Monad.IO.Class
import Data.IORef
import Data.Maybe (fromMaybe)
import Data.Word (Word64)
import OpenTelemetry.Baggage (Baggage)
import OpenTelemetry.Context (Context, empty, insertBaggage, lookupBaggage, removeBaggage)
import OpenTelemetry.Internal.Logging (otelLogError)
import System.IO.Unsafe
import Prelude hiding (lookup)


{- | Per-thread context entry: the context plus the active token ID.
A token ID of 0 means no token is active (initial state).
-}
data ContextEntry = ContextEntry
  { ceContext :: !Context
  , ceTokenId :: {-# UNPACK #-} !Word64
  }


emptyEntry :: ContextEntry
emptyEntry = ContextEntry empty 0
{-# INLINE emptyEntry #-}


{- | Opaque token returned by 'attachContext'.

Pass this to 'detachContext' to restore the context that was active before
the attach. The implementation validates LIFO ordering: detaching out of
order (i.e. with a token that doesn't match the most recent attach) logs
a diagnostic error per the OpenTelemetry specification.

Tokens are lightweight (three words) and do not hold resources that need
explicit cleanup. If a token is simply dropped without calling
'detachContext', nothing leaks — but you lose the LIFO validation for
that attach point.

@since 0.5.0.0
-}
data Token = Token
  { _tokenId :: {-# UNPACK #-} !Word64
  , _tokenPreviousContext :: !Context
  , _tokenPreviousTokenId :: {-# UNPACK #-} !Word64
  }


type ThreadContextMap = ThreadStorageMap ContextEntry


tokenCounter :: IORef Word64
tokenCounter = unsafePerformIO (newIORef 0)
{-# NOINLINE tokenCounter #-}


nextTokenId :: IO Word64
nextTokenId = atomicModifyIORef' tokenCounter (\n -> let !n' = n + 1 in (n', n'))
{-# INLINE nextTokenId #-}


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
getContext = do
  me <- lookup threadContextMap
  pure $! case me of
    Nothing -> empty
    Just entry -> ceContext entry
{-# INLINE getContext #-}


{- | Retrieve a stored 'Context' for the current thread, if it exists.

 @since 0.0.1.0
-}
lookupContext :: (MonadIO m) => m (Maybe Context)
lookupContext = fmap (fmap ceContext) (lookup threadContextMap)
{-# INLINE lookupContext #-}


{- | Retrieve a stored 'Context' for the provided 'ThreadId', if it exists.

 @since 0.0.1.0
-}
lookupContextOnThread :: (MonadIO m) => ThreadId -> m (Maybe Context)
lookupContextOnThread tid = fmap (fmap ceContext) (lookupOnThread threadContextMap tid)
{-# INLINE lookupContextOnThread #-}


{- | Attach a 'Context' to the current thread, returning an opaque 'Token'.

Pass the token to 'detachContext' to restore the previous context. Tokens
enforce LIFO ordering per the OpenTelemetry specification.

@since 0.5.0.0
-}
attachContext :: (MonadIO m) => Context -> m Token
attachContext newCtx = liftIO $ do
  tokId <- nextTokenId
  update threadContextMap $ \mentry ->
    let !old = fromMaybe emptyEntry mentry
        !tok = Token tokId (ceContext old) (ceTokenId old)
        !new = ContextEntry newCtx tokId
    in (Just new, tok)
{-# INLINE attachContext #-}


{- | Attach a 'Context' to the provided 'ThreadId', returning an opaque 'Token'.

@since 0.5.0.0
-}
attachContextOnThread :: (MonadIO m) => ThreadId -> Context -> m Token
attachContextOnThread tid newCtx = liftIO $ do
  tokId <- nextTokenId
  updateOnThread threadContextMap tid $ \mentry ->
    let !old = fromMaybe emptyEntry mentry
        !tok = Token tokId (ceContext old) (ceTokenId old)
        !new = ContextEntry newCtx tokId
    in (Just new, tok)
{-# INLINE attachContextOnThread #-}


{- | Restore the context that was active before the corresponding
'attachContext' call, using the provided 'Token'.

If the token does not match the most recently attached context on this
thread (LIFO violation), the implementation logs a diagnostic error per
the OpenTelemetry specification. The previous context is still restored
regardless.

@since 0.5.0.0
-}
detachContext :: (MonadIO m) => Token -> m ()
detachContext (Token expectedId prevCtx prevTokenId) = liftIO $ do
  mismatch <- update threadContextMap $ \mentry ->
    let !current = fromMaybe emptyEntry mentry
        !restored = ContextEntry prevCtx prevTokenId
    in (Just restored, ceTokenId current /= expectedId)
  when mismatch $
    otelLogError
      "Context detach token mismatch: LIFO ordering violated. \
      \This likely indicates a context leak — an attachContext call \
      \without a corresponding detachContext in the correct order."
{-# INLINE detachContext #-}


{- | Restore the context on the provided 'ThreadId' using the given 'Token'.

@since 0.5.0.0
-}
detachContextFromThread :: (MonadIO m) => ThreadId -> Token -> m ()
detachContextFromThread tid (Token expectedId prevCtx prevTokenId) = liftIO $ do
  mismatch <- updateOnThread threadContextMap tid $ \mentry ->
    let !current = fromMaybe emptyEntry mentry
        !restored = ContextEntry prevCtx prevTokenId
    in (Just restored, ceTokenId current /= expectedId)
  when mismatch $
    otelLogError
      "Context detach token mismatch on remote thread: LIFO ordering violated."
{-# INLINE detachContextFromThread #-}


{- | Alter the context on the current thread using the provided function.

If there is not a context associated with the current thread, the function will
be applied to an empty context and the result will be stored.

This does not affect the active token — it modifies the context in place.

 @since 0.0.1.0
-}
adjustContext :: (MonadIO m) => (Context -> Context) -> m ()
adjustContext f = update threadContextMap $ \mentry ->
  let !old = fromMaybe emptyEntry mentry
      !ctx' = f (ceContext old)
  in (Just (old {ceContext = ctx'}), ())
{-# INLINE adjustContext #-}


{- | Atomically read the current context and replace it via @f@ in a single
operation, returning the old context.

@since 0.4.0.0
-}
getAndAdjustContext :: (MonadIO m) => (Context -> Context) -> m Context
getAndAdjustContext f = update threadContextMap $ \mentry ->
  let !old = fromMaybe emptyEntry mentry
      !ctx = ceContext old
      !new = f ctx
  in (Just (old {ceContext = new}), ctx)
{-# INLINE getAndAdjustContext #-}


{- | Get or create the per-thread context IORef. On the first call per thread,
this inserts a new entry (flat-table CAS, once per thread lifetime). On all
subsequent calls the IORef is found via a single flat-table probe (no CAS).

Use 'readIORef' and 'writeIORef' on the returned 'IORef' for zero-overhead
context access on the hot path.

@since 0.5.0.0
-}
ensureContextRef :: ThreadId -> Int -> IO (IORef ContextEntry)
ensureContextRef tid tw = ensureRef threadContextMap tid tw emptyEntry
{-# INLINE ensureContextRef #-}


{- | Fused CMM fast path: reads @CurrentTSO.id@ and probes the flat table
entirely in CMM, returning the per-thread context IORef. No 'ThreadId'
allocation, no FFI call, no 'Maybe' wrapper on the steady-state path.

Returns @(threadId, contextRef)@. The thread ID is returned for reuse
as the @thread.id@ span attribute.

First call per thread: falls back to 'myThreadId' + insert (one CAS).

@since 0.5.0.0
-}
ensureContextRefFast :: IO (Int, IORef ContextEntry)
ensureContextRefFast = ensureRefFast threadContextMap emptyEntry
{-# INLINE ensureContextRefFast #-}


{- | Fused CMM probe: reads @CurrentTSO.id@ and probes the flat table
entirely in CMM. Returns @(threadId, Maybe (IORef ContextEntry))@.
The thread ID is returned for reuse on the slow path.

@since 0.5.0.0
-}
lookupContextRefFast :: IO (Int, Maybe (IORef ContextEntry))
lookupContextRefFast = lookupRefFast threadContextMap
{-# INLINE lookupContextRefFast #-}


{- | Read just the 'Context' from a per-thread IORef.

For the hot path where you need both the entry and the context, prefer
reading the 'IORef' directly and using 'ceContext'.

@since 0.5.0.0
-}
readContextRef :: IORef ContextEntry -> IO Context
readContextRef ref = ceContext <$> readIORef ref
{-# INLINE readContextRef #-}


{- | Write a 'Context' to a per-thread IORef, preserving the active token ID.
Only the owning thread should call this.

For the hot path (e.g. 'inSpanInternal'), prefer writing the full
'ContextEntry' via 'writeIORef' to avoid the read-modify-write.

@since 0.5.0.0
-}
writeContextRef :: IORef ContextEntry -> Context -> IO ()
writeContextRef ref ctx = modifyIORef' ref (\e -> e {ceContext = ctx})
{-# INLINE writeContextRef #-}


{- | Alter the context on the provided thread.

If there is not a context associated with the provided thread, the function will
be applied to an empty context and the result will be stored.

 @since 0.0.1.0
-}
adjustContextOnThread :: (MonadIO m) => ThreadId -> (Context -> Context) -> m ()
adjustContextOnThread tid f = updateOnThread threadContextMap tid $ \mentry ->
  let !old = fromMaybe emptyEntry mentry
      !ctx' = f (ceContext old)
  in (Just (old {ceContext = ctx'}), ())
{-# INLINE adjustContextOnThread #-}


{- | Get the currently active 'Baggage' from the implicit thread-local context.

@since 0.4.0.0
-}
getActiveBaggage :: (MonadIO m) => m (Maybe Baggage)
getActiveBaggage = lookupBaggage <$> getContext
{-# INLINE getActiveBaggage #-}


{- | Set the currently active 'Baggage' in the implicit thread-local context.

@since 0.4.0.0
-}
setActiveBaggage :: (MonadIO m) => Baggage -> m ()
setActiveBaggage b = adjustContext (insertBaggage b)
{-# INLINE setActiveBaggage #-}


{- | Clear the active 'Baggage' from the implicit thread-local context.

@since 0.4.0.0
-}
clearActiveBaggage :: (MonadIO m) => m ()
clearActiveBaggage = adjustContext removeBaggage
{-# INLINE clearActiveBaggage #-}
