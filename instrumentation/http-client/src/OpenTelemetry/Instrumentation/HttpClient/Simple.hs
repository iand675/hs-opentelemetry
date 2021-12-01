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
import OpenTelemetry.Trace.Core hiding (inSpan, inSpan', inSpan'')
import OpenTelemetry.Trace.Monad
import OpenTelemetry.Instrumentation.HttpClient.Raw
import qualified OpenTelemetry.Instrumentation.Conduit as Conduit
import UnliftIO
import Data.Aeson (FromJSON)
import Conduit (MonadResource, lift)

spanArgs :: SpanArguments
spanArgs = defaultSpanArguments { kind = Client }

httpBS :: (MonadUnliftIO m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response B.ByteString)
httpBS httpConf req = inSpan' "httpBS" spanArgs $ \_s -> do
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpBS req'
  _ <- instrumentResponse httpConf ctxt resp
  pure resp

httpLBS :: (MonadUnliftIO m,MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response L.ByteString)
httpLBS httpConf req = inSpan' "httpLBS" spanArgs $ \_s -> do
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpLBS req'
  _ <- instrumentResponse httpConf ctxt resp
  pure resp

httpNoBody :: (MonadUnliftIO m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response ())
httpNoBody httpConf req = inSpan' "httpNoBody" spanArgs $ \_s -> do
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpNoBody req'
  _ <- instrumentResponse httpConf ctxt resp
  pure resp

httpJSON :: (MonadUnliftIO m, MonadTracer m, FromJSON a) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response a)
httpJSON httpConf req = inSpan' "httpJSON" spanArgs $ \_s -> do
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpJSON req'
  _ <- instrumentResponse httpConf ctxt resp
  pure resp

httpJSONEither :: (FromJSON a, MonadUnliftIO m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response (Either Simple.JSONException a))
httpJSONEither httpConf req = inSpan' "httpJSONEither" spanArgs $ \_s -> do
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpJSONEither req'
  _ <- instrumentResponse httpConf ctxt resp
  pure resp

httpSink :: (MonadTracer m, MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response () -> ConduitM B.ByteString Void m a) -> m a
httpSink httpConf req f = inSpan' "httpSink" spanArgs $ \_s -> do 
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  Simple.httpSink req' $ \resp -> do
    _ <- instrumentResponse httpConf ctxt resp
    f resp

httpSource :: (MonadTracer m, MonadUnliftIO m, MonadResource m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> ConduitM i o m r) -> ConduitM i o m r
httpSource httpConf req f = Conduit.inSpan "httpSource" spanArgs $ \_s -> do
  ctxt <- lift getContext
  req' <- instrumentRequest httpConf ctxt req
  Simple.httpSource req' $ \resp -> do
    _ <- instrumentResponse httpConf ctxt resp
    f resp

withResponse :: ( MonadTracer m, MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> m a) -> m a
withResponse httpConf req f = inSpan' "withResponse" spanArgs $ \_s -> do
  ctxt <- getContext
  req' <- instrumentRequest httpConf ctxt req
  Simple.withResponse req' $ \resp -> do
    _ <- instrumentResponse httpConf ctxt resp
    f resp