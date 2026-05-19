{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      : OpenTelemetry.Instrumentation.Wai
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : WAI middleware for automatic HTTP server tracing
Stability   : experimental

= Overview

Middleware that automatically creates a span for every incoming HTTP request
handled by a WAI application. Extracts trace context from request headers
(via the global propagator) so that spans are properly linked to upstream
callers.

= Quick example

@
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  otelMiddleware <- newOpenTelemetryWaiMiddleware
  run 8080 $ otelMiddleware myApp
@

The example imports 'OpenTelemetry.Trace.withTracerProvider' from
@hs-opentelemetry-sdk@ (this package depends only on the API).

= What gets traced

Each request creates a @Server@ span with:

* Span name derived from the HTTP method and route
* @http.request.method@, @url.path@, @url.scheme@, @http.response.status_code@
* @server.address@, @server.port@ when available
* @user_agent.original@ from the User-Agent header
* Span status set to Error for 5xx responses

= Configuration

Use 'newOpenTelemetryWaiMiddleware'' with a specific 'TracerProvider' when
you cannot rely on the process-global tracer provider.

[HTTP semantic conventions migration:](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan)
set @OTEL_SEMCONV_STABILITY_OPT_IN@ to @http@ for stable names only, @http/dup@
for stable and legacy, or leave unset for legacy-only (until the next major
release of this library).
-}
module OpenTelemetry.Instrumentation.Wai (
  newOpenTelemetryWaiMiddleware,
  newOpenTelemetryWaiMiddleware',
  requestContext,
) where

