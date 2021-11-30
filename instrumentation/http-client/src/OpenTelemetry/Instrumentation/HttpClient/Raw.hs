{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.HttpClient.Raw where
import Control.Monad.IO.Class
import OpenTelemetry.Context (Context, lookupSpan)
import OpenTelemetry.Trace.Core
import OpenTelemetry.Propagator
import Network.HTTP.Client
import Network.HTTP.Types
import Control.Monad (forM_, when)
import qualified Data.ByteString.Char8 as B
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Data.Foldable (Foldable(toList))
import Data.CaseInsensitive (foldedCase)

data HttpClientInstrumentationConfig = HttpClientInstrumentationConfig
  { requestHeadersToRecord :: [HeaderName]
  , responseHeadersToRecord :: [HeaderName]
  }

instance Semigroup HttpClientInstrumentationConfig where
  l <> r = HttpClientInstrumentationConfig
    { requestHeadersToRecord = requestHeadersToRecord l <> requestHeadersToRecord r
    , responseHeadersToRecord = responseHeadersToRecord l <> responseHeadersToRecord r
    }

instance Monoid HttpClientInstrumentationConfig where
  mempty = HttpClientInstrumentationConfig
    { requestHeadersToRecord = mempty
    , responseHeadersToRecord = mempty
    }

httpClientInstrumentationConfig :: HttpClientInstrumentationConfig
httpClientInstrumentationConfig = mempty

  -- TODO see if we can avoid recreating this on each request without being more invasive with the interface
httpTracerProvider :: MonadIO m => m Tracer
httpTracerProvider = do
  tp <- getGlobalTracerProvider
  getTracer tp "hs-opentelemetry-instrumentation-http-client" tracerOptions

instrumentRequest
  :: MonadIO m
  => HttpClientInstrumentationConfig
  -> Context
  -> Request
  -> m Request
instrumentRequest conf ctxt req = do
  tp <- httpTracerProvider
  forM_ (lookupSpan ctxt) $ \s -> do
    addAttributes s
      [ ( "http.method", toAttribute $ T.decodeUtf8 $ method req)
      , ( "http.url",
          toAttribute $
          T.decodeUtf8
          ((if secure req then "https://" else "http://") <> host req <> ":" <> B.pack (show $ port req) <> path req <> queryString req)
        )
      , ( "http.target", toAttribute $ T.decodeUtf8 (path req <> queryString req))
      , ( "http.host", toAttribute $ T.decodeUtf8 $ host req)
      , ( "http.scheme", toAttribute $ TextAttribute $ if secure req then "https" else "http")
      , ( "http.flavor"
        , toAttribute $ case requestVersion req of
            (HttpVersion major minor) -> T.pack (show major <> "." <> show minor)
        )
      , ( "http.user_agent"
        , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
        )
      ]
    addAttributes s $
      concatMap
        (\h -> toList $ (\v -> ("http.request.header." <> T.decodeUtf8 (foldedCase h), toAttribute (T.decodeUtf8 v))) <$> lookup h (requestHeaders req)) $
        requestHeadersToRecord conf

  hdrs <- inject (getTracerProviderPropagators $ getTracerTracerProvider tp) ctxt $ requestHeaders req
  pure $ req
    { requestHeaders = hdrs
    }


instrumentResponse
  :: MonadIO m
  => HttpClientInstrumentationConfig
  -> Context
  -> Response a
  -> m Context
instrumentResponse conf ctxt resp = do
  tp <- httpTracerProvider
  ctxt' <- extract (getTracerProviderPropagators $ getTracerTracerProvider tp) (responseHeaders resp) ctxt
  forM_ (lookupSpan ctxt') $ \s -> do
    when (statusCode (responseStatus resp) >= 400) $ do
      setStatus s (Error "")
    addAttributes s
      [ ("http.status_code", toAttribute $ statusCode $ responseStatus resp)
      -- TODO
      -- , ("http.request_content_length",	_)
      -- , ("http.request_content_length_uncompressed",	_)
      -- , ("http.response_content_length", _)
      -- , ("http.response_content_length_uncompressed", _)
      -- , ("net.transport")
      -- , ("net.peer.name")
      -- , ("net.peer.ip")
      -- , ("net.peer.port")
      ]
    addAttributes s $
      concatMap
        (\h -> toList $ (\v -> ("http.response.header." <> T.decodeUtf8 (foldedCase h), toAttribute (T.decodeUtf8 v))) <$> lookup h (responseHeaders resp)) $
        responseHeadersToRecord conf
  pure ctxt'
