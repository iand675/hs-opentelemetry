{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DefaultSignatures #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Trace.Monad
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Higher-level tracing API
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- The recommended tracing interface for application developers
--
-- See OpenTelemetry.Trace for an interface that's
-- more lower-level, but more flexible.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Trace.Monad 
  ( inSpan
  , defaultSpanArguments
  , SpanArguments(..)
  , SpanKind(..)
  , Link (..)
  , MonadLocalContext(..)
  , MonadGetContext(..)
  , MonadBracketError(..)
  , bracketErrorUnliftIO
  , MonadTracer(..)
  ) where

import Control.Exception (SomeException(..), Exception (displayException))
import qualified Control.Exception as EUnsafe
import Control.Monad.IO.Unlift
import Data.Text (Text, pack)
import OpenTelemetry.Context (Context, insertSpan)
import OpenTelemetry.Trace
  ( Tracer
  , Span
  , SpanStatus(Error)
  , SpanKind(..)
  , SpanArguments(..)
  , Link (..)
  , createSpan
  , endSpan
  , recordException
  , setStatus
  , defaultSpanArguments
  )
import Control.Monad.Reader (ReaderT, forM_)
import GHC.Stack.Types (HasCallStack)

-- | This is generally scoped by Monad stack to do different things
class Monad m => MonadTracer m where
  getTracer :: m Tracer

-- | Get the current OpenTelemetry 'Context'.
--
-- This type class is distinct from 'MonadLocalContext' to accomodate
-- cases where `getContext` needs to be called from a non-reader-like
-- 'Monad' instance.
class Monad m => MonadGetContext m where
  -- | Get the current OpenTelemetry 'Context'.
  --
  -- @since 0.1.0.0
  getContext :: m Context

class MonadGetContext m => MonadLocalContext m where
  localContext :: (Context -> Context) -> m a -> m a

class Monad m => MonadBracketError m where
  bracketError :: m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
  default bracketError :: MonadUnliftIO m => m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
  bracketError = bracketErrorUnliftIO

instance MonadBracketError IO where
instance MonadUnliftIO m => MonadBracketError (ReaderT r m) where

-- | The standard implementation of 'bracketError'
--
-- @since 0.1.0.0
bracketErrorUnliftIO :: MonadUnliftIO m => m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
bracketErrorUnliftIO before after thing = withRunInIO $ \run -> EUnsafe.mask $ \restore -> do
  x <- run before
  res1 <- EUnsafe.try $ restore $ run $ thing x
  case res1 of
    Left (e1 :: SomeException) -> do
      -- explicitly ignore exceptions from after. We know that
      -- no async exceptions were thrown there, so therefore
      -- the stronger exception must come from thing
      --
      -- https://github.com/fpco/safe-exceptions/issues/2
      _ :: Either SomeException b <-
          EUnsafe.try $ EUnsafe.uninterruptibleMask_ $ run $ after (Just e1) x
      EUnsafe.throwIO e1
    Right y -> do
      _ <- EUnsafe.uninterruptibleMask_ $ run $ after Nothing x
      return y

-- | The primary convenience
inSpan 
  :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m, HasCallStack) 
  => Text 
  -> SpanArguments 
  -> (Span -> m a) 
  -> m a
inSpan n args f = do 
  t <- getTracer
  ctx <- getContext
  bracketError 
    (liftIO $ createSpan t ctx n args)
    (\e s -> liftIO $ do
      forM_ e $ \(SomeException inner) -> do
        setStatus s $ Error $ pack $ displayException inner
        recordException s [] Nothing inner
      -- TODO, getting the timestamp is a bit of overhead that would be nice to avoid
      endSpan s Nothing
    )
    (\s -> localContext (insertSpan s) $ f s)