import Control.Exception (bracket)
import Control.Monad
import qualified Data.CaseInsensitive as CI
import qualified Data.HashMap.Strict as H
import Data.IP (fromHostAddress, fromHostAddress6)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import qualified Data.Vault.Lazy as Vault
import GHC.Stack (HasCallStack)
import Network.HTTP.Types
import Network.Socket
import Network.Wai
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Propagator (emptyTextMap, extract, getGlobalTextMapPropagator, inject, textMapFromList, textMapToList)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core
import System.IO.Unsafe
import Text.Read (readMaybe)


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
          tracerOptions
  in middleware waiTracer
  where
    usefulCallsite = callerAttributes
    middleware :: Tracer -> Middleware
    middleware tracer app req sendResp = do
      propagator <- getGlobalTextMapPropagator
      let parentContextM = do
            ctx <- getContext
            let tm = textMapFromList $ map (\(k, v) -> (T.decodeUtf8 (CI.foldedCase k), T.decodeUtf8 v)) (requestHeaders req)
            ctxt <- extract propagator tm ctx
            attachContext ctxt
      let method_ = T.decodeUtf8 $ requestMethod req
          spanName_ = method_

      semanticsOptions <- getSemanticsOptions
      let args =
            defaultSpanArguments
              { kind = Server
              , attributes =
                  case httpOption semanticsOptions of
                    Stable ->
                      usefulCallsite
                        `H.union` [
                                    ( unkey SC.userAgent_original
                                    , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
                                    )
                                  ]
                    StableAndOld ->
                      usefulCallsite
                        `H.union` [
                                    ( unkey SC.userAgent_original
                                    , toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req)
                                    )
                                  ]
                    Old -> usefulCallsite
              }
      -- The cleanup action in this bracket is used to prevent propagated
      -- context from being inherited by any subsequent requests served by the
      -- same thread. Warp supports HTTP keep-alive/persistent connections,
      -- which means a thread can handle multiple requests before exiting.
      bracket parentContextM detachContext $ \_ -> inSpan'' tracer spanName_ args $ \requestSpan -> do
        ctxt <- getContext

        let addStableAttributes = do
              let hostAttrs = case lookup "Host" $ requestHeaders req of
                    Nothing -> []
                    Just hostHeader ->
                      let hostText = T.decodeUtf8 hostHeader
                          (hostName, portSuffix) = T.breakOn ":" hostText
                          portAttr = case T.stripPrefix ":" portSuffix of
                            Just portStr | not (T.null portStr) ->
                              case readMaybe (T.unpack portStr) :: Maybe Int of
                                Just p -> [(unkey SC.server_port, toAttribute p)]
                                Nothing -> [(unkey SC.server_port, toAttribute (if isSecure req then 443 :: Int else 80))]
                            _ -> [(unkey SC.server_port, toAttribute (if isSecure req then 443 :: Int else 80))]
                      in (unkey SC.server_address, toAttribute hostName) : portAttr
                  clientAttrs = case remoteHost req of
                    SockAddrInet port addr ->
                      [ (unkey SC.client_port, toAttribute (fromIntegral port :: Int))
                      , (unkey SC.client_address, toAttribute $ T.pack $ show $ fromHostAddress addr)
                      ]
                    SockAddrInet6 port _ addr _ ->
                      [ (unkey SC.client_port, toAttribute (fromIntegral port :: Int))
                      , (unkey SC.client_address, toAttribute $ T.pack $ show $ fromHostAddress6 addr)
                      ]
                    SockAddrUnix path ->
                      [ (unkey SC.client_address, toAttribute $ T.pack path)
                      ]
              addAttributes requestSpan $
                H.fromList $
                  [ (unkey SC.http_request_method, toAttribute method_)
                  , (unkey SC.url_path, toAttribute $ T.decodeUtf8 $ rawPathInfo req)
                  , (unkey SC.url_query, toAttribute $ T.decodeUtf8 $ rawQueryString req)
                  , (unkey SC.url_scheme, toAttribute (if isSecure req then "https" :: T.Text else "http"))
                  ,
                    ( unkey SC.network_protocol_version
                    , toAttribute $ case httpVersion req of
                        (HttpVersion major minor) ->
                          T.pack $
                            if minor == 0
                              then show major
                              else show major <> "." <> show minor
                    )
                  ]
                    <> hostAttrs
                    <> clientAttrs
            addOldAttributes = do
              let peerAttrs = case remoteHost req of
                    SockAddrInet port addr ->
                      [ (unkey SC.net_peer_port, toAttribute (fromIntegral port :: Int))
                      , (unkey SC.net_peer_ip, toAttribute $ T.pack $ show $ fromHostAddress addr)
                      ]
                    SockAddrInet6 port _ addr _ ->
                      [ (unkey SC.net_peer_port, toAttribute (fromIntegral port :: Int))
                      , (unkey SC.net_peer_ip, toAttribute $ T.pack $ show $ fromHostAddress6 addr)
                      ]
                    SockAddrUnix path ->
                      [ (unkey SC.net_peer_name, toAttribute $ T.pack path)
                      ]
              addAttributes requestSpan $
                H.fromList $
                  [ (unkey SC.http_method, toAttribute $ T.decodeUtf8 $ requestMethod req)
                  , (unkey SC.http_target, toAttribute $ T.decodeUtf8 (rawPathInfo req <> rawQueryString req))
                  , (unkey SC.http_flavor, toAttribute $ httpVersionText (httpVersion req))
                  , (unkey SC.http_userAgent, toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req))
                  , (unkey SC.net_transport, toAttribute ("ip_tcp" :: T.Text))
                  ]
                    <> peerAttrs

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
          tm <- inject propagator (Context.insertSpan requestSpan ctxt') emptyTextMap
          let hs = map (\(k, v) -> (CI.mk (T.encodeUtf8 k), T.encodeUtf8 v)) (textMapToList tm)
          let resp' = mapResponseHeaders (hs ++) resp
          attrs <- spanGetAttributes requestSpan
          forM_ (lookupAttribute attrs (unkey SC.http_route)) $ \case
            AttributeValue (TextAttribute route) -> updateName requestSpan (method_ <> " " <> route)
            _ -> pure ()

          let sc = statusCode (responseStatus resp)
              errorAttrs
                | sc >= 500 = [(unkey SC.error_type, toAttribute (T.pack $ show sc))]
                | otherwise = []
          case httpOption semanticsOptions of
            Stable ->
              addAttributes requestSpan $
                H.fromList $
                  (unkey SC.http_response_statusCode, toAttribute sc)
                    : errorAttrs
            StableAndOld ->
              addAttributes requestSpan $
                H.fromList $
                  [ (unkey SC.http_response_statusCode, toAttribute sc)
                  , (unkey SC.http_statusCode, toAttribute sc)
                  ]
                    <> errorAttrs
            Old ->
              addAttributes requestSpan $
                H.fromList $
                  (unkey SC.http_statusCode, toAttribute sc)
                    : errorAttrs
          when (sc >= 500) $
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


httpVersionText :: HttpVersion -> T.Text
httpVersionText (HttpVersion major minor) =
  TL.toStrict $ toLazyText $ decimal major <> "." <> decimal minor
