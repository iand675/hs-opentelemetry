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
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Monad
import OpenTelemetry.Instrumentation.HttpClient.Raw
import qualified OpenTelemetry.Instrumentation.Conduit as Conduit
import UnliftIO
import Data.Aeson (FromJSON)
import Conduit (MonadResource(..), lift)

spanArgs :: CreateSpanArguments
spanArgs = emptySpanArguments { startingKind = Client }

httpBS :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response B.ByteString)
httpBS httpConf req = inSpan "httpBS" spanArgs $ \s -> do
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpBS req
  instrumentResponse httpConf ctxt resp
  pure resp

httpLBS :: (MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response L.ByteString)
httpLBS httpConf req = inSpan "httpLBS" spanArgs $ \s -> do
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpLBS req
  instrumentResponse httpConf ctxt resp
  pure resp

httpNoBody :: (MonadUnliftIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response ())
httpNoBody httpConf req = inSpan "httpNoBody" spanArgs $ \s -> do
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpNoBody req
  instrumentResponse httpConf ctxt resp
  pure resp

httpJSON :: (MonadGetContext m, MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m, FromJSON a) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response a)
httpJSON httpConf req = inSpan "httpJSON" spanArgs $ \s -> do
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpJSON req
  instrumentResponse httpConf ctxt resp
  pure resp

httpJSONEither :: (FromJSON a, MonadIO m, MonadBracketError m, MonadLocalContext m, MonadTracer m) => HttpClientInstrumentationConfig -> Simple.Request -> m (Simple.Response (Either Simple.JSONException a))
httpJSONEither httpConf req = inSpan "httpJSONEither" spanArgs $ \s -> do
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  resp <- Simple.httpJSONEither req
  instrumentResponse httpConf ctxt resp
  pure resp

httpSink :: (MonadBracketError m, MonadLocalContext m, MonadTracer m, MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response () -> ConduitM B.ByteString Void m a) -> m a
httpSink httpConf req f = inSpan "httpSink" spanArgs $ \s -> do 
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  Simple.httpSink req $ \resp -> do
    instrumentResponse httpConf ctxt resp
    f resp

httpSource :: (MonadLocalContext m, MonadTracer m, MonadUnliftIO m, MonadResource m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> ConduitM i o m r) -> ConduitM i o m r
httpSource httpConf req f = Conduit.inSpan "httpSource" spanArgs $ \s -> do
  ctxt <- lift getContext
  req <- instrumentRequest httpConf ctxt req
  Simple.httpSource req $ \resp -> do
    instrumentResponse httpConf ctxt resp
    f resp

withResponse :: (MonadBracketError m, MonadLocalContext m, MonadTracer m, MonadUnliftIO m) => HttpClientInstrumentationConfig -> Simple.Request -> (Simple.Response (ConduitM i B.ByteString m ()) -> m a) -> m a
withResponse httpConf req f = inSpan "withResponse" spanArgs $ \s -> do
  ctxt <- getContext
  req <- instrumentRequest httpConf ctxt req
  Simple.withResponse req $ \resp -> do
    _ <- instrumentResponse httpConf ctxt resp
    f resp