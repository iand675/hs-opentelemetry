{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Metrics.Aggregation
 Copyright   :  (c) Ian Duncan, 2024
 License     :  BSD-3
 Description :  Metric aggregation strategies
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Aggregation is the process of combining multiple measurements into exact or
 estimated statistics about the measurements that took place during an interval
 of time, during program execution.

 Different instruments have default aggregations:
 - Counter: Sum aggregation
 - UpDownCounter: Sum aggregation
 - Histogram: Explicit bucket histogram aggregation
 - Gauge: LastValue aggregation
 - ObservableCounter: Sum aggregation
 - ObservableUpDownCounter: Sum aggregation

 This module provides the core aggregation implementations used by the SDK.
-}
module OpenTelemetry.Metrics.Aggregation (
  -- * Aggregation types
  Aggregation (..),
  Accumulator,
  newAccumulator,
  recordMeasurement,
  collectAndReset,

  -- * Sum aggregation
  sumAggregation,

  -- * LastValue aggregation
  lastValueAggregation,

  -- * Histogram aggregation
  histogramAggregation,
  defaultHistogramBuckets,
) where

import Control.Concurrent.STM
import Control.Monad (forM)
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Text (Text)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (Attributes, addAttributes, emptyAttributes)
import OpenTelemetry.Common (Timestamp)
import OpenTelemetry.Internal.Metrics.Types


{- | An Aggregation represents how measurements are combined into metrics.

 Each aggregation defines:
 - How to initialize an accumulator
 - How to record a measurement
 - How to collect accumulated data
-}
data Aggregation = Aggregation
  { aggregationNewAccumulator :: IO Accumulator
  -- ^ Create a new accumulator for this aggregation
  , aggregationRecordMeasurement :: Accumulator -> Double -> Attributes -> Timestamp -> IO ()
  -- ^ Record a measurement with attributes and timestamp
  , aggregationCollectAndReset :: Accumulator -> Timestamp -> IO MetricData
  -- ^ Collect accumulated data and reset the accumulator
  }


{- | An Accumulator stores intermediate aggregated data.

 Different aggregation strategies use different accumulator implementations.
-}
data Accumulator
  = SumAccumulator
      { sumAccumulatorValue :: !(TVar (HashMap Attributes Double))
      , sumAccumulatorName :: !Text
      , sumAccumulatorDescription :: !Text
      , sumAccumulatorUnit :: !Text
      , sumAccumulatorTemporality :: !AggregationTemporality
      , sumAccumulatorIsMonotonic :: !Bool
      }
  | LastValueAccumulator
      { lastValueAccumulatorValue :: !(TVar (HashMap Attributes (Double, Timestamp)))
      , lastValueAccumulatorName :: !Text
      , lastValueAccumulatorDescription :: !Text
      , lastValueAccumulatorUnit :: !Text
      }
  | HistogramAccumulator
      { histogramAccumulatorBuckets :: !(V.Vector Double)
      , histogramAccumulatorData :: !(TVar (HashMap Attributes HistogramAccumulatorData))
      , histogramAccumulatorName :: !Text
      , histogramAccumulatorDescription :: !Text
      , histogramAccumulatorUnit :: !Text
      , histogramAccumulatorTemporality :: !AggregationTemporality
      }


data HistogramAccumulatorData = HistogramAccumulatorData
  { histogramAccumulatorCount :: !Int
  , histogramAccumulatorSum :: !Double
  , histogramAccumulatorMin :: !(Maybe Double)
  , histogramAccumulatorMax :: !(Maybe Double)
  , histogramAccumulatorBucketCounts :: !(V.Vector Int)
  }


{- | Create a new accumulator for the given aggregation.

 @since 0.1.0.0
-}
newAccumulator :: Aggregation -> IO Accumulator
newAccumulator = aggregationNewAccumulator


