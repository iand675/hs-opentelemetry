{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- | OTLP HTTP\/Protobuf metrics exporter (@\/v1\/metrics@).

See "OpenTelemetry.Exporter.OTLP.Span" for shared configuration ('OTLPExporterConfig').
-}
module OpenTelemetry.Exporter.OTLP.Metric (
  otlpMetricExporter,
  resourceMetricsToExportRequest,
) where

import Codec.Compression.GZip (compress)
import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Bits (shiftL)
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import qualified Data.HashMap.Strict as H
import Data.List (isInfixOf)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector.Generic as VG
import Network.HTTP.Client
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
import OpenTelemetry.Exporter.OTLP.Span (CompressionFormat (..), OTLPExporterConfig (..))
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Resource (MaterializedResources, getMaterializedResourcesAttributes, getMaterializedResourcesSchema)
import Proto.Encode (encodeMessage)
import Proto.OpenTelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest, defaultExportMetricsServiceRequest)
import qualified Proto.OpenTelemetry.Proto.Collector.Metrics.V1.MetricsService as MSF
import Proto.OpenTelemetry.Proto.Common.V1.Common (InstrumentationScope, KeyValue)
import qualified Proto.OpenTelemetry.Proto.Common.V1.Common as Common
import qualified Proto.OpenTelemetry.Proto.Metrics.V1.Metrics as PM
import qualified Proto.OpenTelemetry.Proto.Resource.V1.Resource as Res
import Text.Read (readMaybe)


-- | Default OTLP timeout (milliseconds), aligned with "OpenTelemetry.Exporter.OTLP.Span".
defaultExporterTimeout :: Int
defaultExporterTimeout = 10_000


httpHost :: OTLPExporterConfig -> String
httpHost conf = fromMaybe defaultHost (otlpEndpoint conf)
  where
    defaultHost = "http://localhost:4318"


httpProtobufMimeType :: C.ByteString
httpProtobufMimeType = "application/x-protobuf"


-- | Encode metric batches to an OTLP 'ExportMetricsServiceRequest'.
resourceMetricsToExportRequest :: Vector ResourceMetricsExport -> ExportMetricsServiceRequest
resourceMetricsToExportRequest rms =
  defaultExportMetricsServiceRequest
    { MSF.exportMetricsServiceRequestResourceMetrics = V.map resourceMetricsExportToProto rms
    }


