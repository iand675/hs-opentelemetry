{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
module OpenTelemetry.Trace.Monad where

import Control.Exception (Exception(..), SomeException(..))
import qualified Control.Exception as EUnsafe
import Control.Monad.IO.Unlift
import Data.Text (Text)
import Lens.Micro
import OpenTelemetry.Context (Context, lookupSpan)
import OpenTelemetry.Trace 
  ( TracerProvider
  , Tracer
  , Span
  , CreateSpanArguments(..)
  , createSpan
  , endSpan
  , recordException
  )

-- | This is a type class rather than coded against MonadIO because
-- we need the ability to specialize behaviour against things like
-- persistent's @ReaderT SqlBackend@ stack.
class MonadTracerProvider m where
  getTracerProvider :: m TracerProvider

-- | This is generally scoped by Monad stack to do different things
class MonadTracer m where
  getTracer :: m Tracer

class MonadGetContext m where
  getContext :: m Context

class MonadGetContext m => MonadLocalContext m where
  localContext :: (Context -> Context) -> m a -> m a

class MonadBracketError m where
  bracketError :: m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c

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
  :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m) 
  => Text 
  -> CreateSpanArguments 
  -> (Span -> m a) 
  -> m a
inSpan n args f = do 
  t <- getTracer
  ctx <- getContext
  bracketError 
    (liftIO $ createSpan t (Just ctx) n args)
    (\e s -> liftIO $ do
      mapM_ (recordException s) e
      -- TODO, getting the timestamp is a bit of overhead that would be nice to avoid
      endSpan s Nothing
    )
    f
