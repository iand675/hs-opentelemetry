{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.Yesod where

import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Trace
import OpenTelemetry.Instrumentation.Wai
import Yesod.Core

openTelemetryYesodMiddleware 
  :: ToTypedContent res 
  => HandlerFor site res
  -> HandlerFor site res
openTelemetryYesodMiddleware m = do
  -- TODO, get TracerProvider from Handler instead of global one.
  tracerProvider <- getGlobalTracerProvider
  tracer <- getTracer tracerProvider "otel-instrumentation-yesod" tracerOptions
  -- TODO, better handle case where wai middleware isn't installed.
  req <- waiRequest
  let mctxt = requestContext req
  requestSpan <- createSpan tracer mctxt "yesod.handler" $ emptySpanArguments
    { startingKind = maybe Server (const Internal) mctxt
    }
  r <- m
  endSpan requestSpan Nothing
  pure r