{- | Record a measurement into an accumulator.

 @since 0.1.0.0
-}
recordMeasurement :: Accumulator -> Double -> Attributes -> Timestamp -> IO ()
recordMeasurement acc value attrs timestamp =
  case acc of
    SumAccumulator {..} -> atomically $ do
      modifyTVar' sumAccumulatorValue $ H.insertWith (+) attrs value
    LastValueAccumulator {..} -> atomically $ do
      modifyTVar' lastValueAccumulatorValue $ H.insert attrs (value, timestamp)
    HistogramAccumulator {..} -> atomically $ do
      let bucketIdx = findBucketIndex histogramAccumulatorBuckets value
          updateHistData Nothing =
            Just $
              HistogramAccumulatorData
                { histogramAccumulatorCount = 1
                , histogramAccumulatorSum = value
                , histogramAccumulatorMin = Just value
                , histogramAccumulatorMax = Just value
                , histogramAccumulatorBucketCounts = V.replicate (V.length histogramAccumulatorBuckets + 1) 0 V.// [(bucketIdx, 1)]
                }
          updateHistData (Just hd) =
            Just $
              hd
                { histogramAccumulatorCount = histogramAccumulatorCount hd + 1
                , histogramAccumulatorSum = histogramAccumulatorSum hd + value
                , histogramAccumulatorMin = case histogramAccumulatorMin hd of
                    Nothing -> Just value
                    Just minVal -> Just (min minVal value)
                , histogramAccumulatorMax = case histogramAccumulatorMax hd of
                    Nothing -> Just value
                    Just maxVal -> Just (max maxVal value)
                , histogramAccumulatorBucketCounts =
                    histogramAccumulatorBucketCounts hd V.// [(bucketIdx, (histogramAccumulatorBucketCounts hd V.! bucketIdx) + 1)]
                }
      modifyTVar' histogramAccumulatorData $ H.alter updateHistData attrs


{- | Collect accumulated data and reset the accumulator.

 @since 0.1.0.0
-}
collectAndReset :: Accumulator -> Timestamp -> IO MetricData
collectAndReset acc timestamp =
  case acc of
    SumAccumulator {..} -> do
      values <- atomically $ do
        current <- readTVar sumAccumulatorValue
        writeTVar sumAccumulatorValue H.empty
        pure current
      let dataPoints =
            V.fromList
              [ DataPoint
                { dataPointAttributes = attrs
                , dataPointTimestamp = timestamp
                , dataPointValue = val
                }
              | (attrs, val) <- H.toList values
              ]
      pure $
        SumData
          { sumName = sumAccumulatorName
          , sumDescription = sumAccumulatorDescription
          , sumUnit = sumAccumulatorUnit
          , sumTemporality = sumAccumulatorTemporality
          , sumIsMonotonic = sumAccumulatorIsMonotonic
          , sumDataPoints = dataPoints
          }
    LastValueAccumulator {..} -> do
      values <- atomically $ do
        current <- readTVar lastValueAccumulatorValue
        writeTVar lastValueAccumulatorValue H.empty
        pure current
      let dataPoints =
            V.fromList
              [ DataPoint
                { dataPointAttributes = attrs
                , dataPointTimestamp = ts
                , dataPointValue = val
                }
              | (attrs, (val, ts)) <- H.toList values
              ]
      pure $
        GaugeData
          { gaugeName = lastValueAccumulatorName
          , gaugeDescription = lastValueAccumulatorDescription
          , gaugeUnit = lastValueAccumulatorUnit
          , gaugeDataPoints = dataPoints
          }
    HistogramAccumulator {..} -> do
      histData <- atomically $ do
        current <- readTVar histogramAccumulatorData
        writeTVar histogramAccumulatorData H.empty
        pure current
      let dataPoints =
            V.fromList
              [ HistogramDataPoint
                { histogramDataPointAttributes = attrs
                , histogramDataPointTimestamp = timestamp
                , histogramDataPointCount = histogramAccumulatorCount hd
                , histogramDataPointSum = histogramAccumulatorSum hd
                , histogramDataPointMin = histogramAccumulatorMin hd
                , histogramDataPointMax = histogramAccumulatorMax hd
                , histogramDataPointBucketCounts = histogramAccumulatorBucketCounts hd
                , histogramDataPointExplicitBounds = histogramAccumulatorBuckets
                }
              | (attrs, hd) <- H.toList histData
              ]
      pure $
        HistogramData
          { histogramName = histogramAccumulatorName
          , histogramDescription = histogramAccumulatorDescription
          , histogramUnit = histogramAccumulatorUnit
          , histogramTemporality = histogramAccumulatorTemporality
          , histogramDataPoints = dataPoints
          }