-- | OTLP 'MetricExporter' using HTTP\/Protobuf (same transport as 'OpenTelemetry.Exporter.OTLP.Span.otlpExporter').
otlpMetricExporter :: (MonadIO m) => OTLPExporterConfig -> m MetricExporter
otlpMetricExporter conf = liftIO $ do
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
    isRetryableStatusCode status_ =
      status_ == status408 || status_ == status429 || (statusCode status_ >= 500 && statusCode status_ < 600)
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
                threadDelay (retryDelay `shiftL` backoffCount)
                sendReq req (backoffCount + 1)
      case eResp of
        Left (HttpExceptionRequest _req' e)
          | isRetryableException e -> exponentialBackoff
        Left err -> pure $ Failure $ Just $ SomeException err
        Right resp ->
          if isRetryableStatusCode (responseStatus resp)
            then case lookup hRetryAfter $ responseHeaders resp of
              Nothing -> exponentialBackoff
              Just retryAfter -> case readMaybe $ C.unpack retryAfter of
                Nothing -> exponentialBackoff
                Just seconds -> do
                  threadDelay (seconds * 1_000_000)
                  sendReq req (backoffCount + 1)
            else
              if statusCode (responseStatus resp) >= 300
                then pure $ Failure Nothing
                else pure Success


type Encoder = L.ByteString -> L.ByteString


httpMetricsCompression :: OTLPExporterConfig -> ([(HeaderName, C.ByteString)], Encoder)
httpMetricsCompression conf =
  case otlpMetricsCompression conf <|> otlpCompression conf of
    Just GZip -> ([(hContentEncoding, "gzip")], compress)
    _ -> ([], id)


httpMetricsResponseTimeout :: OTLPExporterConfig -> ResponseTimeout
httpMetricsResponseTimeout conf = case otlpMetricsTimeout conf <|> otlpTimeout conf of
  Just timeoutMilli
    | timeoutMilli == 0 -> responseTimeoutNone
    | timeoutMilli >= 1 -> responseTimeoutMicro (timeoutMilli * 1_000)
  _ -> responseTimeoutMicro (defaultExporterTimeout * 1_000)


httpMetricsBaseHeaders :: OTLPExporterConfig -> Request -> RequestHeaders
httpMetricsBaseHeaders conf req =
  concat
    [ [(hContentType, httpProtobufMimeType)]
    , [(hAccept, httpProtobufMimeType)]
    , fromMaybe [] (otlpHeaders conf)
    , fromMaybe [] (otlpMetricsHeaders conf)
    , requestHeaders req
    ]


-- | Like traces: default @http:\/\/localhost:4318\/v1\/metrics@, or 'otlpMetricsEndpoint' if set (path appended when missing).
metricsEndpointUrl :: OTLPExporterConfig -> String
metricsEndpointUrl conf =
  case otlpMetricsEndpoint conf of
    Nothing -> httpHost conf <> "/v1/metrics"
    Just e ->
      if "/v1/" `isInfixOf` e
        then e
        else trimTrailingSlash e <> "/v1/metrics"


trimTrailingSlash :: String -> String
trimTrailingSlash = reverse . dropWhile (== '/') . reverse


anyMetricsToExport :: Vector ResourceMetricsExport -> Bool
anyMetricsToExport batches =
  V.any (\rm -> V.any (not . V.null . scopeMetricsExports) (resourceMetricsScopes rm)) batches


resourceMetricsExportToProto :: ResourceMetricsExport -> PM.ResourceMetrics
resourceMetricsExportToProto ResourceMetricsExport {..} =
  PM.defaultResourceMetrics
    { PM.resourceMetricsResource = Just (materializedResourceToProto resourceMetricsResource)
    , PM.resourceMetricsScopeMetrics = V.map scopeMetricsExportToProto resourceMetricsScopes
    , PM.resourceMetricsSchemaUrl = maybe T.empty T.pack (getMaterializedResourcesSchema resourceMetricsResource)
    }


materializedResourceToProto :: MaterializedResources -> Res.Resource
materializedResourceToProto r =
  let attrs = getMaterializedResourcesAttributes r
  in Res.defaultResource
       { Res.resourceAttributes = attributesToProto attrs
       , Res.resourceDroppedAttributesCount = fromIntegral (getDropped attrs)
       }


scopeMetricsExportToProto :: ScopeMetricsExport -> PM.ScopeMetrics
scopeMetricsExportToProto ScopeMetricsExport {..} =
  PM.defaultScopeMetrics
    { PM.scopeMetricsScope = Just (instrumentationLibraryToProto scopeMetricsScope)
    , PM.scopeMetricsMetrics = V.map metricExportToProto scopeMetricsExports
    , PM.scopeMetricsSchemaUrl = librarySchemaUrl scopeMetricsScope
    }


instrumentationLibraryToProto :: InstrumentationLibrary -> InstrumentationScope
instrumentationLibraryToProto InstrumentationLibrary {..} =
  Common.defaultInstrumentationScope
    { Common.instrumentationScopeName = libraryName
    , Common.instrumentationScopeVersion = libraryVersion
    , Common.instrumentationScopeAttributes = attributesToProto libraryAttributes
    , Common.instrumentationScopeDroppedAttributesCount = fromIntegral (getDropped libraryAttributes)
    }


temporalityToProto :: AggregationTemporality -> PM.AggregationTemporality
temporalityToProto = \case
  AggregationDelta -> PM.AggregationTemporality'AggregationTemporalityDelta
  AggregationCumulative -> PM.AggregationTemporality'AggregationTemporalityCumulative


metricExportToProto :: MetricExport -> PM.Metric
metricExportToProto = \case
  MetricExportSum name desc unit_ _scope monotonic _isInt temp pts ->
    baseMetric name desc unit_ $
      PM.Metric'Data'Sum
        PM.defaultSum
          { PM.sumAggregationTemporality = temporalityToProto temp
          , PM.sumIsMonotonic = monotonic
          , PM.sumDataPoints = V.map sumPointToProto pts
          }
  MetricExportHistogram name desc unit_ _scope temp pts ->
    baseMetric name desc unit_ $
      PM.Metric'Data'Histogram
        PM.defaultHistogram
          { PM.histogramAggregationTemporality = temporalityToProto temp
          , PM.histogramDataPoints = V.map histogramPointToProto pts
          }
  MetricExportExponentialHistogram name desc unit_ _scope temp pts ->
    baseMetric name desc unit_ $
      PM.Metric'Data'ExponentialHistogram
        PM.defaultExponentialHistogram
          { PM.exponentialHistogramAggregationTemporality = temporalityToProto temp
          , PM.exponentialHistogramDataPoints = V.map exponentialHistogramPointToProto pts
          }
  MetricExportGauge name desc unit_ _scope _isInt pts ->
    baseMetric name desc unit_ $
      PM.Metric'Data'Gauge
        PM.defaultGauge
          { PM.gaugeDataPoints = V.map gaugePointToProto pts
          }
  where
    baseMetric name desc unit_ d =
      PM.defaultMetric
        { PM.metricName = name
        , PM.metricDescription = desc
        , PM.metricUnit = unit_
        , PM.metricData = Just d
        }


sumPointToProto :: SumDataPoint -> PM.NumberDataPoint
sumPointToProto SumDataPoint {..} =
  numberDataPointFromValue sumDataPointValue $
    PM.defaultNumberDataPoint
      { PM.numberDataPointAttributes = attributesToProto sumDataPointAttributes
      , PM.numberDataPointStartTimeUnixNano = sumDataPointStartTimeUnixNano
      , PM.numberDataPointTimeUnixNano = sumDataPointTimeUnixNano
      , PM.numberDataPointExemplars = V.map metricExemplarToProto sumDataPointExemplars
      }


gaugePointToProto :: GaugeDataPoint -> PM.NumberDataPoint
gaugePointToProto GaugeDataPoint {..} =
  numberDataPointFromValue gaugeDataPointValue $
    PM.defaultNumberDataPoint
      { PM.numberDataPointAttributes = attributesToProto gaugeDataPointAttributes
      , PM.numberDataPointStartTimeUnixNano = gaugeDataPointStartTimeUnixNano
      , PM.numberDataPointTimeUnixNano = gaugeDataPointTimeUnixNano
      , PM.numberDataPointExemplars = V.map metricExemplarToProto gaugeDataPointExemplars
      }


numberDataPointFromValue :: NumberValue -> PM.NumberDataPoint -> PM.NumberDataPoint
numberDataPointFromValue val dp = case val of
  IntNumber i -> dp {PM.numberDataPointValue = Just (PM.NumberDataPoint'Value'AsInt i)}
  DoubleNumber d -> dp {PM.numberDataPointValue = Just (PM.NumberDataPoint'Value'AsDouble d)}


histogramPointToProto :: HistogramDataPoint -> PM.HistogramDataPoint
histogramPointToProto HistogramDataPoint {..} =
  PM.defaultHistogramDataPoint
    { PM.histogramDataPointAttributes = attributesToProto histogramDataPointAttributes
    , PM.histogramDataPointStartTimeUnixNano = histogramDataPointStartTimeUnixNano
    , PM.histogramDataPointTimeUnixNano = histogramDataPointTimeUnixNano
    , PM.histogramDataPointCount = histogramDataPointCount
    , PM.histogramDataPointSum = Just histogramDataPointSum
    , PM.histogramDataPointBucketCounts = VG.convert histogramDataPointBucketCounts
    , PM.histogramDataPointExplicitBounds = VG.convert histogramDataPointExplicitBounds
    , PM.histogramDataPointMin = histogramDataPointMin
    , PM.histogramDataPointMax = histogramDataPointMax
    , PM.histogramDataPointExemplars = V.map metricExemplarToProto histogramDataPointExemplars
    }


metricExemplarToProto :: MetricExemplar -> PM.Exemplar
metricExemplarToProto MetricExemplar {..} =
  PM.defaultExemplar
    { PM.exemplarTraceId = metricExemplarTraceId
    , PM.exemplarSpanId = metricExemplarSpanId
    , PM.exemplarTimeUnixNano = metricExemplarTimeUnixNano
    , PM.exemplarFilteredAttributes = attributesToProto metricExemplarFilteredAttributes
    , PM.exemplarValue =
        fmap
          ( \case
              IntNumber i -> PM.Exemplar'Value'AsInt i
              DoubleNumber d -> PM.Exemplar'Value'AsDouble d
          )
          metricExemplarValue
    }


exponentialHistogramPointToProto :: ExponentialHistogramDataPoint -> PM.ExponentialHistogramDataPoint
exponentialHistogramPointToProto ExponentialHistogramDataPoint {..} =
  PM.defaultExponentialHistogramDataPoint
    { PM.exponentialHistogramDataPointAttributes = attributesToProto exponentialHistogramDataPointAttributes
    , PM.exponentialHistogramDataPointStartTimeUnixNano = exponentialHistogramDataPointStartTimeUnixNano
    , PM.exponentialHistogramDataPointTimeUnixNano = exponentialHistogramDataPointTimeUnixNano
    , PM.exponentialHistogramDataPointCount = exponentialHistogramDataPointCount
    , PM.exponentialHistogramDataPointSum = exponentialHistogramDataPointSum
    , PM.exponentialHistogramDataPointScale = exponentialHistogramDataPointScale
    , PM.exponentialHistogramDataPointZeroCount = exponentialHistogramDataPointZeroCount
    , PM.exponentialHistogramDataPointPositive =
        if V.null exponentialHistogramDataPointPositiveBucketCounts
          then Nothing
          else
            Just
              PM.defaultExponentialHistogramDataPoint'Buckets
                { PM.exponentialHistogramDataPointBucketsOffset = exponentialHistogramDataPointPositiveOffset
                , PM.exponentialHistogramDataPointBucketsBucketCounts = VG.convert exponentialHistogramDataPointPositiveBucketCounts
                }
    , PM.exponentialHistogramDataPointNegative =
        if V.null exponentialHistogramDataPointNegativeBucketCounts
          then Nothing
          else
            Just
              PM.defaultExponentialHistogramDataPoint'Buckets
                { PM.exponentialHistogramDataPointBucketsOffset = exponentialHistogramDataPointNegativeOffset
                , PM.exponentialHistogramDataPointBucketsBucketCounts = VG.convert exponentialHistogramDataPointNegativeBucketCounts
                }
    , PM.exponentialHistogramDataPointMin = exponentialHistogramDataPointMin
    , PM.exponentialHistogramDataPointMax = exponentialHistogramDataPointMax
    , PM.exponentialHistogramDataPointExemplars = V.map metricExemplarToProto exponentialHistogramDataPointExemplars
    , PM.exponentialHistogramDataPointZeroThreshold = exponentialHistogramDataPointZeroThreshold
    }


attributesToProto :: Attributes -> Vector KeyValue
attributesToProto =
  V.fromList
    . fmap attributeToKeyValue
    . H.toList
    . snd
    . ((,) <$> getCount <*> getAttributeMap)
  where
    primAttributeToAnyValue = \case
      TextAttribute t -> wrapAnyValue (Common.AnyValue'Value'StringValue t)
      BoolAttribute b -> wrapAnyValue (Common.AnyValue'Value'BoolValue b)
      DoubleAttribute d -> wrapAnyValue (Common.AnyValue'Value'DoubleValue d)
      IntAttribute i -> wrapAnyValue (Common.AnyValue'Value'IntValue i)
    attributeToKeyValue :: (Text, Attribute) -> KeyValue
    attributeToKeyValue (k, v) =
      Common.defaultKeyValue
        { Common.keyValueKey = k
        , Common.keyValueValue =
            Just
              ( case v of
                  AttributeValue a -> primAttributeToAnyValue a
                  AttributeArray a ->
                    wrapAnyValue
                      ( Common.AnyValue'Value'ArrayValue
                          Common.defaultArrayValue {Common.arrayValueValues = V.fromList (fmap primAttributeToAnyValue a)}
                      )
              )
        }
    wrapAnyValue :: Common.AnyValue'Value -> Common.AnyValue
    wrapAnyValue v = Common.defaultAnyValue {Common.anyValueValue = Just v}
