{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.Wai 
  ( newOpenTelemetryWaiMiddleware
  , requestContext
  ) where

import Data.Maybe
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types
import Network.Wai
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Context.Propagators
import OpenTelemetry.Trace
import System.IO.Unsafe
import qualified Data.Text.Encoding as T
import qualified Data.Text as T
import OpenTelemetry.Resource
import Control.Monad

newOpenTelemetryWaiMiddleware 
  :: TracerProvider 
  -> Propagator Context.Context RequestHeaders ResponseHeaders
  -> IO Middleware
newOpenTelemetryWaiMiddleware tp propagator = do
  waiTracer <- getTracer 
    tp
    "opentelemetry-instrumentation-wai" 
    (TracerOptions Nothing)
  pure $ middleware waiTracer
  where
    middleware :: Tracer -> Middleware
    middleware tracer app req sendResp = do
      -- TODO baggage, span context
      ctxt <- extract propagator (requestHeaders req) Context.empty
      requestSpan <- createSpan tracer ctxt "warp.wai" $ emptySpanArguments
        { startingKind = Server
        }

      insertAttributes requestSpan
        [ ( "http.method", toAttribute $ T.decodeUtf8 $ requestMethod req)
        -- , ( "http.url",
        --     toAttribute $
        --     T.decodeUtf8
        --     ((if secure req then "https://" else "http://") <> host req <> ":" <> B.pack (show $ port req) <> path req <> queryString req)
        --   )
        , ( "http.target", toAttribute $ T.decodeUtf8 (rawPathInfo req <> rawQueryString req))
        -- , ( "http.host", toAttribute $ T.decodeUtf8 $ host req)
        -- , ( "http.scheme", toAttribute $ TextAttribute $ if secure req then "https" else "http")
        , ( "http.flavor"
          , toAttribute $ case httpVersion req of
              (HttpVersion major minor) -> T.pack (show major <> "." <> show minor)
          )
        , ( "http.user_agent"
          , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
          )
        ]

      -- TODO, don't like attaching and also putting it in the request vault, users can do
      -- this or it can be a separate middleware
      -- attachContext $ Context.insertSpan requestSpan ctxt
      let req' = req 
            { vault = Vault.insert 
                contextKey 
                (Context.insertSpan requestSpan ctxt) 
                (vault req) 
            }
      app req' $ \resp -> do
        ctxt' <- fromMaybe Context.empty <$> detachContext
        hs <- inject propagator (Context.insertSpan requestSpan ctxt') []
        -- injecting the span here, but is that actually useful??
        let resp' = mapResponseHeaders (hs ++) resp
        -- TODO need to propagate baggage
        insertAttributes requestSpan
          [ ( "http.status_code", toAttribute $ statusCode $ responseStatus resp)
          ]
        when (statusCode (responseStatus resp) >= 500) $ do
          setStatus requestSpan (Error "")
        respReceived <- sendResp resp'
        ts <- getTimestamp
        endSpan requestSpan (Just ts)
        pure respReceived

contextKey :: Vault.Key Context.Context
contextKey = unsafePerformIO Vault.newKey
{-# NOINLINE contextKey #-}

requestContext :: Request -> Maybe Context.Context
requestContext = 
  Vault.lookup contextKey . 
  vault