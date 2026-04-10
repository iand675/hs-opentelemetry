{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

{- | Prometheus PushGateway support.

Periodically pushes metrics to a
<https://github.com/prometheus/pushgateway Prometheus PushGateway>
in text exposition format.

@
mgr <- newManager defaultManagerSettings
(provider, env) <- createMeterProvider ...
handle <- startPushGateway
  PushGatewayConfig
    { pushGatewayEndpoint = "http://pushgateway:9091"
    , pushGatewayJob      = "my-service"
    , pushGatewayIntervalSeconds = 15
    }
  mgr
  (collectResourceMetrics env)
@
-}
module OpenTelemetry.Exporter.Prometheus.PushGateway (
  PushGatewayConfig (..),
  pushMetricsOnce,
  startPushGateway,
) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (Async, async)
import Control.Exception (SomeException, try)
import Control.Monad (forever, void)
import qualified Data.ByteString.Lazy as LBS
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Vector (Vector)
import Network.HTTP.Client (
  Manager,
  Request (..),
  RequestBody (..),
  httpNoBody,
  parseRequest,
 )
import OpenTelemetry.Exporter.Metric (ResourceMetricsExport)
import OpenTelemetry.Exporter.Prometheus (renderPrometheusText)


data PushGatewayConfig = PushGatewayConfig
  { pushGatewayEndpoint :: Text
  -- ^ Base URL of the PushGateway, e.g. @\"http:\/\/pushgateway:9091\"@
  , pushGatewayJob :: Text
  -- ^ Value for the @job@ grouping key
  , pushGatewayIntervalSeconds :: Int
  -- ^ Seconds between pushes
  }


{- | Push the current metrics snapshot once.

Uses HTTP PUT to @\/metrics\/job\/<job>@ which replaces all metrics
for the given job.
-}
pushMetricsOnce :: PushGatewayConfig -> Manager -> IO (Vector ResourceMetricsExport) -> IO ()
pushMetricsOnce config mgr collect = do
  metrics <- collect
  let body = LBS.fromStrict (TE.encodeUtf8 (renderPrometheusText metrics))
      url =
        T.unpack (pushGatewayEndpoint config)
          <> "/metrics/job/"
          <> T.unpack (pushGatewayJob config)
  baseReq <- parseRequest url
  let req =
        baseReq
          { method = "PUT"
          , requestBody = RequestBodyLBS body
          , requestHeaders = [("Content-Type", "text/plain; version=0.0.4; charset=utf-8")]
          }
  void $ httpNoBody req mgr


{- | Start a background thread that periodically pushes metrics.

Returns an 'Async' handle. Errors during individual pushes are silently
swallowed to avoid crashing the application; the next push will retry.
-}
startPushGateway :: PushGatewayConfig -> Manager -> IO (Vector ResourceMetricsExport) -> IO (Async ())
startPushGateway config mgr collect = async $ forever $ do
  _ <- try @SomeException $ pushMetricsOnce config mgr collect
  threadDelay (pushGatewayIntervalSeconds config * 1000000)