{- | Find the bucket index for a value in a histogram.

 Returns the index of the first bucket where the value is less than or equal
 to the bucket boundary.
-}
findBucketIndex :: V.Vector Double -> Double -> Int
findBucketIndex bounds value = go 0
  where
    go idx
      | idx >= V.length bounds = idx
      | value <= bounds V.! idx = idx
      | otherwise = go (idx + 1)


{- | Sum aggregation for Counter and UpDownCounter instruments.

 Accumulates the sum of all measurements.

 @since 0.1.0.0
-}
sumAggregation
  :: Text
  -- ^ Instrument name
  -> Text
  -- ^ Instrument description
  -> Text
  -- ^ Instrument unit
  -> AggregationTemporality
  -- ^ Aggregation temporality (delta or cumulative)
  -> Bool
  -- ^ Is monotonic (True for Counter, False for UpDownCounter)
  -> Aggregation
sumAggregation name desc unit temporality isMonotonic =
  Aggregation
    { aggregationNewAccumulator = do
        valueRef <- newTVarIO H.empty
        pure $
          SumAccumulator
            { sumAccumulatorValue = valueRef
            , sumAccumulatorName = name
            , sumAccumulatorDescription = desc
            , sumAccumulatorUnit = unit
            , sumAccumulatorTemporality = temporality
            , sumAccumulatorIsMonotonic = isMonotonic
            }
    , aggregationRecordMeasurement = \acc value attrs _timestamp ->
        case acc of
          SumAccumulator {..} -> atomically $ do
            modifyTVar' sumAccumulatorValue $ H.insertWith (+) attrs value
          _ -> pure () -- Should not happen
    , aggregationCollectAndReset = collectAndReset
    }


{- | LastValue aggregation for Gauge instruments.

 Records the last observed value and its timestamp.

 @since 0.1.0.0
-}
lastValueAggregation
  :: Text
  -- ^ Instrument name
  -> Text
  -- ^ Instrument description
  -> Text
  -- ^ Instrument unit
  -> Aggregation
lastValueAggregation name desc unit =
  Aggregation
    { aggregationNewAccumulator = do
        valueRef <- newTVarIO H.empty
        pure $
          LastValueAccumulator
            { lastValueAccumulatorValue = valueRef
            , lastValueAccumulatorName = name
            , lastValueAccumulatorDescription = desc
            , lastValueAccumulatorUnit = unit
            }
    , aggregationRecordMeasurement = \acc value attrs timestamp ->
        case acc of
          LastValueAccumulator {..} -> atomically $ do
            modifyTVar' lastValueAccumulatorValue $ H.insert attrs (value, timestamp)
          _ -> pure () -- Should not happen
    , aggregationCollectAndReset = collectAndReset
    }


{- | Default histogram bucket boundaries.

 Uses exponential buckets: [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]

 @since 0.1.0.0
-}
defaultHistogramBuckets :: V.Vector Double
defaultHistogramBuckets = V.fromList [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]


{- | Histogram aggregation for Histogram instruments.

 Records a distribution of values across bucket boundaries.

 @since 0.1.0.0
-}
histogramAggregation
  :: Text
  -- ^ Instrument name
  -> Text
  -- ^ Instrument description
  -> Text
  -- ^ Instrument unit
  -> AggregationTemporality
  -- ^ Aggregation temporality
  -> V.Vector Double
  -- ^ Histogram bucket boundaries (must be sorted)
  -> Aggregation
histogramAggregation name desc unit temporality buckets =
  Aggregation
    { aggregationNewAccumulator = do
        dataRef <- newTVarIO H.empty
        pure $
          HistogramAccumulator
            { histogramAccumulatorBuckets = buckets
            , histogramAccumulatorData = dataRef
            , histogramAccumulatorName = name
            , histogramAccumulatorDescription = desc
            , histogramAccumulatorUnit = unit
            , histogramAccumulatorTemporality = temporality
            }
    , aggregationRecordMeasurement = recordMeasurement
    , aggregationCollectAndReset = collectAndReset
    }
