{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Metric.View
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  Metric views (spec: @specification/metrics/sdk.md@): instrument selection and aggregation overrides.
Stability   :  experimental

Selector criteria are additive (AND): an instrument must match /all/ provided criteria.
-}
module OpenTelemetry.Metric.View (
  View (..),
  ViewSelector (..),
  ViewAggregation (..),
  MeterScope,
  findMatchingView,
  findAllMatchingViews,
  viewOverrideName,
  viewOverrideDescription,

  -- * Re-exports for convenience
  MetricsExemplarFilter (..),
) where

import Data.Int (Int32)
import Data.List (filter, find)
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Environment (MetricsExemplarFilter (..))
import OpenTelemetry.Metric.Core (InstrumentKind (..))


{- | Select instruments by name pattern, kind, unit, and meter scope.

All provided criteria are ANDed (spec: "criteria SHOULD be treated as additive").

@since 0.0.1.0
-}
data ViewSelector = ViewSelector
  { viewInstrumentNamePattern :: !Text
  -- ^ Exact name, @*@ for all, or @prefix*@ suffix-wildcard.
  , viewInstrumentKind :: !(Maybe InstrumentKind)
  , viewInstrumentUnit :: !(Maybe Text)
  , viewMeterName :: !(Maybe Text)
  , viewMeterVersion :: !(Maybe Text)
  , viewMeterSchemaUrl :: !(Maybe Text)
  }


{- | Aggregation override or drop.

@since 0.0.1.0
-}
data ViewAggregation
  = ViewAggregationDefault
  | ViewAggregationExplicitBucketHistogram ![Double]
  | ViewAggregationExponentialHistogram !Int32
  | -- | Force Sum aggregation (for counters and up-down counters).
    ViewAggregationSum
  | -- | Force Last Value aggregation (for gauges).
    ViewAggregationLastValue
  | ViewAggregationDrop
  deriving stock (Eq)


{- | One view (first matching view in the provider list wins for single-match queries).

@since 0.0.1.0
-}
data View = View
  { viewSelector :: !ViewSelector
  , viewAggregation :: !ViewAggregation
  , viewAttributeKeys :: !(Maybe [Text])
  , viewName :: !(Maybe Text)
  , viewDescription :: !(Maybe Text)
  , viewExemplarFilter :: !(Maybe MetricsExemplarFilter)
  {- ^ Per-view exemplar filter override. When set, takes precedence over
  the global provider-level filter for instruments matched by this view.
  -}
  }


{- | Scope info passed during matching (avoids importing InstrumentationLibrary into this module).

@since 0.0.1.0
-}
type MeterScope = (Text, Text, Text)


matchesName :: Text -> Text -> Bool
matchesName pat n
  | pat == "*" = True
  | "*" `T.isSuffixOf` pat = T.isPrefixOf (T.toLower (T.init pat)) (T.toLower n)
  | otherwise = T.toLower pat == T.toLower n


matchesSelector :: ViewSelector -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> Bool
matchesSelector sel kind name mUnit (scopeName, scopeVer, scopeSchema) =
  matchesName (viewInstrumentNamePattern sel) name
    && maybe True (== kind) (viewInstrumentKind sel)
    && maybe True (\u -> mUnit == Just u) (viewInstrumentUnit sel)
    && maybe True (== scopeName) (viewMeterName sel)
    && maybe True (== scopeVer) (viewMeterVersion sel)
    && maybe True (== scopeSchema) (viewMeterSchemaUrl sel)


{- | First matching view with full selector criteria.

@since 0.0.1.0
-}
findMatchingView :: [View] -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> Maybe View
findMatchingView views kind name mUnit scope =
  find (\v -> matchesSelector (viewSelector v) kind name mUnit scope) views


{- | All matching views (spec: each produces a separate metric stream).

@since 0.0.1.0
-}
findAllMatchingViews :: [View] -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> [View]
findAllMatchingViews views kind name mUnit scope =
  Data.List.filter (\v -> matchesSelector (viewSelector v) kind name mUnit scope) views


-- | @since 0.0.1.0
viewOverrideName :: [View] -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> Text
viewOverrideName views kind name mUnit scope =
  case findMatchingView views kind name mUnit scope of
    Just v -> case viewName v of
      Just n -> n
      Nothing -> name
    Nothing -> name


-- | @since 0.0.1.0
viewOverrideDescription :: [View] -> InstrumentKind -> Text -> Maybe Text -> Maybe Text -> MeterScope -> Maybe Text
viewOverrideDescription views kind name mUnit mDesc scope =
  case findMatchingView views kind name mUnit scope of
    Just v -> case viewDescription v of
      Just d -> Just d
      Nothing -> mDesc
    Nothing -> mDesc
