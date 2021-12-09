{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.HttpClient.Simple 
  ( httpBS
  , httpLBS
  , httpNoBody
  , httpJSON
  , httpJSONEither
  , httpSink
  , httpSource
  , withResponse
  , httpClientInstrumentationConfig
  , HttpClientInstrumentationConfig(..)
  , module X
  ) where
import qualified Network.HTTP.Simple as Simple
import Network.HTTP.Simple as X hiding (httpBS, httpLBS, httpNoBody, httpJSON, httpJSONEither, httpSink, httpSource, withResponse)
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Data.Conduit (ConduitM, Void)
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Trace.Core
import OpenTelemetry.Instrumentation.HttpClient.Raw
import qualified OpenTelemetry.Instrumentation.Conduit as Conduit
import UnliftIO
import Data.Aeson (FromJSON)
import Conduit (MonadResource, lift)

spanArgs :: SpanArguments
spanArgs = defaultSpanArguments { kind = Client }

httpBS :: (MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response B.ByteString)
httpBS httpConf req = do
  t <- httpTracerProvider
  inSpan' t "httpBS" spanArgs $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpBS req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp

httpLBS :: (MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response L.ByteString)
httpLBS httpConf req = do
  t <- httpTracerProvider
  inSpan' t "httpLBS" spanArgs $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpLBS req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp

httpNoBody :: (MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response ())
httpNoBody httpConf req = do
  t <- httpTracerProvider
  inSpan' t "httpNoBody" spanArgs $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpNoBody req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp

httpJSON :: (MonadUnliftIO m, FromJSON a) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response a)
httpJSON httpConf req = do
  t <- httpTracerProvider
  inSpan' t "httpJSON" spanArgs $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpJSON req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp

httpJSONEither :: (FromJSON a, MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response (Either Simple.JSONException a))
httpJSONEither httpConf req = do
  t <- httpTracerProvider
  inSpan' t "httpJSONEither" spanArgs $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- Simple.httpJSONEither req'
    _ <- instrumentResponse httpConf ctxt resp
    pure resp

httpSink :: (MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response () -> ConduitM B.ByteString Void m a) -> m a
httpSink httpConf req f = do
  t <- httpTracerProvider
  inSpan' t "httpSink" spanArgs $ \_s -> do 
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    Simple.httpSink req' $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      f resp

httpSource :: (MonadUnliftIO m, MonadResource m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> ConduitM i o m r) -> ConduitM i o m r
httpSource httpConf req f = do
  t <- httpTracerProvider
  Conduit.inSpan t "httpSource" spanArgs $ \_s -> do
    ctxt <- lift getContext
    req' <- instrumentRequest httpConf ctxt req
    Simple.httpSource req' $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      f resp

withResponse :: (MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> m a) -> m a
withResponse httpConf req f = do
  t <- httpTracerProvider
  inSpan' t "withResponse" spanArgs $ \_s -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    Simple.withResponse req' $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      f resp