{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      :  OpenTelemetry.Instrumentation.HttpClient.Metrics
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  HTTP client metrics per the OpenTelemetry stable HTTP semantic conventions.
Stability   :  experimental

Recorded instruments:

* @http.client.request.duration@  — 'Histogram' (seconds)
* @http.client.active_requests@   — 'UpDownCounter'

Attributes: @http.request.method@, @http.response.status_code@, @server.address@,
@server.port@.

Usage:

@
meter <- getMeter provider (instrumentationLibrary "hs-opentelemetry-http-client" "0.1.0")
metrics <- newHttpClientMetrics meter
-- wrap individual requests:
resp <- withHttpClientMetrics metrics request (httpLbs request manager)
@
-}
module OpenTelemetry.Instrumentation.HttpClient.Metrics (
  HttpClientMetrics (..),
  newHttpClientMetrics,
  withHttpClientMetrics,
) where

import Control.Exception (SomeException, catch, throwIO)
import Data.Int (Int64)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import GHC.Clock (getMonotonicTimeNSec)
import Network.HTTP.Client (Request (..), Response (..))
import Network.HTTP.Types (statusCode)
import OpenTelemetry.Attributes (Attributes, addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Metric.Core (
  AdvisoryParameters (..),
  Counter (..),
  Histogram (..),
  Meter (..),
  UpDownCounter (..),
  defaultAdvisoryParameters,
 )


data HttpClientMetrics = HttpClientMetrics
  { httpClientDuration :: !Histogram
  , httpClientActiveRequests :: !(UpDownCounter Int64)
  , httpClientRequestCount :: !(Counter Int64)
  }


newHttpClientMetrics :: Meter -> IO HttpClientMetrics
newHttpClientMetrics m = do
  dur <-
    meterCreateHistogram
      m
      "http.client.request.duration"
      (Just "s")
      (Just "Duration of outbound HTTP requests")
      defaultAdvisoryParameters
        { advisoryExplicitBucketBoundaries =
            Just [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0]
        }
  active <-
    meterCreateUpDownCounterInt64
      m
      "http.client.active_requests"
      (Just "{request}")
      (Just "Number of active outbound HTTP requests")
      defaultAdvisoryParameters
  cnt <-
    meterCreateCounterInt64
      m
      "http.client.request.count"
      (Just "{request}")
      (Just "Total number of outbound HTTP requests")
      defaultAdvisoryParameters
  pure
    HttpClientMetrics
      { httpClientDuration = dur
      , httpClientActiveRequests = active
      , httpClientRequestCount = cnt
      }


{- | Wrap an HTTP request action to record metrics.

@
resp <- withHttpClientMetrics metrics req (httpLbs req manager)
@
-}
withHttpClientMetrics :: HttpClientMetrics -> Request -> IO (Response body) -> IO (Response body)
withHttpClientMetrics hcm req action = do
  let reqAttrs = requestAttributes req
  upDownCounterAdd (httpClientActiveRequests hcm) 1 reqAttrs
  startNs <- getMonotonicTimeNSec
  result <-
    (Right <$> action)
      `catch` (\(e :: SomeException) -> pure (Left e))
  endNs <- getMonotonicTimeNSec
  upDownCounterAdd (httpClientActiveRequests hcm) (-1) reqAttrs
  let durationSec = fromIntegral (endNs - startNs) / 1000000000 :: Double
  case result of
    Right resp -> do
      let sc = statusCode (responseStatus resp)
          respAttrs = addAttribute defaultAttributeLimits reqAttrs (unkey SC.http_response_statusCode) sc
      histogramRecord (httpClientDuration hcm) durationSec respAttrs
      counterAdd (httpClientRequestCount hcm) 1 respAttrs
      pure resp
    Left ex -> do
      let errAttrs = addAttribute defaultAttributeLimits reqAttrs (unkey SC.error_type) (T.pack (show (typeOf ex)))
      histogramRecord (httpClientDuration hcm) durationSec errAttrs
      counterAdd (httpClientRequestCount hcm) 1 errAttrs
      throwIO ex
  where
    typeOf :: SomeException -> String
    typeOf e = case words (show e) of
      (w : _) -> w
      [] -> "unknown"


requestAttributes :: Request -> Attributes
requestAttributes req =
  let a1 = addAttribute defaultAttributeLimits emptyAttributes (unkey SC.http_request_method) (T.decodeUtf8 (method req))
      a2 = addAttribute defaultAttributeLimits a1 (unkey SC.server_address) (T.decodeUtf8 (host req))
      a3 = addAttribute defaultAttributeLimits a2 (unkey SC.server_port) (port req)
  in a3
