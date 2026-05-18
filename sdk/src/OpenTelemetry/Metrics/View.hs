{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Metric views (spec: @specification/metrics/sdk.md@): instrument selection and aggregation overrides.

Selector criteria are additive (AND): an instrument must match /all/ provided criteria.
-}
module OpenTelemetry.Metrics.View (
  View (..),
  ViewSelector (..),
  ViewAggregation (..),
  findMatchingView,
  findAllMatchingViews,
  viewOverrideName,
  viewOverrideDescription,
) where

import Data.Int (Int32)
import Data.List (filter, find)
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Metrics (InstrumentKind (..))


{- | Select instruments by name pattern, kind, unit, and meter scope.

All provided criteria are ANDed (spec: "criteria SHOULD be treated as additive").
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


-- | Aggregation override or drop.
data ViewAggregation
  = ViewAggregationDefault
  | ViewAggregationExplicitBucketHistogram ![Double]
  | ViewAggregationExponentialHistogram !Int32
  | ViewAggregationDrop
  deriving stock (Eq)


-- | One view (first matching view in the provider list wins for single-match queries).
data View = View
  { viewSelector :: !ViewSelector
  , viewAggregation :: !ViewAggregation
  , viewAttributeKeys :: !(Maybe [Text])
  , viewName :: !(Maybe Text)
  , viewDescription :: !(Maybe Text)
  }


-- | Scope info passed during matching (avoids importing InstrumentationLibrary into this module).
type MeterScope = (Text, Text, Text)


matchesName :: Text -> Text -> Bool
matchesName pat n
  | pat == "*" = True
  | "*" `T.isSuffixOf` pat = T.isPrefixOf (T.init pat) n
  | otherwise = T.toLower pat == T.toLower n


matchesSelector :: ViewSelector -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> Bool
matchesSelector sel kind name mUnit (scopeName, scopeVer, scopeSchema) =
  matchesName (viewInstrumentNamePattern sel) name
    && maybe True (== kind) (viewInstrumentKind sel)
    && maybe True (\u -> mUnit == Just u) (viewInstrumentUnit sel)
    && maybe True (== scopeName) (viewMeterName sel)
    && maybe True (== scopeVer) (viewMeterVersion sel)
    && maybe True (== scopeSchema) (viewMeterSchemaUrl sel)


-- | First matching view (legacy single-match for backward compat).
findMatchingView :: [View] -> InstrumentKind -> Text -> Maybe View
findMatchingView views kind name =
  find (\v -> matchesSelector (viewSelector v) kind name Nothing ("", "", "")) views


-- | All matching views (spec: each produces a separate metric stream).
findAllMatchingViews :: [View] -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> [View]
findAllMatchingViews views kind name mUnit scope =
  Data.List.filter (\v -> matchesSelector (viewSelector v) kind name mUnit scope) views


viewOverrideName :: [View] -> InstrumentKind -> Text -> Text
viewOverrideName views kind name =
  case findMatchingView views kind name of
    Just v -> case viewName v of
      Just n -> n
      Nothing -> name
    Nothing -> name


viewOverrideDescription :: [View] -> InstrumentKind -> Text -> Maybe Text -> Maybe Text
viewOverrideDescription views kind name mDesc =
  case findMatchingView views kind name of
    Just v -> case viewDescription v of
      Just d -> Just d
      Nothing -> mDesc
    Nothing -> mDesc
