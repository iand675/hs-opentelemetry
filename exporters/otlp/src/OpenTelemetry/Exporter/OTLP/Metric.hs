{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      : OpenTelemetry.Exporter.OTLP.Metric
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : OTLP metric exporter (HTTP/protobuf)
Stability   : experimental

= Overview

Exports metrics to any OTLP-compatible endpoint using HTTP with protobuf
encoding.

= Configuration

Uses the same @OTEL_EXPORTER_OTLP_*@ environment variables as the span
exporter (see "OpenTelemetry.Exporter.OTLP.Span"), with metric-specific
overrides:

* @OTEL_EXPORTER_OTLP_METRICS_ENDPOINT@ — endpoint override for metrics
* @OTEL_EXPORTER_OTLP_METRICS_HEADERS@ — additional headers for metrics
* @OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE@ — TLS CA cert for metrics
* @OTEL_EXPORTER_OTLP_METRICS_INSECURE@ — disable TLS for metrics
* @OTEL_EXPORTER_OTLP_METRICS_COMPRESSION@ — compression for metrics
* @OTEL_EXPORTER_OTLP_METRICS_TIMEOUT@ — timeout for metrics export
* @OTEL_EXPORTER_OTLP_METRICS_PROTOCOL@ — protocol override for metrics
* @OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE@ — @cumulative@ (default)
  or @delta@
-}
module OpenTelemetry.Exporter.OTLP.Metric (
  otlpMetricExporter,
  resourceMetricsToExportRequest,
) where

import Codec.Compression.GZip (compress)
import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad (when)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Bits (shiftL)
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe)
import Data.ProtoLens (defMessage, encodeMessage)
import Data.ProtoLens.Encoding (decodeMessage)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector.Generic as VG
import Lens.Micro ((&), (.~), (^.))
import Network.HTTP.Client
import qualified Network.HTTP.Client as HTTPClient
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import OpenTelemetry.Attributes
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExemplar (..),
  MetricExport (..),
  MetricExporter (..),
  NumberValue (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Exporter.OTLP.Internal.Config
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Resource (MaterializedResources, getMaterializedResourcesAttributes, getMaterializedResourcesSchema)
import Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest, ExportMetricsServiceResponse)
import qualified Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields as MSF
import Proto.Opentelemetry.Proto.Common.V1.Common (InstrumentationScope, KeyValue)
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as Common_Fields
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics as PM
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields as Mf
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource as Res
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields as Rf
import System.Random (randomRIO)


#ifdef GRPC_ENABLED
import qualified OpenTelemetry.Exporter.OTLP.GRPC
#endif


-- | Encode metric batches to an OTLP 'ExportMetricsServiceRequest'.
resourceMetricsToExportRequest :: Vector ResourceMetricsExport -> ExportMetricsServiceRequest
resourceMetricsToExportRequest rms =
  defMessage
    & MSF.vec'resourceMetrics
      .~ V.map resourceMetricsExportToProto rms


{- | Create an OTLP metric exporter, choosing transport based on the
configured protocol (default: @http\/protobuf@).
-}
otlpMetricExporter :: (MonadIO m) => OTLPExporterConfig -> m MetricExporter
otlpMetricExporter conf = case resolvedMetricProtocol conf of
  HttpProtobuf -> httpOtlpMetricExporter conf
#ifdef GRPC_ENABLED
  GRpc -> OpenTelemetry.Exporter.OTLP.GRPC.grpcOtlpMetricExporter conf resourceMetricsToExportRequest
#endif


resolvedMetricProtocol :: OTLPExporterConfig -> Protocol
resolvedMetricProtocol conf =
  case otlpMetricsProtocol conf <|> otlpProtocol conf of
    Just p -> p
    Nothing -> HttpProtobuf


