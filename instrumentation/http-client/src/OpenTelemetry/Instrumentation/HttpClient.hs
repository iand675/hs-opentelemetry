{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- | Offer a few options for HTTP instrumentation

- Add attributes via 'Request' and 'Response' to an existing span (Best)
- Use internals to instrument a particular callsite using modifyRequest, modifyResponse (Next best)
- Provide a middleware to pull from the thread-local state (okay)
- Modify the global manager to pull from the thread-local state (least good, can't be helped sometimes)

[New HTTP semantic conventions have been declared stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "http" - to use the stable conventions
- "http/dup" - to emit both the old and the stable conventions
Otherwise, the old conventions will be used. The stable conventions will replace the old conventions in the next major release of this library.
-}
module OpenTelemetry.Instrumentation.HttpClient (
  appendModifierToSettings,
) where

import Control.Exception (assert)
import Control.Monad ((>=>))
import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.Bifunctor (bimap)
import qualified Data.CaseInsensitive as CI
import Data.Foldable (fold)
import Data.Function ((&))
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Data.Int (Int64)
import Data.Monoid (Endo (Endo, appEndo))
import qualified Data.TLS.GHC as TLS
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import GHC.Stack (HasCallStack, withFrozenCallStack)
import qualified Network.HTTP.Client as Orig
import qualified Network.HTTP.Types.Status as HT
import qualified OpenTelemetry.Attributes.Map as Otel
import qualified OpenTelemetry.Context.ThreadLocal as Otel
import qualified OpenTelemetry.Propagator as Otel
import qualified OpenTelemetry.SemanticConventions as Otel
import qualified OpenTelemetry.Trace.Core as Otel


appendModifierToSettings :: (MonadIO m, HasCallStack) => Otel.TracerProvider -> Orig.ManagerSettings -> m Orig.ManagerSettings
appendModifierToSettings tracerProvider settings = withFrozenCallStack $ liftIO $ do
  let
    tracer =
      Otel.makeTracer
        tracerProvider
        $Otel.detectInstrumentationLibrary
        Otel.tracerOptions
    managerModifyRequest = Orig.managerModifyRequest settings
    managerModifyResponse = Orig.managerModifyResponse settings
  tls <- makeThreadLocalStorage
  pure
    settings
      { Orig.managerModifyRequest = requestModifier tracer tls >=> managerModifyRequest
      , Orig.managerModifyResponse = managerModifyResponse >=> responseModifier tls
      }


type ThreadLocalStorage = TLS.TLS (IORef (Maybe Otel.Span))


requestModifier :: HasCallStack => Otel.Tracer -> ThreadLocalStorage -> Orig.Request -> IO Orig.Request
requestModifier tracer tls request = do
  spanRef <- TLS.getTLS tls
  maybeSpan <- readIORef spanRef
  case maybeSpan of
    Nothing -> do
      context <- Otel.getContext
      let attributes = makeRequestAttributes request `H.union` Otel.callerAttributes
      span_ <- Otel.createSpan tracer context "request" Otel.defaultSpanArguments {Otel.kind = Otel.Client, Otel.attributes}
      writeIORef spanRef $ Just span_
      let propagator = Otel.getTracerProviderPropagators $ Otel.getTracerTracerProvider tracer
      headers <- Otel.injector propagator context $ Orig.requestHeaders request
      pure request {Orig.requestHeaders = headers}
    Just _ -> pure request


responseModifier :: HasCallStack => ThreadLocalStorage -> Orig.Response Orig.BodyReader -> IO (Orig.Response Orig.BodyReader)
responseModifier tls response = do
  spanRef <- TLS.getTLS tls
  maybeSpan <- readIORef spanRef
  case maybeSpan of
    Just span_ -> do
      Otel.addAttributes span_ $ makeResponseAttributes response
      Otel.endSpan span_ Nothing
      writeIORef spanRef Nothing
    Nothing -> assert False $ pure () -- something went wrong
  pure response


makeThreadLocalStorage :: IO ThreadLocalStorage
makeThreadLocalStorage = TLS.mkTLS $ newIORef Nothing


makeRequestAttributes :: Orig.Request -> Otel.AttributeMap
makeRequestAttributes request =
  let
    requestHeaders =
      bimap
        (Text.decodeLatin1 . CI.foldedCase)
        ((Text.dropAround (== ' ') <$>) . Text.split (== ',') . Text.decodeLatin1)
        <$> Orig.requestHeaders request
    methodOriginal = Text.decodeLatin1 $ Orig.method request
    method :: Text
    method =
      case CI.foldCase methodOriginal of
        "get" -> "GET"
        "head" -> "HEAD"
        "post" -> "POST"
        "put" -> "PUT"
        "delete" -> "DELETE"
        "connect" -> "CONNECT"
        "options" -> "OPTIONS"
        "trace" -> "TRACE"
        "patch" -> "PATCH"
        _ -> "_OTHER"
    resendCount :: Int64
    resendCount = fromIntegral $ Orig.redirectCount request
    address = Text.decodeLatin1 $ Orig.host request
    port :: Int64
    port = fromIntegral $ Orig.port request
    url = Text.pack $ show $ Orig.getUri request
  in
    mempty
      -- HTTP attributes
      -- attributes to dismiss: error.type, http.request.body.size, http.response.body.size, network.protocol.version
      & appEndo (fold $ Endo . (\(k, v) -> Otel.insertByKey (Otel.http_request_header k) v) <$> requestHeaders)
      & Otel.insertByKey Otel.http_request_method method
      & Otel.insertByKey Otel.http_request_methodOriginal methodOriginal
      & Otel.insertByKey Otel.http_request_resendCount resendCount
      & Otel.insertByKey Otel.network_peer_address address
      & Otel.insertByKey Otel.network_peer_port port
      & Otel.insertByKey Otel.network_protocol_name "http"
      & Otel.insertByKey Otel.network_transport "tcp"
      & Otel.insertByKey Otel.server_address address
      & Otel.insertByKey Otel.server_port port
      & Otel.insertByKey Otel.url_full url


makeResponseAttributes :: Orig.Response a -> Otel.AttributeMap
makeResponseAttributes response =
  let
    responseHeaders =
      bimap
        (Text.decodeLatin1 . CI.foldedCase)
        ((Text.dropAround (== ' ') <$>) . Text.split (== ',') . Text.decodeLatin1)
        <$> Orig.responseHeaders response
    statusCode :: Int64
    statusCode = fromIntegral $ HT.statusCode $ Orig.responseStatus response
  in
    mempty
      & appEndo (fold $ Endo . (\(k, v) -> Otel.insertByKey (Otel.http_response_header k) v) <$> responseHeaders)
      & Otel.insertByKey Otel.http_response_statusCode statusCode
