{-# LANGUAGE OverloadedStrings #-}

{- | OpenTelemetry instrumentation for @http-client@.

== Recommended: Manager-level instrumentation

The easiest approach — instrument the 'Manager' once and all requests
through it are automatically traced, including requests from third-party
libraries:

@
import Network.HTTP.Client.TLS (tlsManagerSettings)
import OpenTelemetry.Instrumentation.HttpClient.Raw
  ('instrumentManagerSettings', 'httpClientInstrumentationConfig')

manager <- 'newTracedManager' 'httpClientInstrumentationConfig' tlsManagerSettings
-- Every request through this manager now creates a client span
-- with HTTP attributes and propagation headers.
resp <- Client.httpLbs req manager
@

== Alternative: per-request combinator

If you can't control 'Manager' creation, wrap individual calls:

@
resp <- 'tracedHttpRequest' 'httpClientInstrumentationConfig' req $ \\req' ->
  Client.httpLbs req' manager
@

== Alternative: drop-in replacement functions

These create a span per call and are backward-compatible with the
pre-0.2 API:

@
resp <- 'httpLbs' req manager              -- uses default config
resp <- 'httpLbs'' myConfig req manager    -- custom config
@

== Propagation-only mode

If you manage spans yourself (e.g., via @inSpan@) but want propagation
headers injected automatically:

@
settings <- 'httpClientPropagateHeaders' tlsManagerSettings
manager <- newManager settings
@

[HTTP semantic conventions are stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in via @OTEL_SEMCONV_STABILITY_OPT_IN@:

- @\"http\"@ — stable conventions only
- @\"http\/dup\"@ — emit both stable and old
- (default) — old conventions only
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
