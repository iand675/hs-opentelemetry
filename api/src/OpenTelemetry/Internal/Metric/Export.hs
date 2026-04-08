{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StrictData #-}

{- |
Module      : OpenTelemetry.Internal.Metric.Export
Copyright   : (c) Ian Duncan, 2024-2026
License     : BSD-3
Description : Export data types for metric data points and aggregations.
Stability   : experimental

Defines the Haskell representation of metric data as seen by exporters:
sum/gauge/histogram/exponential-histogram data points, exemplars, resource
and scope wrappers. Not intended for direct import; use
"OpenTelemetry.Exporter.Metric" instead.

Spec: <https://opentelemetry.io/docs/specs/otel/metrics/sdk/>
-}
module OpenTelemetry.Internal.Metric.Export (
  AggregationTemporality (..),
  NumberValue (..),
  OptionalDouble (..),
  toMaybeDouble,
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
  complementAttributesByKeys,
) where

import Data.ByteString (ByteString)
import qualified Data.HashMap.Strict as H
import qualified Data.HashSet as HS
import Data.Int (Int32, Int64)
import Data.Text (Text)
import Data.Vector (Vector)
import Data.Word (Word64)
import GHC.Generics (Generic)
import OpenTelemetry.Attributes (Attributes, emptyAttributes, getAttributeMap, unsafeAttributesFromMapIgnoringLimits)
import OpenTelemetry.Internal.Common.Types (ExportResult, FlushResult, InstrumentationLibrary, ShutdownResult)
import OpenTelemetry.Resource (MaterializedResources)


-- | Export-time aggregation temporality (maps to OTLP 'AggregationTemporality').
--
-- @since 0.0.1.0
data AggregationTemporality
  = AggregationDelta
  | AggregationCumulative
  deriving stock (Eq, Show, Generic)


{- | A numeric metric value, either integral or floating-point.
Uses UNPACK to avoid the extra indirection that 'Either' 'Int64' 'Double' incurs.

@since 0.0.1.0
-}
data NumberValue
  = IntNumber {-# UNPACK #-} !Int64
  | DoubleNumber {-# UNPACK #-} !Double
  deriving stock (Eq, Show, Generic)


{- | An optional 'Double', using UNPACK to avoid the extra box that @Maybe Double@ incurs.
2 words for 'SomeDouble' vs 4 for @Just (D# x)@.

@since 0.0.1.0
-}
data OptionalDouble
  = NoDouble
  | SomeDouble {-# UNPACK #-} !Double
  deriving stock (Eq, Show, Generic)


-- | Convert to the standard @Maybe Double@ (e.g. for OTLP export).
--
-- @since 0.0.1.0
toMaybeDouble :: OptionalDouble -> Maybe Double
toMaybeDouble NoDouble = Nothing
toMaybeDouble (SomeDouble d) = Just d
{-# INLINE toMaybeDouble #-}


-- | Exemplar (trace link + optional measurement) for OTLP 'Exemplar'.
--
-- @since 0.0.1.0
data MetricExemplar = MetricExemplar
  { metricExemplarTraceId :: !ByteString
  , metricExemplarSpanId :: !ByteString
  , metricExemplarTimeUnixNano :: !Word64
  , metricExemplarFilteredAttributes :: !Attributes
  , metricExemplarValue :: !(Maybe NumberValue)
  }
  deriving stock (Eq, Show, Generic)


-- | One sum data point (cumulative or delta depending on reader temporality in SDK).
--
-- @since 0.0.1.0
data SumDataPoint = SumDataPoint
  { sumDataPointStartTimeUnixNano :: !Word64
  , sumDataPointTimeUnixNano :: !Word64
  , sumDataPointValue :: !NumberValue
  , sumDataPointAttributes :: !Attributes
  , sumDataPointExemplars :: !(Vector MetricExemplar)
  }
  deriving stock (Eq, Show, Generic)


-- | Histogram bucket counts (explicit boundaries) + sum + count.
--
-- @since 0.0.1.0
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
--
-- @since 0.0.1.0
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
--
-- @since 0.0.1.0
data GaugeDataPoint = GaugeDataPoint
  { gaugeDataPointStartTimeUnixNano :: !Word64
  , gaugeDataPointTimeUnixNano :: !Word64
  , gaugeDataPointValue :: !NumberValue
  , gaugeDataPointAttributes :: !Attributes
  , gaugeDataPointExemplars :: !(Vector MetricExemplar)
  }
  deriving stock (Eq, Show, Generic)


-- | One exported metric (all points share name/unit/description/scope).
--
-- @since 0.0.1.0
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


-- | @since 0.0.1.0
data ScopeMetricsExport = ScopeMetricsExport
  { scopeMetricsScope :: !InstrumentationLibrary
  , scopeMetricsExports :: !(Vector MetricExport)
  }
  deriving stock (Eq, Show, Generic)


-- | @since 0.0.1.0
data ResourceMetricsExport = ResourceMetricsExport
  { resourceMetricsResource :: !MaterializedResources
  , resourceMetricsScopes :: !(Vector ScopeMetricsExport)
  }
  deriving stock (Eq, Show, Generic)


-- | @since 0.0.1.0
data MetricExporter = MetricExporter
  { metricExporterExport :: !(Vector ResourceMetricsExport -> IO ExportResult)
  , metricExporterShutdown :: !(IO ShutdownResult)
  , metricExporterForceFlush :: !(IO FlushResult)
  }


{- | When a view selects attribute keys, drop other keys at export time
(series identity unchanged).

The 'HashSet' should be pre-built at instrument creation time so that
this function avoids allocating a new set on every data point.

@since 0.0.1.0
-}
filterAttributesByKeys :: Maybe (HS.HashSet Text) -> Attributes -> Attributes
filterAttributesByKeys Nothing attrs = attrs
filterAttributesByKeys (Just keep) attrs =
  let m = getAttributeMap attrs
      m' = H.filterWithKey (\k _ -> k `HS.member` keep || k == "otel.metric.overflow") m
  in unsafeAttributesFromMapIgnoringLimits m'


{- | Complement of 'filterAttributesByKeys': returns attributes whose keys
are NOT in the export set. Used for exemplar @filtered_attributes@ per spec
§ metrics/sdk.md "Exemplar": "the set of attributes that were filtered out
by the aggregator".

The 'HashSet' should be pre-built at instrument creation time so that
this function avoids allocating a new set on every data point.

@since 0.0.1.0
-}
complementAttributesByKeys :: Maybe (HS.HashSet Text) -> Attributes -> Attributes
complementAttributesByKeys Nothing _ = emptyAttributes
complementAttributesByKeys (Just keep) attrs =
  let m = getAttributeMap attrs
      m' = H.filterWithKey (\k _ -> not (k `HS.member` keep)) m
  in unsafeAttributesFromMapIgnoringLimits m'
