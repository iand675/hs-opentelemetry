{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.Conduit
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Trace conduit pipeline stages as spans
Stability   : experimental

= Overview

Wraps individual conduit pipeline stages in trace spans so you can see
how time is spent across your streaming pipeline. Use 'inSpan' to run a
sub-pipeline under a span; exceptions are recorded on the span and rethrown.

= Quick example

@
import Conduit
import Data.ByteString (ByteString)
import OpenTelemetry.Instrumentation.Conduit (inSpan)
import OpenTelemetry.Trace.Core (defaultSpanArguments)

myPipeline :: Tracer -> ConduitT ByteString Void IO ()
myPipeline tracer =
  sourceFile "input.csv"
    .| inSpan tracer "parse" defaultSpanArguments (\_ -> mapC parseRow)
    .| inSpan tracer "transform" defaultSpanArguments (\_ -> mapC transformRow)
    .| sinkFile "output.json"
@
-}
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
