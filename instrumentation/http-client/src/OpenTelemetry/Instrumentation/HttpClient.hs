{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.HttpClient
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Automatic tracing for http-client requests
Stability   : experimental

= Overview

Instruments outbound HTTP requests made with the @http-client@ library.
Creates a @Client@ span for each request and injects trace context into
request headers so downstream services can continue the trace.

= Quick example

The usual approach is to build a 'Manager' with traced settings once; spans
use the tracer from 'OpenTelemetry.Instrumentation.HttpClient.Raw.httpTracerProvider'
(typically the global tracer provider):

@
import Network.HTTP.Client.TLS (tlsManagerSettings)
import OpenTelemetry.Instrumentation.HttpClient
  ( httpLbs
  , httpClientInstrumentationConfig
  , newTracedManager
  )

main :: IO ()
main = do
  manager <- newTracedManager httpClientInstrumentationConfig tlsManagerSettings
  response <- httpLbs request manager
  ...
@

For custom manager settings, apply 'OpenTelemetry.Instrumentation.HttpClient.Raw.instrumentManagerSettings'
before @newManager@. You can also use 'tracedHttpRequest' or the prime-suffixed
variants (e.g. 'httpLbs'') for per-call configuration; see the export list below.

= What gets traced

Each outbound request creates a @Client@ span with:

* Span name: @METHOD host@ (e.g. @GET api.example.com@)
* @http.request.method@, @url.full@, @server.address@, @server.port@
* @http.response.status_code@, @http.response.body.size@
* Trace context injected into request headers via the global propagator

[HTTP semantic conventions migration:](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan)
opt in via @OTEL_SEMCONV_STABILITY_OPT_IN@ (@http@, @http/dup@, or default legacy).
-}
module OpenTelemetry.Instrumentation.HttpClient (
  -- * Manager-level instrumentation (recommended)
  instrumentManagerSettings,
  newTracedManager,
  httpClientPropagateHeaders,

  -- * Per-request combinator
  tracedHttpRequest,

  -- * Drop-in replacements (zero-config)
  withResponse,
  httpLbs,
  httpNoBody,
  responseOpen,

  -- * Drop-in replacements (with config)
  withResponse',
  httpLbs',
  httpNoBody',
  responseOpen',

  -- * Configuration
  httpClientInstrumentationConfig,
  HttpClientInstrumentationConfig (..),

  -- * Re-exports
  module X,
) where

import Control.Monad.IO.Class (MonadIO (..))
import qualified Data.ByteString.Lazy as L
import GHC.Stack
import Network.HTTP.Client as X hiding (httpLbs, httpNoBody, responseOpen, withResponse)
import qualified Network.HTTP.Client as Client
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Instrumentation.HttpClient.Raw (
  HttpClientInstrumentationConfig (..),
  httpClientInstrumentationConfig,
  httpClientPropagateHeaders,
  httpTracerProvider,
  instrumentManagerSettings,
  instrumentRequest,
  instrumentResponse,
  newTracedManager,
  tracedHttpRequest,
 )
import OpenTelemetry.Trace.Core (
  SpanArguments (kind),
  SpanKind (Client),
  addAttributesToSpanArguments,
  callerAttributes,
  defaultSpanArguments,
  inSpan'',
 )
import UnliftIO (MonadUnliftIO, askRunInIO)


spanArgs :: SpanArguments
spanArgs = defaultSpanArguments {kind = Client}


{- | 'withResponse' with default instrumentation config.

@since 0.2.0.0
-}
withResponse
  :: (MonadUnliftIO m, HasCallStack)
  => Client.Request
  -> Client.Manager
  -> (Client.Response Client.BodyReader -> m a)
  -> m a
withResponse = withResponse' mempty


{- | 'httpLbs' with default instrumentation config.

@since 0.2.0.0
-}
httpLbs
  :: (MonadUnliftIO m, HasCallStack)
  => Client.Request
  -> Client.Manager
  -> m (Client.Response L.ByteString)
httpLbs = httpLbs' mempty


{- | 'httpNoBody' with default instrumentation config.

@since 0.2.0.0
-}
httpNoBody
  :: (MonadUnliftIO m, HasCallStack)
  => Client.Request
  -> Client.Manager
  -> m (Client.Response ())
httpNoBody = httpNoBody' mempty


{- | 'responseOpen' with default instrumentation config.

@since 0.2.0.0
-}
responseOpen
  :: (MonadUnliftIO m, HasCallStack)
  => Client.Request
  -> Client.Manager
  -> m (Client.Response Client.BodyReader)
responseOpen = responseOpen' mempty


{- | Instrumented 'Client.withResponse' with explicit config.

@since 0.2.0.0
-}
withResponse'
  :: (MonadUnliftIO m, HasCallStack)
  => HttpClientInstrumentationConfig
  -> Client.Request
  -> Client.Manager
  -> (Client.Response Client.BodyReader -> m a)
  -> m a
withResponse' httpConf req man f = do
  tracer <- httpTracerProvider
  inSpan'' tracer "withResponse" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_wrSpan -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    runInIO <- askRunInIO
    liftIO $ Client.withResponse req' man $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      runInIO $ f resp


{- | Instrumented 'Client.httpLbs' with explicit config.

@since 0.2.0.0
-}
httpLbs'
  :: (MonadUnliftIO m, HasCallStack)
  => HttpClientInstrumentationConfig
  -> Client.Request
  -> Client.Manager
  -> m (Client.Response L.ByteString)
httpLbs' httpConf req man = do
  tracer <- httpTracerProvider
  inSpan'' tracer "httpLbs" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_ -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- liftIO $ Client.httpLbs req' man
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


{- | Instrumented 'Client.httpNoBody' with explicit config.

@since 0.2.0.0
-}
httpNoBody'
  :: (MonadUnliftIO m, HasCallStack)
  => HttpClientInstrumentationConfig
  -> Client.Request
  -> Client.Manager
  -> m (Client.Response ())
httpNoBody' httpConf req man = do
  tracer <- httpTracerProvider
  inSpan'' tracer "httpNoBody" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_ -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- liftIO $ Client.httpNoBody req' man
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


{- | Instrumented 'Client.responseOpen' with explicit config.

@since 0.2.0.0
-}
responseOpen'
  :: (MonadUnliftIO m, HasCallStack)
  => HttpClientInstrumentationConfig
  -> Client.Request
  -> Client.Manager
  -> m (Client.Response Client.BodyReader)
responseOpen' httpConf req man = do
  tracer <- httpTracerProvider
  inSpan'' tracer "responseOpen" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_ -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- liftIO $ Client.responseOpen req' man
    _ <- instrumentResponse httpConf ctxt resp
    pure resp
