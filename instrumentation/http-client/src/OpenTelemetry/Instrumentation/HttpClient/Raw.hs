{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      : OpenTelemetry.Instrumentation.HttpClient.Raw
Description : Low-level HTTP client instrumentation.
Stability   : experimental

Provides raw request/response hooks for creating spans around HTTP calls.
-}
module OpenTelemetry.Instrumentation.HttpClient.Raw (
  -- * Manager-level instrumentation
  instrumentManagerSettings,
  newTracedManager,
  httpClientPropagateHeaders,

  -- * Per-request combinator
  tracedHttpRequest,

  -- * Low-level building blocks
  instrumentRequest,
  instrumentResponse,
  instrumentResponseOnSpan,

  -- * Configuration
  HttpClientInstrumentationConfig (..),
  httpClientInstrumentationConfig,

  -- * Metrics
  HttpClientMetrics (..),
  createHttpClientMetrics,
  createHttpClientMetricsFromMeter,

  -- * Internal
  httpTracerProvider,
  httpVersionText,
) where

import Control.Applicative ((<|>))
import Control.Exception (SomeException, catch, throwIO)
import Control.Monad (forM_, when)
import Control.Monad.IO.Class
import qualified Data.ByteString.Char8 as B
import Data.CaseInsensitive (foldedCase)
import qualified Data.CaseInsensitive as CI
import qualified Data.HashMap.Strict as H
import Data.Int (Int64)
import Data.Maybe
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Typeable (tyConName, typeOf, typeRepTyCon)
import Data.Word (Word64)
import Network.HTTP.Client
import Network.HTTP.Types
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Context (insertSpan, lookupSpan)
import qualified OpenTelemetry.Context as Ctx
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Metric.Core
import OpenTelemetry.Propagator (TextMap, TextMapPropagator, extract, getGlobalTextMapPropagator, inject, textMapFromList, textMapToList)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core
import System.IO.Unsafe (unsafePerformIO)


data HttpClientInstrumentationConfig = HttpClientInstrumentationConfig
  { requestName :: Maybe T.Text
  , requestHeadersToRecord :: [HeaderName]
  , responseHeadersToRecord :: [HeaderName]
  , httpClientMetrics :: Maybe HttpClientMetrics
  }


instance Semigroup HttpClientInstrumentationConfig where
  l <> r =
    HttpClientInstrumentationConfig
      { requestName = requestName r <|> requestName l
      , requestHeadersToRecord = requestHeadersToRecord l <> requestHeadersToRecord r
      , responseHeadersToRecord = responseHeadersToRecord l <> responseHeadersToRecord r
      , httpClientMetrics = httpClientMetrics r <|> httpClientMetrics l
      }


instance Monoid HttpClientInstrumentationConfig where
  mempty =
    HttpClientInstrumentationConfig
      { requestName = Nothing
      , requestHeadersToRecord = mempty
      , responseHeadersToRecord = mempty
      , httpClientMetrics = Nothing
      }


httpClientInstrumentationConfig :: HttpClientInstrumentationConfig
httpClientInstrumentationConfig = mempty