-- | OTLP 'MetricExporter' using HTTP\/Protobuf.
httpOtlpMetricExporter :: (MonadIO m) => OTLPExporterConfig -> m MetricExporter
httpOtlpMetricExporter conf = liftIO $ do
  req <- parseRequest (metricsEndpointUrl conf)
  let (encodingHeaders, encoder) = httpMetricsCompression conf
  let baseReq =
        req
          { method = "POST"
          , requestHeaders = encodingHeaders <> httpMetricsBaseHeaders conf req
          , responseTimeout = httpMetricsResponseTimeout conf
          }
  pure $
    MetricExporter
      { metricExporterExport = \batches -> do
          if not (anyMetricsToExport batches)
            then pure Success
            else do
              result <- try $ exporterExportCall encoder baseReq batches
              case result of
                Left err -> case fromException err of
                  Just (SomeAsyncException _) -> throwIO err
                  Nothing -> pure $ Failure $ Just err
                Right ok -> pure ok
      , metricExporterShutdown = pure ShutdownSuccess
      , metricExporterForceFlush = pure FlushSuccess
      }
  where
    retryDelay = 100_000
    maxRetryCount = 5
    isRetryableException = \case
      ResponseTimeout -> True
      ConnectionTimeout -> True
      ConnectionFailure _ -> True
      ConnectionClosed -> True
      _ -> False

    exporterExportCall encoder baseReq batches = do
      let msg = encodeMessage (resourceMetricsToExportRequest batches)
      let req =
            baseReq
              { requestBody =
                  RequestBodyLBS $ encoder $ L.fromStrict msg
              }
      sendReq req 0
    sendReq req backoffCount = do
      eResp <- try $ httpBS req
      let exponentialBackoff =
            if backoffCount == maxRetryCount
              then pure $ Failure Nothing
              else do
                let !baseDelay = retryDelay `shiftL` backoffCount
                jitterUs <- randomRIO (0, baseDelay)
                threadDelay (baseDelay + jitterUs)
                sendReq req (backoffCount + 1)
      case eResp of
        Left err@(HttpExceptionRequest req' e)
          | HTTPClient.host req' == "localhost"
          , HTTPClient.port req' == 4317 || HTTPClient.port req' == 4318
          , ConnectionFailure _ <- e ->
              pure $ Failure Nothing
          | otherwise ->
              if isRetryableException e
                then exponentialBackoff
                else pure $ Failure $ Just $ SomeException err
        Left err -> pure $ Failure $ Just $ SomeException err
        Right resp ->
          if isRetryableHttpStatus (responseStatus resp)
            then case lookup hRetryAfter $ responseHeaders resp of
              Nothing -> exponentialBackoff
              Just retryAfter -> do
                mMicros <- parseRetryAfterMicros retryAfter
                case mMicros of
                  Nothing -> exponentialBackoff
                  Just micros -> do
                    threadDelay micros
                    sendReq req (backoffCount + 1)
            else
              if statusCode (responseStatus resp) >= 300
                then do
                  otelLogWarning $
                    "OTLP metric export failed with HTTP status "
                      <> show (statusCode (responseStatus resp))
                      <> ": "
                      <> C.unpack (statusMessage (responseStatus resp))
                  pure $ Failure Nothing
                else do
                  let body = responseBody resp
                  case decodeMessage body of
                    Right (mResp :: ExportMetricsServiceResponse) -> do
                      let ps = mResp ^. MSF.partialSuccess
                          rejected = ps ^. MSF.rejectedDataPoints
                          errMsg = ps ^. MSF.errorMessage
                      when (rejected > 0) $
                        otelLogWarning $
                          "OTLP partial success: "
                            <> show rejected
                            <> " metric data points rejected"
                            <> if T.null errMsg then "" else ": " <> T.unpack errMsg
                      pure Success
                    Left _ -> pure Success


type Encoder = L.ByteString -> L.ByteString


httpMetricsCompression :: OTLPExporterConfig -> ([(HeaderName, C.ByteString)], Encoder)
httpMetricsCompression conf =
  case otlpMetricsCompression conf <|> otlpCompression conf of
    Just GZip -> ([(hContentEncoding, "gzip")], compress)
    _ -> ([], id)


httpMetricsResponseTimeout :: OTLPExporterConfig -> ResponseTimeout
httpMetricsResponseTimeout conf = case otlpMetricsTimeout conf <|> otlpTimeout conf of
  Just timeoutMilli
    | timeoutMilli >= 1 -> responseTimeoutMicro (timeoutMilli * 1_000)
  -- Spec: "Export MUST NOT block indefinitely."
  _ -> responseTimeoutMicro (defaultExporterTimeout * 1_000)


httpMetricsBaseHeaders :: OTLPExporterConfig -> Request -> RequestHeaders
httpMetricsBaseHeaders conf req =
  concat
    [ [(hContentType, httpProtobufContentType)]
    , [(hAccept, httpProtobufContentType)]
    , [("User-Agent", otlpUserAgent)]
    , fromMaybe [] (otlpHeaders conf)
    , fromMaybe [] (otlpMetricsHeaders conf)
    , requestHeaders req
    ]


metricsEndpointUrl :: OTLPExporterConfig -> String
metricsEndpointUrl conf = httpSignalEndpointUrl (otlpMetricsEndpoint conf) conf "/v1/metrics"


anyMetricsToExport :: Vector ResourceMetricsExport -> Bool
anyMetricsToExport batches =
  V.any
    ( \rm ->
        V.any (not . V.null . scopeMetricsExports) (resourceMetricsScopes rm)
    )
    batches


resourceMetricsExportToProto :: ResourceMetricsExport -> PM.ResourceMetrics
resourceMetricsExportToProto ResourceMetricsExport {..} =
  defMessage
    & Mf.resource
      .~ materializedResourceToProto resourceMetricsResource
    & Mf.vec'scopeMetrics
      .~ V.map scopeMetricsExportToProto resourceMetricsScopes
    & Mf.schemaUrl
      .~ maybe T.empty T.pack (getMaterializedResourcesSchema resourceMetricsResource)


materializedResourceToProto :: MaterializedResources -> Res.Resource
materializedResourceToProto r =
  let attrs = getMaterializedResourcesAttributes r
  in defMessage
      & Rf.vec'attributes
        .~ attributesToProto attrs
      & Rf.droppedAttributesCount
        .~ fromIntegral (getDropped attrs)


scopeMetricsExportToProto :: ScopeMetricsExport -> PM.ScopeMetrics
scopeMetricsExportToProto ScopeMetricsExport {..} =
  defMessage
    & Mf.scope
      .~ instrumentationLibraryToProto scopeMetricsScope
    & Mf.vec'metrics
      .~ V.map metricExportToProto scopeMetricsExports
    & Mf.schemaUrl
      .~ librarySchemaUrl scopeMetricsScope


instrumentationLibraryToProto :: InstrumentationLibrary -> InstrumentationScope
instrumentationLibraryToProto InstrumentationLibrary {..} =
  defMessage
    & Common_Fields.name
      .~ libraryName
    & Common_Fields.version
      .~ libraryVersion
    & Common_Fields.vec'attributes
      .~ attributesToProto libraryAttributes
    & Common_Fields.droppedAttributesCount
      .~ fromIntegral (getDropped libraryAttributes)


temporalityToProto :: AggregationTemporality -> PM.AggregationTemporality
temporalityToProto = \case
  AggregationDelta -> PM.AGGREGATION_TEMPORALITY_DELTA
  AggregationCumulative -> PM.AGGREGATION_TEMPORALITY_CUMULATIVE


metricExportToProto :: MetricExport -> PM.Metric
metricExportToProto = \case
  MetricExportSum name desc unit_ _scope monotonic _isInt temp pts ->
    defMessage
      & Mf.name
        .~ name
      & Mf.description
        .~ desc
      & Mf.unit
        .~ unit_
      & Mf.sum
        .~ ( defMessage
              & Mf.aggregationTemporality
                .~ temporalityToProto temp
              & Mf.isMonotonic
                .~ monotonic
              & Mf.vec'dataPoints
                .~ V.map sumPointToProto pts
           )
  MetricExportHistogram name desc unit_ _scope temp pts ->
    defMessage
      & Mf.name
        .~ name
      & Mf.description
        .~ desc
      & Mf.unit
        .~ unit_
      & Mf.histogram
        .~ ( defMessage
              & Mf.aggregationTemporality
                .~ temporalityToProto temp
              & Mf.vec'dataPoints
                .~ V.map histogramPointToProto pts
           )
  MetricExportExponentialHistogram name desc unit_ _scope temp pts ->
    defMessage
      & Mf.name
        .~ name
      & Mf.description
        .~ desc
      & Mf.unit
        .~ unit_
      & Mf.exponentialHistogram
        .~ ( defMessage
              & Mf.aggregationTemporality
                .~ temporalityToProto temp
              & Mf.vec'dataPoints
                .~ V.map exponentialHistogramPointToProto pts
           )
  MetricExportGauge name desc unit_ _scope _isInt pts ->
    defMessage
      & Mf.name
        .~ name
      & Mf.description
        .~ desc
      & Mf.unit
        .~ unit_
      & Mf.gauge
        .~ ( defMessage
              & Mf.vec'dataPoints
                .~ V.map gaugePointToProto pts
           )


sumPointToProto :: SumDataPoint -> PM.NumberDataPoint
sumPointToProto SumDataPoint {..} =
  setNumberValue sumDataPointValue $
    defMessage
      & Mf.vec'attributes
        .~ attributesToProto sumDataPointAttributes
      & Mf.startTimeUnixNano
        .~ sumDataPointStartTimeUnixNano
      & Mf.timeUnixNano
        .~ sumDataPointTimeUnixNano
      & Mf.vec'exemplars
        .~ V.map metricExemplarToProto sumDataPointExemplars


gaugePointToProto :: GaugeDataPoint -> PM.NumberDataPoint
gaugePointToProto GaugeDataPoint {..} =
  setNumberValue gaugeDataPointValue $
    defMessage
      & Mf.vec'attributes
        .~ attributesToProto gaugeDataPointAttributes
      & Mf.startTimeUnixNano
        .~ gaugeDataPointStartTimeUnixNano
      & Mf.timeUnixNano
        .~ gaugeDataPointTimeUnixNano
      & Mf.vec'exemplars
        .~ V.map metricExemplarToProto gaugeDataPointExemplars


setNumberValue :: NumberValue -> PM.NumberDataPoint -> PM.NumberDataPoint
setNumberValue (IntNumber i) dp = dp & Mf.asInt .~ i
setNumberValue (DoubleNumber d) dp = dp & Mf.asDouble .~ d


histogramPointToProto :: HistogramDataPoint -> PM.HistogramDataPoint
histogramPointToProto HistogramDataPoint {..} =
  defMessage
    & Mf.vec'attributes
      .~ attributesToProto histogramDataPointAttributes
    & Mf.startTimeUnixNano
      .~ histogramDataPointStartTimeUnixNano
    & Mf.timeUnixNano
      .~ histogramDataPointTimeUnixNano
    & Mf.count
      .~ histogramDataPointCount
    & Mf.maybe'sum
      .~ Just histogramDataPointSum
    & Mf.vec'bucketCounts
      .~ VG.convert histogramDataPointBucketCounts
    & Mf.vec'explicitBounds
      .~ VG.convert histogramDataPointExplicitBounds
    & Mf.maybe'min
      .~ histogramDataPointMin
    & Mf.maybe'max
      .~ histogramDataPointMax
    & Mf.vec'exemplars
      .~ V.map metricExemplarToProto histogramDataPointExemplars


metricExemplarToProto :: MetricExemplar -> PM.Exemplar
metricExemplarToProto MetricExemplar {..} =
  defMessage
    & Mf.traceId
      .~ metricExemplarTraceId
    & Mf.spanId
      .~ metricExemplarSpanId
    & Mf.timeUnixNano
      .~ metricExemplarTimeUnixNano
    & Mf.vec'filteredAttributes
      .~ attributesToProto metricExemplarFilteredAttributes
    & Mf.maybe'value
      .~ fmap
        ( \case
            IntNumber i -> PM.Exemplar'AsInt i
            DoubleNumber d -> PM.Exemplar'AsDouble d
        )
        metricExemplarValue


exponentialHistogramPointToProto :: ExponentialHistogramDataPoint -> PM.ExponentialHistogramDataPoint
exponentialHistogramPointToProto ExponentialHistogramDataPoint {..} =
  defMessage
    & Mf.vec'attributes
      .~ attributesToProto exponentialHistogramDataPointAttributes
    & Mf.startTimeUnixNano
      .~ exponentialHistogramDataPointStartTimeUnixNano
    & Mf.timeUnixNano
      .~ exponentialHistogramDataPointTimeUnixNano
    & Mf.count
      .~ exponentialHistogramDataPointCount
    & Mf.maybe'sum
      .~ exponentialHistogramDataPointSum
    & Mf.scale
      .~ exponentialHistogramDataPointScale
    & Mf.zeroCount
      .~ exponentialHistogramDataPointZeroCount
    & Mf.maybe'positive
      .~ ( if V.null exponentialHistogramDataPointPositiveBucketCounts
            then Nothing
            else
              Just $
                defMessage
                  & Mf.offset
                    .~ exponentialHistogramDataPointPositiveOffset
                  & Mf.vec'bucketCounts
                    .~ VG.convert exponentialHistogramDataPointPositiveBucketCounts
         )
    & Mf.maybe'negative
      .~ ( if V.null exponentialHistogramDataPointNegativeBucketCounts
            then Nothing
            else
              Just $
                defMessage
                  & Mf.offset
                    .~ exponentialHistogramDataPointNegativeOffset
                  & Mf.vec'bucketCounts
                    .~ VG.convert exponentialHistogramDataPointNegativeBucketCounts
         )
    & Mf.maybe'min
      .~ exponentialHistogramDataPointMin
    & Mf.maybe'max
      .~ exponentialHistogramDataPointMax
    & Mf.vec'exemplars
      .~ V.map metricExemplarToProto exponentialHistogramDataPointExemplars
    & Mf.zeroThreshold
      .~ exponentialHistogramDataPointZeroThreshold


attributesToProto :: Attributes -> Vector KeyValue
attributesToProto attrs =
  V.map (uncurry attributeToKeyValue) $
    V.fromListN (H.size m) (H.toList m)
  where
    m = getAttributeMap attrs
    primAttributeToAnyValue = \case
      TextAttribute t -> defMessage & Common_Fields.stringValue .~ t
      BoolAttribute b -> defMessage & Common_Fields.boolValue .~ b
      DoubleAttribute d -> defMessage & Common_Fields.doubleValue .~ d
      IntAttribute i -> defMessage & Common_Fields.intValue .~ i
    attributeToKeyValue :: Text -> Attribute -> KeyValue
    attributeToKeyValue k v =
      defMessage
        & Common_Fields.key
          .~ k
        & Common_Fields.value
          .~ ( case v of
                AttributeValue a -> primAttributeToAnyValue a
                AttributeArray a ->
                  defMessage
                    & Common_Fields.arrayValue
                      .~ (defMessage & Common_Fields.values .~ fmap primAttributeToAnyValue a)
             )
