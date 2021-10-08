{-# LANGUAGE OverloadedStrings #-}
{- | Offer a few options for HTTP instrumentation

- Add attributes via 'Request' and 'Response' to an existing span (Best)
- Use internals to instrument a particular callsite using modifyRequest, modifyResponse (Next best)
- Provide a middleware to pull from the thread-local state (okay)
- Modify the global manager to pull from the thread-local state (least good, can't be helped sometimes)
-}
module OpenTelemetry.Instrumentation.HttpClient where
import Control.Monad.IO.Class
import OpenTelemetry.Context (Context, lookupSpan)
import OpenTelemetry.Context.Propagators
import OpenTelemetry.Trace
import Network.HTTP.Client
import Network.HTTP.Types
import Control.Monad (forM_)
import qualified Data.ByteString.Char8 as B
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import OpenTelemetry.Resource
-- TODO, Manager really needs proper hooks for this.

instrumentRequest
  :: MonadIO m
  => Propagator Context RequestHeaders ResponseHeaders
  -> Context
  -> Request
  -> m Request
instrumentRequest p ctxt req = do
  forM_ (lookupSpan ctxt) $ \s -> do
    insertAttributes s
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

  hdrs <- inject p ctxt $ requestHeaders req
  pure $ req
    { requestHeaders = hdrs
    }


instrumentResponse
  :: MonadIO m
  => Propagator Context RequestHeaders ResponseHeaders
  -> Context
  -> Response a
  -> m Context
instrumentResponse p ctxt resp = do
  ctxt <- extract p (responseHeaders resp) ctxt
  forM_ (lookupSpan ctxt) $ \s -> do
    insertAttributes s
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
      --, ("http.user_agent", _)
      -- Must be configured by user
      -- , ("http.request.header.<key>", _)
      -- , ("http.response.header.<key>", _)
      ]
  pure ctxt