-- Context key for the span created by Manager-level hooks, so we can
-- retrieve "our" span in managerModifyResponse without confusing it with
-- a caller's span.
managedSpanKey :: Ctx.Key Span
managedSpanKey = unsafePerformIO $ Ctx.newKey "http-client.managed-span"
{-# NOINLINE managedSpanKey #-}


-- Context key to stash the attach token so we can restore context
-- after managerModifyResponse completes.
parentTokenKey :: Ctx.Key Token
parentTokenKey = unsafePerformIO $ Ctx.newKey "http-client.parent-token"
{-# NOINLINE parentTokenKey #-}


metricStartKey :: Ctx.Key (Word64, Request)
metricStartKey = unsafePerformIO $ Ctx.newKey "http-client.metric-start"
{-# NOINLINE metricStartKey #-}


httpTracerProvider :: (MonadIO m) => m Tracer
httpTracerProvider = do
  tp <- getGlobalTracerProvider
  pure $ makeTracer tp $detectInstrumentationLibrary tracerOptions


data HttpClientMetrics = HttpClientMetrics
  { hcmDuration :: !Histogram
  , hcmActive :: !(UpDownCounter Int64)
  , hcmCount :: !(Counter Int64)
  }


createHttpClientMetrics :: IO HttpClientMetrics
createHttpClientMetrics = do
  mp <- getGlobalMeterProvider
  meter <- getMeter mp "hs-opentelemetry-instrumentation-http-client"
  createHttpClientMetricsFromMeter meter


createHttpClientMetricsFromMeter :: Meter -> IO HttpClientMetrics
createHttpClientMetricsFromMeter meter = do
  dur <-
    meterCreateHistogram
      meter
      "http.client.request.duration"
      (Just "s")
      (Just "Duration of outbound HTTP requests")
      defaultAdvisoryParameters
        { advisoryExplicitBucketBoundaries =
            Just [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0]
        }
  active <- meterCreateUpDownCounterInt64 meter "http.client.active_requests" (Just "{request}") (Just "Number of active outbound HTTP requests") defaultAdvisoryParameters
  cnt <- meterCreateCounterInt64 meter "http.client.request.count" (Just "{request}") (Just "Total number of outbound HTTP requests") defaultAdvisoryParameters
  pure HttpClientMetrics {hcmDuration = dur, hcmActive = active, hcmCount = cnt}


resolveMetrics :: HttpClientInstrumentationConfig -> IO HttpClientMetrics
resolveMetrics conf = maybe createHttpClientMetrics pure (httpClientMetrics conf)


metricRequestAttrs :: Request -> A.Attributes
metricRequestAttrs req =
  let a1 = A.addAttribute A.defaultAttributeLimits A.emptyAttributes (unkey SC.http_request_method) (T.decodeUtf8 (method req))
      a2 = A.addAttribute A.defaultAttributeLimits a1 (unkey SC.server_address) (T.decodeUtf8 (host req))
      a3 = A.addAttribute A.defaultAttributeLimits a2 (unkey SC.server_port) (port req)
  in a3


recordResponseMetrics :: HttpClientMetrics -> Request -> Word64 -> Word64 -> Response a -> IO ()
recordResponseMetrics hcm req startNs endNs resp = do
  let sc = statusCode (responseStatus resp)
      durationSec = fromIntegral (endNs - startNs) / 1_000_000_000 :: Double
      base = metricRequestAttrs req
      a1 = A.addAttribute A.defaultAttributeLimits base (unkey SC.http_response_statusCode) sc
      a2 = A.addAttribute A.defaultAttributeLimits a1 (unkey SC.network_protocol_version) (httpVersionText (responseVersion resp))
      respAttrs
        | sc >= 400 = A.addAttribute A.defaultAttributeLimits a2 (unkey SC.error_type) (T.pack (show sc))
        | otherwise = a2
  histogramRecord (hcmDuration hcm) durationSec respAttrs
  counterAdd (hcmCount hcm) 1 respAttrs


recordErrorMetrics :: HttpClientMetrics -> Request -> Word64 -> Word64 -> SomeException -> IO ()
recordErrorMetrics hcm req startNs endNs ex = do
  let durationSec = fromIntegral (endNs - startNs) / 1_000_000_000 :: Double
      base = metricRequestAttrs req
      errType = T.pack $ tyConName $ typeRepTyCon $ typeOf ex
      errAttrs = A.addAttribute A.defaultAttributeLimits base (unkey SC.error_type) errType
  histogramRecord (hcmDuration hcm) durationSec errAttrs
  counterAdd (hcmCount hcm) 1 errAttrs


{- | Instrument a 'ManagerSettings' to automatically trace all HTTP requests.

Each request through the resulting 'Manager' will:

1. Create a client span named after the HTTP method (e.g., @\"GET\"@, @\"POST\"@)
2. Add request\/response attributes per the OTel HTTP semantic conventions
3. Inject context propagation headers (e.g., @traceparent@, @tracestate@)
4. Record response status code and set error status for 4xx\/5xx
5. End the span when the response is received (or on exception)

This is the recommended way to instrument http-client. Set it up once
at 'Manager' creation time and all requests — including those from
third-party libraries — are automatically traced.

@
settings <- 'instrumentManagerSettings' 'httpClientInstrumentationConfig' tlsManagerSettings
manager <- 'newManager' settings
-- All requests through this manager are now traced:
resp <- Client.httpLbs req manager
@

@since 0.2.0.0
-}
instrumentManagerSettings
  :: HttpClientInstrumentationConfig
  -> ManagerSettings
  -> IO ManagerSettings
instrumentManagerSettings conf settings = do
  tracer <- httpTracerProvider
  hcm <- resolveMetrics conf
  pure $
    settings
      { managerModifyRequest = \req -> do
          req' <- managerModifyRequest settings req
          parentCtx <- getContext

          let methodText = T.decodeUtf8 (method req')
              reqSpanName = fromMaybe methodText (requestName conf)

          s <-
            createSpanWithoutCallStack
              tracer
              parentCtx
              reqSpanName
              defaultSpanArguments {kind = Client}

          let newCtx =
                Ctx.insert managedSpanKey s
                  . insertSpan s
                  $ parentCtx

          tok <- attachContext newCtx
          adjustContext (Ctx.insert parentTokenKey tok)

          upDownCounterAdd (hcmActive hcm) 1 (metricRequestAttrs req')

          addRequestAttributes conf s req'

          propagator <- getGlobalTextMapPropagator
          ctx' <- getContext
          hdrs <- injectToHeaders propagator ctx' (requestHeaders req')
          startTs <- getTimestamp
          adjustContext (Ctx.insert metricStartKey (timestampNanoseconds startTs, req'))
          pure req' {requestHeaders = hdrs}
      , managerModifyResponse = \resp -> do
          resp' <- managerModifyResponse settings resp
          ctx <- getContext
          forM_ (Ctx.lookup managedSpanKey ctx) $ \s -> do
            instrumentResponseOnSpan conf s resp'
            endSpan s Nothing
          forM_ (Ctx.lookup metricStartKey ctx) $ \(startNs, origReq) -> do
            endTs <- getTimestamp
            upDownCounterAdd (hcmActive hcm) (-1) (metricRequestAttrs origReq)
            recordResponseMetrics hcm origReq startNs (timestampNanoseconds endTs) resp'
          forM_ (Ctx.lookup parentTokenKey ctx) detachContext
          pure resp'
      , managerWrapException = \req action ->
          managerWrapException settings req action `catch` \(e :: SomeException) -> do
            ctx <- getContext
            forM_ (Ctx.lookup managedSpanKey ctx) $ \s -> do
              let errText = T.pack (show e)
              addAttributes s [(unkey SC.error_type, toAttribute errText)]
              setStatus s (Error errText)
              endSpan s Nothing
            forM_ (Ctx.lookup metricStartKey ctx) $ \(startNs, origReq) -> do
              endTs <- getTimestamp
              upDownCounterAdd (hcmActive hcm) (-1) (metricRequestAttrs origReq)
              recordErrorMetrics hcm origReq startNs (timestampNanoseconds endTs) e
            forM_ (Ctx.lookup parentTokenKey ctx) detachContext
            throwIO e
      }


{- | Create a new 'Manager' with automatic tracing. Convenience wrapper
around 'instrumentManagerSettings' and 'newManager'.

@
manager <- 'newTracedManager' 'httpClientInstrumentationConfig' defaultManagerSettings
@

@since 0.2.0.0
-}
newTracedManager :: HttpClientInstrumentationConfig -> ManagerSettings -> IO Manager
newTracedManager conf settings = do
  settings' <- instrumentManagerSettings conf settings
  newManager settings'


{- | Lightweight variant that only injects context propagation headers
(e.g., @traceparent@, @tracestate@) without creating spans. Useful when
spans are managed elsewhere (e.g., via @inSpan@) but you still want
outgoing requests to carry trace context.

@
settings <- 'httpClientPropagateHeaders' defaultManagerSettings
manager <- 'newManager' settings
@

@since 0.2.0.0
-}
httpClientPropagateHeaders :: ManagerSettings -> IO ManagerSettings
httpClientPropagateHeaders settings =
  pure $
    settings
      { managerModifyRequest = \req -> do
          req' <- managerModifyRequest settings req
          ctx <- getContext
          propagator <- getGlobalTextMapPropagator
          hdrs <- injectToHeaders propagator ctx (requestHeaders req')
          pure req' {requestHeaders = hdrs}
      }


{- | Wrap any HTTP request action in a client span. The request is used
to derive the span name and attributes; the continuation receives the
modified request with propagation headers injected.

@
resp <- 'tracedHttpRequest' conf req $ \\req' ->
  Client.httpLbs req' manager
@

Exception-safe: the span is always ended, even if the action throws.

@since 0.2.0.0
-}
tracedHttpRequest
  :: HttpClientInstrumentationConfig
  -> Request
  -> (Request -> IO (Response a))
  -> IO (Response a)
tracedHttpRequest conf req action = do
  tracer <- httpTracerProvider
  hcm <- resolveMetrics conf
  let methodText = T.decodeUtf8 (method req)
      reqSpanName = fromMaybe methodText (requestName conf)
  ctx <- getContext
  s <-
    createSpanWithoutCallStack
      tracer
      ctx
      reqSpanName
      defaultSpanArguments {kind = Client}
  let ctx' = insertSpan s ctx
  tok <- attachContext ctx'

  addRequestAttributes conf s req
  upDownCounterAdd (hcmActive hcm) 1 (metricRequestAttrs req)
  startTs <- getTimestamp

  propagator <- getGlobalTextMapPropagator
  hdrs <- injectToHeaders propagator ctx' (requestHeaders req)
  let req' = req {requestHeaders = hdrs}

  let onError (e :: SomeException) = do
        endTs <- getTimestamp
        upDownCounterAdd (hcmActive hcm) (-1) (metricRequestAttrs req)
        recordErrorMetrics hcm req (timestampNanoseconds startTs) (timestampNanoseconds endTs) e
        let errText = T.pack (show e)
        addAttributes s [(unkey SC.error_type, toAttribute errText)]
        setStatus s (Error errText)
        endSpan s Nothing
        detachContext tok
        throwIO e

  resp <-
    action req' `catch` onError

  endTs <- getTimestamp
  upDownCounterAdd (hcmActive hcm) (-1) (metricRequestAttrs req)
  recordResponseMetrics hcm req (timestampNanoseconds startTs) (timestampNanoseconds endTs) resp
  instrumentResponseOnSpan conf s resp
  endSpan s Nothing
  detachContext tok
  pure resp


-- | Add request attributes to a span. Does not inject propagation headers.
addRequestAttributes
  :: (MonadIO m)
  => HttpClientInstrumentationConfig
  -> Span
  -> Request
  -> m ()
addRequestAttributes conf s req = do
  let url =
        T.decodeUtf8
          ( (if secure req then "https://" else "http://")
              <> host req
              <> ":"
              <> B.pack (show $ port req)
              <> path req
              <> queryString req
          )
      methodText = T.decodeUtf8 $ method req

  updateName s $ fromMaybe methodText $ requestName conf

  let addStableAttributes = do
        addAttributes
          s
          [ (unkey SC.http_request_method, toAttribute $ T.decodeUtf8 $ method req)
          , (unkey SC.url_full, toAttribute url)
          , (unkey SC.url_path, toAttribute $ T.decodeUtf8 $ path req)
          , (unkey SC.url_query, toAttribute $ T.decodeUtf8 $ queryString req)
          , (unkey SC.server_address, toAttribute $ T.decodeUtf8 $ host req)
          , (unkey SC.server_port, toAttribute $ port req)
          , (unkey SC.url_scheme, toAttribute $ TextAttribute $ if secure req then "https" else "http")
          , (unkey SC.network_protocol_version, toAttribute $ httpVersionText (requestVersion req))
          , (unkey SC.userAgent_original, toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req))
          ]
        addAttributes s
          $ H.fromList
          $ mapMaybe
            (\h -> (\v -> ("http.request.header." <> T.decodeUtf8 (foldedCase h), toAttribute (T.decodeUtf8 v))) <$> lookup h (requestHeaders req))
          $ requestHeadersToRecord conf

      addOldAttributes = do
        addAttributes
          s
          [ (unkey SC.http_method, toAttribute $ T.decodeUtf8 $ method req)
          , (unkey SC.http_url, toAttribute url)
          , (unkey SC.http_target, toAttribute $ T.decodeUtf8 (path req <> queryString req))
          , (unkey SC.http_host, toAttribute $ T.decodeUtf8 $ host req)
          , (unkey SC.http_scheme, toAttribute $ TextAttribute $ if secure req then "https" else "http")
          , (unkey SC.http_flavor, toAttribute $ httpVersionText (requestVersion req))
          , (unkey SC.http_userAgent, toAttribute $ maybe "" T.decodeUtf8 (lookup hUserAgent $ requestHeaders req))
          ]
        addAttributes s
          $ H.fromList
          $ mapMaybe
            (\h -> (\v -> ("http.request.header." <> T.decodeUtf8 (foldedCase h), toAttribute (T.decodeUtf8 v))) <$> lookup h (requestHeaders req))
          $ requestHeadersToRecord conf

  semanticsOptions <- liftIO getSemanticsOptions
  case httpOption semanticsOptions of
    Stable -> addStableAttributes
    StableAndOld -> addStableAttributes >> addOldAttributes
    Old -> addOldAttributes


-- | Record response attributes on a specific span.
instrumentResponseOnSpan
  :: (MonadIO m)
  => HttpClientInstrumentationConfig
  -> Span
  -> Response a
  -> m ()
instrumentResponseOnSpan conf s resp = do
  let sc = statusCode (responseStatus resp)
      errorAttrs
        | sc >= 400 = [(unkey SC.error_type, toAttribute (T.pack $ show sc))]
        | otherwise = []
      headerAttrs =
        H.fromList
          $ mapMaybe
            (\h -> (\v -> ("http.response.header." <> T.decodeUtf8 (foldedCase h), toAttribute (T.decodeUtf8 v))) <$> lookup h (responseHeaders resp))
          $ responseHeadersToRecord conf

  semanticsOptions <- liftIO getSemanticsOptions
  case httpOption semanticsOptions of
    Stable ->
      addAttributes s $
        H.fromList ((unkey SC.http_response_statusCode, toAttribute sc) : errorAttrs)
          `H.union` headerAttrs
    StableAndOld ->
      addAttributes s $
        H.fromList
          ( [ (unkey SC.http_response_statusCode, toAttribute sc)
            , (unkey SC.http_statusCode, toAttribute sc)
            ]
              <> errorAttrs
          )
          `H.union` headerAttrs
    Old ->
      addAttributes s $
        H.fromList ((unkey SC.http_statusCode, toAttribute sc) : errorAttrs)
          `H.union` headerAttrs

  when (sc >= 400) $
    setStatus s (Error "")


{- | Add request attributes and inject propagation headers.

This is the original low-level function. For most use cases, prefer
'instrumentManagerSettings' or 'tracedHttpRequest'.

@since 0.1.0.0
-}
instrumentRequest
  :: (MonadIO m)
  => HttpClientInstrumentationConfig
  -> Ctx.Context
  -> Request
  -> m Request
instrumentRequest conf ctxt req = do
  forM_ (lookupSpan ctxt) $ \s ->
    addRequestAttributes conf s req

  propagator <- liftIO getGlobalTextMapPropagator
  hdrs <- injectToHeaders propagator ctxt $ requestHeaders req
  pure $
    req
      { requestHeaders = hdrs
      }


{- | Record response attributes on the active span in the given context.

This is the original low-level function. For most use cases, prefer
'instrumentManagerSettings' or 'tracedHttpRequest'.

@since 0.1.0.0
-}
instrumentResponse
  :: (MonadIO m)
  => HttpClientInstrumentationConfig
  -> Ctx.Context
  -> Response a
  -> m ()
instrumentResponse conf ctxt resp = do
  propagator <- liftIO getGlobalTextMapPropagator
  ctxt' <- extractFromHeaders propagator (responseHeaders resp) ctxt
  forM_ (lookupSpan ctxt') $ \s ->
    instrumentResponseOnSpan conf s resp


httpVersionText :: HttpVersion -> T.Text
httpVersionText (HttpVersion major minor) =
  TL.toStrict $ toLazyText $ decimal major <> "." <> decimal minor


headersToTextMap :: RequestHeaders -> TextMap
headersToTextMap = textMapFromList . map (\(k, v) -> (T.decodeUtf8 (foldedCase k), T.decodeUtf8 v))


injectToHeaders :: (MonadIO m) => TextMapPropagator -> Ctx.Context -> RequestHeaders -> m RequestHeaders
injectToHeaders propagator ctx existingHeaders = do
  tm <- inject propagator ctx (headersToTextMap existingHeaders)
  pure $ map (\(k, v) -> (CI.mk (T.encodeUtf8 k), T.encodeUtf8 v)) (textMapToList tm)


extractFromHeaders :: (MonadIO m) => TextMapPropagator -> ResponseHeaders -> Ctx.Context -> m Ctx.Context
extractFromHeaders propagator hdrs = extract propagator (headersToTextMap hdrs)
