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
  , inSpan'
  , defaultSpanArguments
  , SpanArguments(..)
  , SpanKind(..)
  , Link (..)
  -- Interacting with the span in the current context
  -- , getSpan
  -- , updateName
  -- , addAttribute
  -- , addAttributes
  -- , getAttributes
  -- , addEvent
  -- , NewEvent (..)
  -- Fundamental monad instances
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
  , defaultSpanArguments, whenSpanIsRecording, addAttributes, ToAttribute (toAttribute)
  )
import Control.Monad.Reader (ReaderT, forM_)
import Control.Concurrent (myThreadId)
import OpenTelemetry.Util (getThreadId)
import GHC.Stack
import qualified Data.Text as T

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

inSpan
  :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m, HasCallStack)
  => Text
  -> SpanArguments
  -> m a
  -> m a
inSpan n args m = inSpan'' callStack n args (const m)

inSpan'
  :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m, HasCallStack)
  => Text
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan' = inSpan'' callStack

inSpan''
  :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m, HasCallStack)
  => CallStack
  -> Text
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan'' cs n args f = do
  t <- getTracer
  ctx <- getContext
  bracketError
    (liftIO $ createSpan t ctx n args)
    (\e s -> liftIO $ do
      whenSpanIsRecording s $ do
        tid <- myThreadId
        addAttributes s
          [ ("thread.id", toAttribute $ getThreadId tid)
          ]
        case getCallStack cs of
          [] -> pure ()
          (fn, loc):_ -> do
            addAttributes s
              [ ("code.function", toAttribute $ T.pack fn)
              , ("code.namespace", toAttribute $ T.pack $ srcLocModule loc)
              , ("code.filepath", toAttribute $ T.pack $ srcLocFile loc)
              , ("code.lineno", toAttribute $ srcLocStartLine loc)
              , ("code.package", toAttribute $ T.pack $ srcLocPackage loc)
              ]
      forM_ e $ \(SomeException inner) -> do
        setStatus s $ Error $ pack $ displayException inner
        recordException s [] Nothing inner
      -- TODO, getting the timestamp is a bit of overhead that would be nice to avoid
      endSpan s Nothing
    )
    (\s -> localContext (insertSpan s) $ f s)

-- getSpan :: MonadGetContext m => m (Maybe Span)
-- getSpan = lookupSpan <$> getContext

-- updateName :: (MonadGetContext m) => Text -> m ()
-- updateName = _

-- addAttribute :: (MonadGetContext m, ToAttribute attr) => Text -> attr -> m ()
-- addAttribute = _

-- addAttributes :: (MonadGetContext m) => [(Text, Attribute)] -> m ()
-- addAttributes = _

-- askAttributes :: (MonadGetContext m) => m [(Text, Attribute)]
-- askAttributes = _

-- setStatus :: (MonadGetContext m) => SpanStatus -> m ()
-- setStatus = _

-- addEvent :: (MonadGetContext m) => NewEvent -> m ()
-- addEvent = _
