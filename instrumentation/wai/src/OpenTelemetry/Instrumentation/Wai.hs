{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Instrumentation.Wai (
  newOpenTelemetryWaiMiddleware,
  newOpenTelemetryWaiMiddleware',
  requestContext,
) where

import Control.Exception (bracket)
import Control.Monad
import Data.IP (fromHostAddress, fromHostAddress6)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types
import Network.Socket
import Network.Wai
import OpenTelemetry.Attributes (lookupAttribute)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Propagator
import OpenTelemetry.Trace.Core
import System.IO.Unsafe


newOpenTelemetryWaiMiddleware :: IO Middleware
newOpenTelemetryWaiMiddleware = getGlobalTracerProvider >>= newOpenTelemetryWaiMiddleware'


newOpenTelemetryWaiMiddleware'
  :: TracerProvider
  -> IO Middleware
newOpenTelemetryWaiMiddleware' tp = do
  let waiTracer =
        makeTracer
          tp
          "opentelemetry-instrumentation-wai"
          (TracerOptions Nothing)
  pure $ middleware waiTracer
  where
    middleware :: Tracer -> Middleware
    middleware tracer app req sendResp = do
      let propagator = getTracerProviderPropagators $ getTracerTracerProvider tracer
      let parentContextM = do
            ctx <- getContext
            ctxt <- extract propagator (requestHeaders req) ctx
            attachContext ctxt
      let path_ = T.decodeUtf8 $ rawPathInfo req
      -- peer = remoteHost req
      parentContextM
      inSpan' tracer path_ (defaultSpanArguments {kind = Server}) $ \requestSpan -> do
        ctxt <- getContext
        addAttributes
          requestSpan
          [ ("http.method", toAttribute $ T.decodeUtf8 $ requestMethod req)
          , -- , ( "http.url",
            --     toAttribute $
            --     T.decodeUtf8
            --     ((if secure req then "https://" else "http://") <> host req <> ":" <> B.pack (show $ port req) <> path req <> queryString req)
            --   )
            ("http.target", toAttribute $ T.decodeUtf8 (rawPathInfo req <> rawQueryString req))
          , -- , ( "http.host", toAttribute $ T.decodeUtf8 $ host req)
            -- , ( "http.scheme", toAttribute $ TextAttribute $ if secure req then "https" else "http")

            ( "http.flavor"
            , toAttribute $ case httpVersion req of
                (HttpVersion major minor) -> T.pack (show major <> "." <> show minor)
            )
          ,
            ( "http.user_agent"
            , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
            )
          , -- TODO HTTP/3 will require detecting this dynamically
            ("net.transport", toAttribute ("ip_tcp" :: T.Text))
          ]

        -- TODO this is warp dependent, probably.
        -- , ( "net.host.ip")
        -- , ( "net.host.port")
        -- , ( "net.host.name")
        addAttributes requestSpan $ case remoteHost req of
          SockAddrInet port addr ->
            [ ("net.peer.port", toAttribute (fromIntegral port :: Int))
            , ("net.peer.ip", toAttribute $ T.pack $ show $ fromHostAddress addr)
            ]
          SockAddrInet6 port _ addr _ ->
            [ ("net.peer.port", toAttribute (fromIntegral port :: Int))
            , ("net.peer.ip", toAttribute $ T.pack $ show $ fromHostAddress6 addr)
            ]
          SockAddrUnix path ->
            [ ("net.peer.name", toAttribute $ T.pack path)
            ]
        let req' =
              req
                { vault =
                    Vault.insert
                      contextKey
                      ctxt
                      (vault req)
                }
        app req' $ \resp -> do
          ctxt' <- getContext
          hs <- inject propagator (Context.insertSpan requestSpan ctxt') []
          let resp' = mapResponseHeaders (hs ++) resp
          attrs <- spanGetAttributes requestSpan
          forM_ (lookupAttribute attrs "http.route") $ \case
            AttributeValue (TextAttribute route) -> updateName requestSpan route
            _ -> pure ()

          addAttributes
            requestSpan
            [ ("http.status_code", toAttribute $ statusCode $ responseStatus resp)
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
  Vault.lookup contextKey
    . vault
