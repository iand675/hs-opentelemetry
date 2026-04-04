{-# LANGUAGE OverloadedStrings #-}

{- | Prometheus metrics serving via WAI.

Provides a WAI 'Middleware' and standalone 'Application' for serving
OpenTelemetry metrics in Prometheus text exposition format.

== Avoiding trace noise

The 'prometheusMiddleware' short-circuits @\/metrics@ requests before they
reach any inner middleware. Compose it __outside__ the OTel WAI tracing
middleware so scrape requests never generate spans:

@
app <- prometheusMiddleware collect (otelMiddleware innerApp)
@

== Standalone server (spec-conformant)

'startPrometheusServer' reads @OTEL_EXPORTER_PROMETHEUS_HOST@ (default
@0.0.0.0@) and @OTEL_EXPORTER_PROMETHEUS_PORT@ (default @9464@) and runs
a Warp server that serves the @\/metrics@ endpoint. No OTel instrumentation
is applied to this server.
-}
module OpenTelemetry.Exporter.Prometheus.WAI (
  -- * WAI integration
  prometheusApplication,
  prometheusMiddleware,
  prometheusMiddleware',

  -- * Standalone server
  startPrometheusServer,
  startPrometheusServerAsync,

  -- * Configuration
  PrometheusExporterConfig (..),
  defaultPrometheusExporterConfig,
) where

import Control.Concurrent.Async (Async, async)
import qualified Data.ByteString.Lazy as LBS
import Data.String (fromString)
import Data.Text (Text)
import qualified Data.Text.Encoding as TE
import Network.HTTP.Types (status200)
import Network.Wai (Application, Middleware, pathInfo, responseLBS)
import qualified Network.Wai.Handler.Warp as Warp
import OpenTelemetry.Exporter.Metric (ResourceMetricsExport)
import OpenTelemetry.Exporter.Prometheus (renderPrometheusText)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


data PrometheusExporterConfig = PrometheusExporterConfig
  { prometheusMetricsPath :: [Text]
  -- ^ URL path segments to serve metrics at. Default: @[\"metrics\"]@
  }


defaultPrometheusExporterConfig :: PrometheusExporterConfig
defaultPrometheusExporterConfig =
  PrometheusExporterConfig
    { prometheusMetricsPath = ["metrics"]
    }


{- | WAI 'Application' that always responds with Prometheus metrics.

Every request path returns @200@ with the current metrics snapshot. Use
this with 'Warp.runSettings' for a dedicated metrics server, or compose
into a larger application with a router.
-}
prometheusApplication :: IO [ResourceMetricsExport] -> Application
prometheusApplication collect _request respond = do
  metrics <- collect
  let body = LBS.fromStrict (TE.encodeUtf8 (renderPrometheusText metrics))
  respond $
    responseLBS
      status200
      [("Content-Type", "text/plain; version=0.0.4; charset=utf-8")]
      body


{- | WAI 'Middleware' that intercepts @\/metrics@ and serves Prometheus text.

Requests whose 'pathInfo' matches the configured metrics path are handled
immediately; all other requests pass through to the inner application.
Place this __outside__ any OTel tracing middleware to avoid generating
spans for Prometheus scrape requests.
-}
prometheusMiddleware :: IO [ResourceMetricsExport] -> Middleware
prometheusMiddleware = prometheusMiddleware' defaultPrometheusExporterConfig


-- | Like 'prometheusMiddleware' with a custom 'PrometheusExporterConfig'.
prometheusMiddleware' :: PrometheusExporterConfig -> IO [ResourceMetricsExport] -> Middleware
prometheusMiddleware' config collect inner request respond
  | pathInfo request == prometheusMetricsPath config =
      prometheusApplication collect request respond
  | otherwise =
      inner request respond


{- | Start a standalone Prometheus HTTP server (blocking).

Reads environment variables per the OpenTelemetry specification:

* @OTEL_EXPORTER_PROMETHEUS_HOST@ — bind address (default @0.0.0.0@)
* @OTEL_EXPORTER_PROMETHEUS_PORT@ — listen port (default @9464@)

The server responds to every path with the metrics snapshot. No
OpenTelemetry instrumentation is applied to this server.
-}
startPrometheusServer :: IO [ResourceMetricsExport] -> IO ()
startPrometheusServer collect = do
  host <- maybe "0.0.0.0" id <$> lookupEnv "OTEL_EXPORTER_PROMETHEUS_HOST"
  port <- maybe 9464 id . (>>= readMaybe) <$> lookupEnv "OTEL_EXPORTER_PROMETHEUS_PORT"
  let settings =
        Warp.setPort port $
          Warp.setHost (fromString host) $
            Warp.defaultSettings
  Warp.runSettings settings (prometheusApplication collect)


-- | Like 'startPrometheusServer' but runs in a background thread.
startPrometheusServerAsync :: IO [ResourceMetricsExport] -> IO (Async ())
startPrometheusServerAsync collect = async (startPrometheusServer collect)
