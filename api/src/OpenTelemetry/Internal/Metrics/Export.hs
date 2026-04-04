{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StrictData #-}

{- | Haskell view of metric data for 'MetricExporter' (see specification/metrics/sdk.md).
-}
module OpenTelemetry.Internal.Metrics.Export (
  AggregationTemporality (..),
  MetricExemplar (..),
  SumDataPoint (..),
  HistogramDataPoint (..),
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  MetricExport (..),
  ScopeMetricsExport (..),
  ResourceMetricsExport (..),
  MetricExporter (..),
  filterAttributesByKeys,
) where

import Data.ByteString (ByteString)
import Data.Int (Int32, Int64)
import Data.Text (Text)
import Data.Vector (Vector)
import Data.Word (Word64)
import GHC.Generics (Generic)
import qualified Data.HashMap.Strict as H
import qualified Data.HashSet as HS
import OpenTelemetry.Attributes (Attributes, getAttributeMap, unsafeAttributesFromListIgnoringLimits)
import OpenTelemetry.Internal.Common.Types (ExportResult, FlushResult, InstrumentationLibrary, ShutdownResult)
import OpenTelemetry.Resource (MaterializedResources)


-- | Export-time aggregation temporality (maps to OTLP 'AggregationTemporality').
data AggregationTemporality
  = AggregationDelta
  | AggregationCumulative
  deriving stock (Eq, Show, Generic)


-- | Exemplar (trace link + optional measurement) for OTLP 'Exemplar'.
data MetricExemplar = MetricExemplar
  { metricExemplarTraceId :: !ByteString
  , metricExemplarSpanId :: !ByteString
  , metricExemplarTimeUnixNano :: !Word64
  , metricExemplarFilteredAttributes :: !Attributes
  , metricExemplarValue :: !(Maybe (Either Int64 Double))
  }
  deriving stock (Eq, Show, Generic)


-- | One sum data point (cumulative or delta depending on reader temporality in SDK).
data SumDataPoint = SumDataPoint
  { sumDataPointStartTimeUnixNano :: !Word64
  , sumDataPointTimeUnixNano :: !Word64
  , sumDataPointValue :: !(Either Int64 Double)
  , sumDataPointAttributes :: !Attributes
  , sumDataPointExemplars :: !(Vector MetricExemplar)
  }
  deriving stock (Eq, Show, Generic)


-- | Histogram bucket counts (explicit boundaries) + sum + count.
data HistogramDataPoint = HistogramDataPoint
  { histogramDataPointStartTimeUnixNano :: !Word64
  , histogramDataPointTimeUnixNano :: !Word64
  , histogramDataPointCount :: !Word64
  , histogramDataPointSum :: !Double
  , histogramDataPointBucketCounts :: !(Vector Word64)
  , histogramDataPointExplicitBounds :: !(Vector Double)
  , histogramDataPointAttributes :: !Attributes
  , histogramDataPointMin :: !(Maybe Double)
  , histogramDataPointMax :: !(Maybe Double)
  , histogramDataPointExemplars :: !(Vector MetricExemplar)
  }
  deriving stock (Eq, Show, Generic)


-- | Exponential histogram data point (OTLP native exponential layout).
data ExponentialHistogramDataPoint = ExponentialHistogramDataPoint
  { exponentialHistogramDataPointStartTimeUnixNano :: !Word64
  , exponentialHistogramDataPointTimeUnixNano :: !Word64
  , exponentialHistogramDataPointCount :: !Word64
  , exponentialHistogramDataPointSum :: !(Maybe Double)
  , exponentialHistogramDataPointScale :: !Int32
  , exponentialHistogramDataPointZeroCount :: !Word64
  , exponentialHistogramDataPointPositiveOffset :: !Int32
  , exponentialHistogramDataPointPositiveBucketCounts :: !(Vector Word64)
  , exponentialHistogramDataPointNegativeOffset :: !Int32
  , exponentialHistogramDataPointNegativeBucketCounts :: !(Vector Word64)
  , exponentialHistogramDataPointAttributes :: !Attributes
  , exponentialHistogramDataPointMin :: !(Maybe Double)
  , exponentialHistogramDataPointMax :: !(Maybe Double)
  , exponentialHistogramDataPointExemplars :: !(Vector MetricExemplar)
  , exponentialHistogramDataPointZeroThreshold :: !Double
  }
  deriving stock (Eq, Show, Generic)


-- | Last-value gauge point.
data GaugeDataPoint = GaugeDataPoint
  { gaugeDataPointStartTimeUnixNano :: !Word64
  , gaugeDataPointTimeUnixNano :: !Word64
  , gaugeDataPointValue :: !(Either Int64 Double)
  , gaugeDataPointAttributes :: !Attributes
  , gaugeDataPointExemplars :: !(Vector MetricExemplar)
  }
  deriving stock (Eq, Show, Generic)


-- | One exported metric (all points share name/unit/description/scope).
data MetricExport
  = MetricExportSum
      { mesName :: !Text
      , mesDescription :: !Text
      , mesUnit :: !Text
      , mesScope :: !InstrumentationLibrary
      , mesMonotonic :: !Bool
      , mesIsInt :: !Bool
      , mesAggregationTemporality :: !AggregationTemporality
      , mesSumPoints :: !(Vector SumDataPoint)
      }
  | MetricExportHistogram
      { mehName :: !Text
      , mehDescription :: !Text
      , mehUnit :: !Text
      , mehScope :: !InstrumentationLibrary
      , mehAggregationTemporality :: !AggregationTemporality
      , mehPoints :: !(Vector HistogramDataPoint)
      }
  | MetricExportExponentialHistogram
      { meehName :: !Text
      , meehDescription :: !Text
      , meehUnit :: !Text
      , meehScope :: !InstrumentationLibrary
      , meehAggregationTemporality :: !AggregationTemporality
      , meehPoints :: !(Vector ExponentialHistogramDataPoint)
      }
  | MetricExportGauge
      { megName :: !Text
      , megDescription :: !Text
      , megUnit :: !Text
      , megScope :: !InstrumentationLibrary
      , megIsInt :: !Bool
      , megGaugePoints :: !(Vector GaugeDataPoint)
      }
  deriving stock (Eq, Show, Generic)


data ScopeMetricsExport = ScopeMetricsExport
  { scopeMetricsScope :: !InstrumentationLibrary
  , scopeMetricsExports :: !(Vector MetricExport)
  }
  deriving stock (Eq, Show, Generic)


data ResourceMetricsExport = ResourceMetricsExport
  { resourceMetricsResource :: !MaterializedResources
  , resourceMetricsScopes :: !(Vector ScopeMetricsExport)
  }
  deriving stock (Eq, Show, Generic)


data MetricExporter = MetricExporter
  { metricExporterExport :: !([ResourceMetricsExport] -> IO ExportResult)
  , metricExporterShutdown :: !(IO ShutdownResult)
  , metricExporterForceFlush :: !(IO FlushResult)
  }


-- | When a view selects attribute keys, drop other keys at export time (series identity unchanged).
filterAttributesByKeys :: Maybe [Text] -> Attributes -> Attributes
filterAttributesByKeys Nothing attrs = attrs
filterAttributesByKeys (Just ks) attrs =
  let keep = HS.fromList ks
      m = getAttributeMap attrs
      m' = H.filterWithKey (\k _ -> k `HS.member` keep) m
   in unsafeAttributesFromListIgnoringLimits (H.toList m')
