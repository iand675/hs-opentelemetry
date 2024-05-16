{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Instrumentation.HttpClient.Simple (
  httpBS,
  httpLBS,
  httpNoBody,
  httpJSON,
  httpJSONEither,
  httpSink,
  httpSource,
  withResponse,
  httpClientInstrumentationConfig,
  HttpClientInstrumentationConfig (..),
  module X,
) where

import Conduit (MonadResource, lift)
import Data.Aeson (FromJSON)
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Data.Conduit (ConduitM, Void)
import GHC.Stack
import Network.HTTP.Simple as X hiding (httpBS, httpJSON, httpJSONEither, httpLBS, httpNoBody, httpSink, httpSource, withResponse)
import qualified Network.HTTP.Simple as Simple
import OpenTelemetry.Context.ThreadLocal
import qualified OpenTelemetry.Instrumentation.Conduit as Conduit
import OpenTelemetry.Instrumentation.HttpClient.Raw
import OpenTelemetry.Trace.Core
import UnliftIO


spanArgs :: SpanArguments
spanArgs = defaultSpanArguments {kind = Client}


httpBS :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response B.ByteString)
httpBS httpConf req = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "httpBS" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpBS req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


httpLBS :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response L.ByteString)
httpLBS httpConf req = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "httpLBS" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpLBS req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


httpNoBody :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response ())
httpNoBody httpConf req = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "httpNoBody" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpNoBody req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


httpJSON :: (MonadUnliftIO m, FromJSON a, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response a)
httpJSON httpConf req = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "httpJSON" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpJSON req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


httpJSONEither :: (FromJSON a, MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response (Either Simple.JSONException a))
httpJSONEither httpConf req = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "httpJSONEither" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpJSONEither req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


httpSink :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response () -> ConduitM B.ByteString Void m a) -> m a
httpSink httpConf req f = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "httpSink" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    Simple.httpSink req' $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      f resp


httpSource :: (MonadUnliftIO m, MonadResource m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> ConduitM i o m r) -> ConduitM i o m r
httpSource httpConf req f = do
  HttpTracer {..} <- httpTracerProvider
  Conduit.inSpan tracer "httpSource" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- lift getContext
    req' <- instrumentRequest httpConf ctxt req
    Simple.httpSource req' $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      f resp


withResponse :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> m a) -> m a
withResponse httpConf req f = do
  HttpTracer {..} <- httpTracerProvider
  inSpan' tracer "withResponse" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    Simple.withResponse req' $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      f resp
