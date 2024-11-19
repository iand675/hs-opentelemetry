{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
[New HTTP semantic conventions have been declared stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "http" - to use the stable conventions
- "http/dup" - to emit both the old and the stable conventions
Otherwise, the old conventions will be used. The stable conventions will replace the old conventions in the next major release of this library.
-}
module OpenTelemetry.Instrumentation.Wai (
  newOpenTelemetryWaiMiddleware,
  newOpenTelemetryWaiMiddleware',
  requestContext,
) where

import Control.Exception (bracket)
import Control.Monad
import qualified Data.HashMap.Strict as H
import Data.IP (fromHostAddress, fromHostAddress6)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Vault.Lazy as Vault
import GHC.Stack (HasCallStack)
import Network.HTTP.Types
import Network.Socket
import Network.Wai
import OpenTelemetry.Attributes (lookupAttribute)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Propagator
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core
import System.IO.Unsafe


newOpenTelemetryWaiMiddleware :: (HasCallStack) => IO Middleware
newOpenTelemetryWaiMiddleware = newOpenTelemetryWaiMiddleware' <$> getGlobalTracerProvider


newOpenTelemetryWaiMiddleware'
  :: (HasCallStack)
  => TracerProvider
  -> Middleware
newOpenTelemetryWaiMiddleware' tp =
  let waiTracer =
        makeTracer
          tp
          $detectInstrumentationLibrary
          (TracerOptions Nothing)
  in middleware waiTracer
  where
    usefulCallsite = callerAttributes
    middleware :: Tracer -> Middleware
    middleware tracer app req sendResp = do
      let propagator = getTracerProviderPropagators $ getTracerTracerProvider tracer
      let parentContextM = do
            ctx <- getContext
            ctxt <- extract propagator (requestHeaders req) ctx
            attachContext ctxt
      let path_ = T.decodeUtf8 $ rawPathInfo req
      -- peer = remoteHost req

      semanticsOptions <- getSemanticsOptions
      let args =
            defaultSpanArguments
              { kind = Server
              , attributes =
                  case httpOption semanticsOptions of
                    Stable ->
                      usefulCallsite
                        `H.union` [
                                    ( "user_agent.original"
                                    , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
                                    )
                                  ]
                    StableAndOld ->
                      usefulCallsite
                        `H.union` [
                                    ( "user_agent.original"
                                    , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
                                    )
                                  ]
                    Old -> usefulCallsite
              }
      -- The cleanup action in this bracket is used to prevent propagated
      -- context from being inherited by any subsequent requests served by the
      -- same thread. Warp supports HTTP keep-alive/persistent connections,
      -- which means a thread can handle multiple requests before exiting.
      bracket parentContextM (const $ void detachContext) $ \_ -> inSpan'' tracer path_ args $ \requestSpan -> do
        ctxt <- getContext

        let addStableAttributes = do
              addAttributes
                requestSpan
                [ ("http.request.method", toAttribute $ T.decodeUtf8 $ requestMethod req)
                , -- , ( "url.full",
                  --     toAttribute $
                  --     T.decodeUtf8
                  --     ((if secure req then "https://" else "http://") <> host req <> ":" <> B.pack (show $ port req) <> path req <> queryString req)
                  --   )
                  ("url.path", toAttribute $ T.decodeUtf8 $ rawPathInfo req)
                , ("url.query", toAttribute $ T.decodeUtf8 $ rawQueryString req)
                , -- , ( "http.host", toAttribute $ T.decodeUtf8 $ host req)
                  -- , ( "url.scheme", toAttribute $ TextAttribute $ if secure req then "https" else "http")

                  ( "network.protocol.version"
                  , toAttribute $ case httpVersion req of
                      (HttpVersion major minor) ->
                        T.pack $
                          if minor == 0
                            then show major
                            else show major <> "." <> show minor
                  )
                , -- TODO HTTP/3 will require detecting this dynamically
                  ("net.transport", toAttribute ("ip_tcp" :: T.Text))
                ]

              addAttributes requestSpan $ case remoteHost req of
                SockAddrInet port addr ->
                  [ ("server.port", toAttribute (fromIntegral port :: Int))
                  , ("server.address", toAttribute $ T.pack $ show $ fromHostAddress addr)
                  ]
                SockAddrInet6 port _ addr _ ->
                  [ ("server.port", toAttribute (fromIntegral port :: Int))
                  , ("server.address", toAttribute $ T.pack $ show $ fromHostAddress6 addr)
                  ]
                SockAddrUnix path ->
                  [ ("server.address", toAttribute $ T.pack path)
                  ]
            addOldAttributes = do
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

        case httpOption semanticsOptions of
          Stable -> addStableAttributes
          StableAndOld -> addOldAttributes >> addStableAttributes
          Old -> addOldAttributes

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

          case httpOption semanticsOptions of
            Stable ->
              addAttributes
                requestSpan
                [ ("http.response.status_code", toAttribute $ statusCode $ responseStatus resp)
                ]
            StableAndOld ->
              addAttributes
                requestSpan
                [ ("http.response.status_code", toAttribute $ statusCode $ responseStatus resp)
                , ("http.status_code", toAttribute $ statusCode $ responseStatus resp)
                ]
            Old ->
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
