{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- | Prometheus text exposition format (0.0.4) for 'ResourceMetricsExport' batches.

Labels combine resource attributes with point attributes (point wins on key clash).
Instrumentation scope name is exposed as @job@ when non-empty.

Exponential histograms are mapped to classic @histogram@ buckets using OTel-style
@le@ upper bounds derived from scale and bucket index (@2^((i+1)/2^scale)@ for positive indices).

This is intended for scraping or debugging; for production, prefer OTLP metrics.
-}
module OpenTelemetry.Exporter.Prometheus (
  renderPrometheusText,
) where

import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import Data.Char (isAlphaNum)
import qualified Data.HashMap.Strict as H
import Data.Int (Int32, Int64)
import Data.List (sort)
import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Attributes
import OpenTelemetry.Exporter.Metric (
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExemplar (..),
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import OpenTelemetry.Resource (getMaterializedResourcesAttributes)
import Text.Printf (printf)


-- | Render Prometheus text (lines separated by @\\n@, trailing newline).
renderPrometheusText :: [ResourceMetricsExport] -> Text
renderPrometheusText batches =
  T.intercalate "\n" $ filter (not . T.null) $ fmap renderResource batches


renderResource :: ResourceMetricsExport -> Text
renderResource ResourceMetricsExport {..} =
  let resMap = attributesToLabelMap (getMaterializedResourcesAttributes resourceMetricsResource)
  in T.intercalate "\n" $ fmap (renderScope resMap) $ V.toList resourceMetricsScopes


renderScope :: Map.Map Text Text -> ScopeMetricsExport -> Text
renderScope resMap ScopeMetricsExport {..} =
  let jobMap =
        if T.null (libraryName scopeMetricsScope)
          then resMap
          else Map.insert "job" (libraryName scopeMetricsScope) resMap
  in T.intercalate "\n" $ fmap (renderMetric jobMap) $ V.toList scopeMetricsExports


renderMetric :: Map.Map Text Text -> MetricExport -> Text
renderMetric baseLabels = \case
  MetricExportSum name desc _unit _lib monotonic _isInt _temp pts ->
    let typ = if monotonic then "counter" else "gauge"
        nm = sanitizeName name
        helpLine = mconcat ["# HELP ", nm, " ", escapeHelp desc]
        typeLine = mconcat ["# TYPE ", nm, " ", typ]
        lines_ =
          fmap
            ( \p ->
                T.concat
                  [ nm
                  , formatLabels (mergeLabels baseLabels (attributesToLabelMap (sumDataPointAttributes p)))
                  , " "
                  , either (T.pack . show) showDouble (sumDataPointValue p)
                  , sumPointExemplarSuffix p
                  ]
            )
            (V.toList pts)
    in T.unlines $ helpLine : typeLine : lines_
  MetricExportGauge name desc _unit _lib _isInt pts ->
    let nm = sanitizeName name
        helpLine = mconcat ["# HELP ", nm, " ", escapeHelp desc]
        typeLine = mconcat ["# TYPE ", nm, " gauge"]
        lines_ =
          fmap
            ( \p ->
                T.concat
                  [ nm
                  , formatLabels (mergeLabels baseLabels (attributesToLabelMap (gaugeDataPointAttributes p)))
                  , " "
                  , either (T.pack . show) showDouble (gaugeDataPointValue p)
                  , gaugePointExemplarSuffix p
                  ]
            )
            (V.toList pts)
    in T.unlines $ helpLine : typeLine : lines_
  MetricExportHistogram name desc _unit _lib _temp pts ->
    let nm = sanitizeName name
        helpLine = mconcat ["# HELP ", nm, " ", escapeHelp desc]
        typeLine = mconcat ["# TYPE ", nm, " histogram"]
        lines_ = concatMap (renderHistogramPoint baseLabels nm) (V.toList pts)
    in T.unlines $ helpLine : typeLine : lines_
  MetricExportExponentialHistogram name desc _unit _lib _temp pts ->
    let nm = sanitizeName name
        helpLine = mconcat ["# HELP ", nm, " ", escapeHelp desc]
        typeLine = mconcat ["# TYPE ", nm, " histogram"]
        lines_ = concatMap (renderExponentialHistogramPoint baseLabels nm) (V.toList pts)
    in T.unlines $ helpLine : typeLine : lines_


byteStringHex :: ByteString -> Text
byteStringHex = T.pack . concatMap (printf "%02x") . B.unpack


exemplarComment :: MetricExemplar -> Text
exemplarComment e =
  T.concat
    [ "{trace_id=\""
    , byteStringHex (metricExemplarTraceId e)
    , "\",span_id=\""
    , byteStringHex (metricExemplarSpanId e)
    , "\"}"
    ]


exemplarValueText :: MetricExemplar -> Text
exemplarValueText e = case metricExemplarValue e of
  Nothing -> "0"
  Just (Left i) -> T.pack (show i)
  Just (Right d) -> showDouble d


sumPointExemplarSuffix :: SumDataPoint -> Text
sumPointExemplarSuffix p =
  if V.null (sumDataPointExemplars p)
    then ""
    else
      let e = V.head (sumDataPointExemplars p)
      in T.concat [" # ", exemplarComment e, " ", exemplarValueText e]


gaugePointExemplarSuffix :: GaugeDataPoint -> Text
gaugePointExemplarSuffix p =
  if V.null (gaugeDataPointExemplars p)
    then ""
    else
      let e = V.head (gaugeDataPointExemplars p)
      in T.concat [" # ", exemplarComment e, " ", exemplarValueText e]


renderHistogramPoint :: Map.Map Text Text -> Text -> HistogramDataPoint -> [Text]
renderHistogramPoint baseLabels hname p =
  let lbls = mergeLabels baseLabels (attributesToLabelMap (histogramDataPointAttributes p))
      bounds = histogramDataPointExplicitBounds p
      counts = histogramDataPointBucketCounts p
      cum = V.scanl1' (+) counts
      finiteLines =
        fmap
          ( \(b, c) ->
              T.concat
                [ hname
                , "_bucket"
                , formatLabels (Map.insert "le" (T.pack (show b)) lbls)
                , " "
                , T.pack (show c)
                ]
          )
          (zip (V.toList bounds) (V.toList $ V.take (V.length bounds) cum))
      infLine =
        T.concat
          [ hname
          , "_bucket"
          , formatLabels (Map.insert "le" "+Inf" lbls)
          , " "
          , T.pack (show (histogramDataPointCount p))
          , histExemplarSuffix p
          ]
      sumLine =
        T.concat
          [ hname
          , "_sum"
          , formatLabels lbls
          , " "
          , showDouble (histogramDataPointSum p)
          ]
      countLine =
        T.concat
          [ hname
          , "_count"
          , formatLabels lbls
          , " "
          , T.pack (show (histogramDataPointCount p))
          ]
  in finiteLines ++ [infLine, sumLine, countLine]


histExemplarSuffix :: HistogramDataPoint -> Text
histExemplarSuffix p =
  if V.null (histogramDataPointExemplars p)
    then ""
    else
      let e = V.head (histogramDataPointExemplars p)
      in T.concat [" # ", exemplarComment e, " ", exemplarValueText e]


-- | Approximate @le@ upper bound for exponential bucket index (positive side).
leUpperBoundExp :: Int32 -> Int32 -> Double
leUpperBoundExp scale idx =
  2 ** ((fromIntegral idx + 1) / 2 ** fromIntegral scale)


renderExponentialHistogramPoint :: Map.Map Text Text -> Text -> ExponentialHistogramDataPoint -> [Text]
renderExponentialHistogramPoint baseLabels hname p =
  let lbls = mergeLabels baseLabels (attributesToLabelMap (exponentialHistogramDataPointAttributes p))
      sc = exponentialHistogramDataPointScale p
      posOff = exponentialHistogramDataPointPositiveOffset p
      posCnt = exponentialHistogramDataPointPositiveBucketCounts p
      negOff = exponentialHistogramDataPointNegativeOffset p
      negCnt = exponentialHistogramDataPointNegativeBucketCounts p
      posCum = if V.null posCnt then V.empty else V.scanl1' (+) posCnt
      negCum = if V.null negCnt then V.empty else V.scanl1' (+) negCnt
      posPairs =
        fmap
          ( \(i, c) ->
              let idx = posOff + fromIntegral (i :: Int)
                  le = leUpperBoundExp sc idx
              in T.concat
                  [ hname
                  , "_bucket"
                  , formatLabels (Map.insert "le" (T.pack (show le)) lbls)
                  , " "
                  , T.pack (show c)
                  ]
          )
          (zip [0 :: Int ..] (V.toList posCum))
      negPairs =
        fmap
          ( \(i, c) ->
              let idx = negOff + fromIntegral (i :: Int)
                  le = negate (leUpperBoundExp sc idx)
              in T.concat
                  [ hname
                  , "_bucket"
                  , formatLabels (Map.insert "le" (T.pack (show le)) lbls)
                  , " "
                  , T.pack (show c)
                  ]
          )
          (zip [0 :: Int ..] (V.toList negCum))
      zeroLine =
        if exponentialHistogramDataPointZeroCount p == 0
          then []
          else
            [ T.concat
                [ hname
                , "_bucket"
                , formatLabels (Map.insert "le" "0" lbls)
                , " "
                , T.pack (show (exponentialHistogramDataPointZeroCount p))
                ]
            ]
      infLine =
        T.concat
          [ hname
          , "_bucket"
          , formatLabels (Map.insert "le" "+Inf" lbls)
          , " "
          , T.pack (show (exponentialHistogramDataPointCount p))
          , expHistExemplarSuffix p
          ]
      sumLine =
        T.concat
          [ hname
          , "_sum"
          , formatLabels lbls
          , " "
          , showDouble (fromMaybe 0 (exponentialHistogramDataPointSum p))
          ]
      countLine =
        T.concat
          [ hname
          , "_count"
          , formatLabels lbls
          , " "
          , T.pack (show (exponentialHistogramDataPointCount p))
          ]
  in zeroLine ++ negPairs ++ posPairs ++ [infLine, sumLine, countLine]


expHistExemplarSuffix :: ExponentialHistogramDataPoint -> Text
expHistExemplarSuffix p =
  if V.null (exponentialHistogramDataPointExemplars p)
    then ""
    else
      let e = V.head (exponentialHistogramDataPointExemplars p)
      in T.concat [" # ", exemplarComment e, " ", exemplarValueText e]


mergeLabels :: Map.Map Text Text -> Map.Map Text Text -> Map.Map Text Text
mergeLabels resource point = Map.union point resource


attributesToLabelMap :: Attributes -> Map.Map Text Text
attributesToLabelMap attrs =
  Map.fromList $ mapMaybe pair $ H.toList $ getAttributeMap attrs
  where
    pair (k, v) = case attributeToLabelText v of
      Nothing -> Nothing
      Just t -> Just (k, t)


attributeToLabelText :: Attribute -> Maybe Text
attributeToLabelText = \case
  AttributeValue p -> Just (primitiveToText p)
  AttributeArray _ -> Nothing


primitiveToText :: PrimitiveAttribute -> Text
primitiveToText = \case
  TextAttribute t -> t
  BoolAttribute b -> if b then "true" else "false"
  DoubleAttribute d -> showDouble d
  IntAttribute i -> T.pack (show (i :: Int64))


showDouble :: Double -> Text
showDouble d = T.pack (show d)


escapeLabelValue :: Text -> Text
escapeLabelValue t =
  T.concatMap
    ( \c ->
        if c == '\\'
          then "\\\\"
          else
            if c == '"'
              then "\\\""
              else T.singleton c
    )
    t


escapeHelp :: Text -> Text
escapeHelp = T.replace "\\" "\\\\" . T.replace "\n" "\\n"


sanitizeName :: Text -> Text
sanitizeName =
  T.map $ \c ->
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == ':'
      then c
      else '_'


formatLabels :: Map.Map Text Text -> Text
formatLabels m =
  if Map.null m
    then ""
    else
      let pairs =
            sort $
              fmap
                ( \(k, v) ->
                    (sanitizeLabelName k, escapeLabelValue v)
                )
                (Map.toList m)
          inner = T.intercalate "," $ fmap (\(k, v) -> T.concat [k, "=\"", v, "\""]) pairs
      in T.concat ["{", inner, "}"]


sanitizeLabelName :: Text -> Text
sanitizeLabelName t =
  if T.null t
    then "label"
    else
      let c0 = T.head t
          rest = T.tail t
          fixFirst =
            if isAlphaNum c0 || c0 == '_'
              then T.singleton c0
              else "_"
      in fixFirst <> T.map (\c -> if isAlphaNum c || c == '_' then c else '_') rest
