{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      :  OpenTelemetry.Trace.Monad
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Monadic tracing API
Stability   :  experimental

= Overview

Higher-level tracing interface that obtains the 'Tracer' from your monad
stack via 'MonadTracer', eliminating the need to pass it explicitly.

= Quick example

@
data App = App { appTracer :: Tracer }

instance MonadTracer (ReaderT App IO) where
  getTracer = asks appTracer

handleRequest :: (MonadUnliftIO m, MonadTracer m) => Request -> m Response
handleRequest req = inSpan "handleRequest" defaultSpanArguments $ do
  user <- inSpan "lookupUser" defaultSpanArguments $ lookupUser req
  inSpan "buildResponse" defaultSpanArguments $ buildResponse user
@

= Variants

* 'inSpan' : simple wrapper, no span access in callback
* 'OpenTelemetry.Trace.Monad.inSpan'' : passes the 'Span' to the callback for adding attributes
* 'OpenTelemetry.Trace.Monad.inSpan''' : raw variant, no automatic source-location capture

All variants automatically end the span and record exceptions, just like
their counterparts in "OpenTelemetry.Trace.Core".

= When to use this vs Trace.Core

Use this module when your application has a monad stack with a 'Tracer'
in the environment. Use "OpenTelemetry.Trace.Core" when you have the
'Tracer' as an explicit argument or need lower-level control.
-}
module OpenTelemetry.Trace.Monad (
  inSpan,
  inSpan',
  OpenTelemetry.Trace.Monad.inSpan'',
  -- Interacting with the span in the current context
  -- , getSpan
  -- , updateName
  -- , addAttribute
  -- , addAttributes
  -- , getAttributeMap
  -- , addEvent
  -- , NewEvent (..)
  -- Fundamental monad instances
  MonadTracer (..),
) where

import Control.Monad.IO.Unlift
import Control.Monad.Trans.Class (MonadTrans (lift))
import Control.Monad.Trans.Identity (IdentityT)
import Control.Monad.Trans.Reader (ReaderT)
import Data.Text (Text)
import GHC.Stack
import OpenTelemetry.Trace.Core (
  Span,
  SpanArguments (..),
  Tracer,
  addAttributesToSpanArguments,
  callerAttributes,
  inSpan'',
 )


{- | This is generally scoped by Monad stack to do different things

@since 0.0.1.0
-}
class (Monad m) => MonadTracer m where
  getTracer :: m Tracer


-- | @since 0.0.1.0
inSpan
  :: (MonadUnliftIO m, MonadTracer m, HasCallStack)
  => Text
  -> SpanArguments
  -> m a
  -> m a
inSpan n args m = OpenTelemetry.Trace.Monad.inSpan'' n (addAttributesToSpanArguments callerAttributes args) (const m)


-- | @since 0.0.1.0
inSpan'
  :: (MonadUnliftIO m, MonadTracer m, HasCallStack)
  => Text
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan' n args f = OpenTelemetry.Trace.Monad.inSpan'' n (addAttributesToSpanArguments callerAttributes args) f


-- | @since 0.4.0.0
inSpan''
  :: (MonadUnliftIO m, MonadTracer m, HasCallStack)
  => Text
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan'' n args f = do
  t <- getTracer
  OpenTelemetry.Trace.Core.inSpan'' t n args f


instance (MonadTracer m) => MonadTracer (IdentityT m) where
  getTracer = lift getTracer


instance {-# OVERLAPPABLE #-} (MonadTracer m) => MonadTracer (ReaderT r m) where
  getTracer = lift getTracer
