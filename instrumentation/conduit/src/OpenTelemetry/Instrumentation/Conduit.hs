{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Instrumentation.Conduit where

import Conduit
import Control.Exception (SomeException, throwIO)
import Data.Text (Text)
import GHC.Stack (HasCallStack)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Context.ThreadLocal
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace.Core hiding (getTracer)


inSpan
  :: (MonadResource m, MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -> SpanArguments
  -> (Span -> ConduitM i o m a)
  -> ConduitM i o m a
inSpan t n args f = do
  ctx <- lift getContext
  bracketP
    (createSpanWithoutCallStack t ctx n $ addAttributesToSpanArguments callerAttributes args)
    (`endSpan` Nothing)
    $ \span_ -> do
      catchC (f span_) $ \e -> do
        liftIO $ do
          recordException span_ [(unkey SC.exception_escaped, toAttribute True)] Nothing (e :: SomeException)
          throwIO e
