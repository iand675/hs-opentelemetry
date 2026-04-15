{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Instrumentation.Wai.Metrics
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  WAI middleware that records HTTP server metrics per the OpenTelemetry HTTP semantic conventions (stable, Nov 2023).
Stability   :  experimental

Recorded instruments:

* @http.server.request.duration@  — 'Histogram' (seconds)
* @http.server.active_requests@   — 'UpDownCounter'

Attributes follow the stable HTTP semantic conventions:
@http.request.method@, @http.response.status_code@, @url.scheme@,
@network.protocol.version@, @http.route@ (if set on the span).

Usage:

@
meter <- getMeter provider (instrumentationLibrary "hs-opentelemetry-wai" "0.1.0")
metricsMiddleware <- newWaiMetricsMiddleware meter
let app = metricsMiddleware (tracingMiddleware myApp)
@
-}
module OpenTelemetry.Instrumentation.Wai.Metrics (
  newWaiMetricsMiddleware,
  WaiMetrics (..),
  newWaiMetrics,
) where

import Data.Int (Int64)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import GHC.Clock (getMonotonicTimeNSec)
import Network.HTTP.Types (HttpVersion (..), statusCode)
import Network.Wai (Middleware, Request (..), responseStatus)
import OpenTelemetry.Attributes (Attributes, addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Metric.Core (
  AdvisoryParameters (..),
  Counter (..),
  Histogram (..),
  Meter (..),
  UpDownCounter (..),
  defaultAdvisoryParameters,
 )
import qualified OpenTelemetry.SemanticConventions as SC


data WaiMetrics = WaiMetrics
  { waiDurationHistogram :: !Histogram
  , waiActiveRequests :: !(UpDownCounter Int64)
  , waiRequestCounter :: !(Counter Int64)
  }


{- | Allocate metric instruments on the given 'Meter'.
Call once during application startup.
-}
newWaiMetrics :: Meter -> IO WaiMetrics
newWaiMetrics m = do
  dur <-
    meterCreateHistogram
      m
      "http.server.request.duration"
      (Just "s")
      (Just "Duration of inbound HTTP requests")
      defaultAdvisoryParameters
        { advisoryExplicitBucketBoundaries =
            Just [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0]
        }
  active <-
    meterCreateUpDownCounterInt64
      m
      "http.server.active_requests"
      (Just "{request}")
      (Just "Number of active HTTP server requests")
      defaultAdvisoryParameters
  reqCount <-
    meterCreateCounterInt64
      m
      "http.server.request.count"
      (Just "{request}")
      (Just "Total number of HTTP server requests")
      defaultAdvisoryParameters
  pure
    WaiMetrics
      { waiDurationHistogram = dur
      , waiActiveRequests = active
      , waiRequestCounter = reqCount
      }


{- | Create a WAI 'Middleware' that records HTTP server metrics.

Should be composed with tracing middleware so that @http.route@ can be
extracted from the span attributes.
-}
newWaiMetricsMiddleware :: Meter -> IO Middleware
newWaiMetricsMiddleware m = do
  wm <- newWaiMetrics m
  pure (metricsMiddleware wm)


metricsMiddleware :: WaiMetrics -> Middleware
metricsMiddleware wm app req sendResp = do
  let methodAttr = addAttribute defaultAttributeLimits emptyAttributes (unkey SC.http_request_method) (T.decodeUtf8 (requestMethod req))
      reqAttrs =
        addAttribute defaultAttributeLimits methodAttr (unkey SC.url_scheme) $
          if isSecure req then ("https" :: T.Text) else "http"
  upDownCounterAdd (waiActiveRequests wm) 1 reqAttrs
  startNs <- getMonotonicTimeNSec
  app req $ \resp -> do
    result <- sendResp resp
    endNs <- getMonotonicTimeNSec
    upDownCounterAdd (waiActiveRequests wm) (-1) reqAttrs
    let sc = statusCode (responseStatus resp)
        durationSec = fromIntegral (endNs - startNs) / 1000000000 :: Double
        respAttrs = addResponseAttrs sc req reqAttrs
    histogramRecord (waiDurationHistogram wm) durationSec respAttrs
    counterAdd (waiRequestCounter wm) 1 respAttrs
    pure result


addResponseAttrs :: Int -> Request -> Attributes -> Attributes
addResponseAttrs sc req attrs =
  let a1 = addAttribute defaultAttributeLimits attrs (unkey SC.http_response_statusCode) sc
      a2 =
        addAttribute defaultAttributeLimits a1 (unkey SC.network_protocol_version) $
          httpVersionToText (httpVersion req)
  in a2


httpVersionToText :: HttpVersion -> T.Text
httpVersionToText (HttpVersion major minor)
  | minor == 0 = T.pack (show major)
  | otherwise = T.pack (show major <> "." <> show minor)
