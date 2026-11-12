{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- | Prometheus text exposition format (0.0.4) for 'ResourceMetricsExport' batches.

Labels combine resource attributes with point attributes (point wins on key clash).
Instrumentation scope is exported in @otel_scope_@ labels. The scope name
is also exposed as @job@ when non-empty.

Exponential histograms are mapped to classic @histogram@ buckets using OTel-style
@le@ upper bounds derived from scale and bucket index (@2^((i+1)/2^scale)@ for positive indices).

This is intended for scraping or debugging; for production, prefer OTLP metrics.
-}
module OpenTelemetry.Exporter.Prometheus (
  renderPrometheusText,
) where

import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Char (isAsciiLower, isAsciiUpper, isDigit)
import qualified Data.HashMap.Strict as H
import Data.Int (Int32)
import Data.List (intersperse, sortOn)
import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (Builder, fromText, singleton, toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Text.Lazy.Builder.RealFloat (realFloat)
import Data.Vector (Vector)
import qualified Data.Vector as V
import Data.Word (Word64)
import OpenTelemetry.Attributes
import OpenTelemetry.Exporter.Metric (
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExemplar (..),
  MetricExport (..),
  NumberValue (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import OpenTelemetry.Resource (getMaterializedResourcesAttributes)


type Labels = Map.Map Text Text


data MetricFamily = MetricFamily
  { familyDescription :: !Text
  , familyType :: !Text
  , familySamples :: !(Map.Map Labels (Word64, Builder))
  }


-- | Render Prometheus text (lines separated by @\n@, trailing newline).
renderPrometheusText :: Vector ResourceMetricsExport -> Text
renderPrometheusText batches =
  TL.toStrict $ toLazyText $ Map.foldMapWithKey renderFamily families
  where
    families = V.foldl' collectResource Map.empty batches
    renderFamily name family =
      helpLine name (familyDescription family)
        <> typeLine name (familyType family)
        <> foldMap snd (familySamples family)


collectResource :: Map.Map Text MetricFamily -> ResourceMetricsExport -> Map.Map Text MetricFamily
collectResource families ResourceMetricsExport {..} =
  V.foldl' collectScope families resourceMetricsScopes
  where
    resourceLabels = attributesToLabelMap (getMaterializedResourcesAttributes resourceMetricsResource)
    collectScope acc ScopeMetricsExport {..} =
      let name = libraryName scopeMetricsScope
          legacyLabels = if T.null name then resourceLabels else Map.insert "job" name resourceLabels
      in V.foldl' (collectMetric legacyLabels (scopeLabels scopeMetricsScope)) acc scopeMetricsExports


scopeLabels :: InstrumentationLibrary -> [(Text, Text)]
scopeLabels scope =
  [ ("otel_scope_name", libraryName scope)
  , ("otel_scope_version", libraryVersion scope)
  , ("otel_scope_schema_url", librarySchemaUrl scope)
  ]
    <> [ (key, value)
       | (attr, value) <- Map.toList (attributesToLabelMap (libraryAttributes scope))
       , let key = "otel_scope_" <> attr
       , sanitizeLabelName key `notElem` ["otel_scope_name", "otel_scope_version", "otel_scope_schema_url"]
       ]


collectMetric :: Labels -> [(Text, Text)] -> Map.Map Text MetricFamily -> MetricExport -> Map.Map Text MetricFamily
collectMetric baseLabels scope families = \case
  MetricExportSum name desc _unit _lib monotonic _isInt _temp points ->
    let typ = if monotonic then "counter" else "gauge"
        render nm p =
          sample id (sumDataPointTimeUnixNano p) (sumDataPointAttributes p) $
            renderNumberPoint nm (sumDataPointValue p) (sumDataPointExemplars p)
    in addFamily name desc typ render points
  MetricExportGauge name desc _unit _lib _isInt points ->
    let render nm p =
          sample id (gaugeDataPointTimeUnixNano p) (gaugeDataPointAttributes p) $
            renderNumberPoint nm (gaugeDataPointValue p) (gaugeDataPointExemplars p)
    in addFamily name desc "gauge" render points
  MetricExportHistogram name desc _unit _lib _temp points ->
    let render nm p =
          sample (Map.delete "le") (histogramDataPointTimeUnixNano p) (histogramDataPointAttributes p) $
            \labels -> renderHistogramPoint labels nm p
    in addFamily name desc "histogram" render points
  MetricExportExponentialHistogram name desc _unit _lib _temp points ->
    let render nm p =
          sample (Map.delete "le") (exponentialHistogramDataPointTimeUnixNano p) (exponentialHistogramDataPointAttributes p) $
            \labels -> renderExponentialHistogramPoint labels nm p
    in addFamily name desc "histogram" render points
  where
    addFamily rawName description typ render points =
      let name = sanitizeName rawName
          update entry =
            let family = fromMaybe (MetricFamily description typ Map.empty) entry
            in if familyType family == typ
                 then Just family {familySamples = V.foldl' (insertSample name) (familySamples family) points}
                 else entry
          insertSample nm acc point =
            let (labels, time, builder) = render nm point
            in Map.insertWith preferLatest labels (time, builder) acc
      in Map.alter update name families
    preferLatest new old = if fst new > fst old then new else old
    sample prepare time attrs render =
      let labels = prepare $ normalizeLabels (scope <> Map.toList (mergeLabels baseLabels (attributesToLabelMap attrs)))
      in (labels, time, render labels)


renderNumberPoint :: Text -> NumberValue -> Vector MetricExemplar -> Labels -> Builder
renderNumberPoint name value exemplars labels =
  fromText name <> formatLabels labels <> sp <> numberValue value <> exemplarSuffix exemplars <> nl


helpLine :: Text -> Text -> Builder
helpLine nm desc =
  "# HELP " <> fromText nm <> sp <> fromText (escapeHelp desc) <> nl


typeLine :: Text -> Text -> Builder
typeLine nm typ =
  "# TYPE " <> fromText nm <> sp <> fromText typ <> nl


nl :: Builder
nl = singleton '\n'


sp :: Builder
sp = singleton ' '


numberValue :: NumberValue -> Builder
numberValue (IntNumber i) = decimal i
numberValue (DoubleNumber d) = buildDouble d


buildDouble :: Double -> Builder
buildDouble d
  | isNaN d = "NaN"
  | isInfinite d = if d > 0 then "+Inf" else "-Inf"
  | otherwise = realFloat d


doubleToText :: Double -> Text
doubleToText = TL.toStrict . toLazyText . buildDouble


buildWord64 :: Word64 -> Builder
buildWord64 = decimal


byteStringHex :: ByteString -> Builder
byteStringHex = BS.foldl' (\acc w -> acc <> word8Hex w) mempty
  where
    word8Hex w =
      let (hi, lo) = w `divMod` 16
      in singleton (hexDigit hi) <> singleton (hexDigit lo)
    hexDigit n
      | n < 10 = toEnum (fromEnum '0' + fromIntegral n)
      | otherwise = toEnum (fromEnum 'a' + fromIntegral n - 10)


exemplarSuffix :: V.Vector MetricExemplar -> Builder
exemplarSuffix exs
  | V.null exs = mempty
  | otherwise =
      let e = V.head exs
      in " # {trace_id=\""
           <> byteStringHex (metricExemplarTraceId e)
           <> "\",span_id=\""
           <> byteStringHex (metricExemplarSpanId e)
           <> "\"} "
           <> exemplarValue e


exemplarValue :: MetricExemplar -> Builder
exemplarValue e = case metricExemplarValue e of
  Nothing -> "0"
  Just (IntNumber i) -> decimal i
  Just (DoubleNumber d) -> buildDouble d


renderHistogramPoint :: Map.Map Text Text -> Text -> HistogramDataPoint -> Builder
renderHistogramPoint lbls hname p =
  let bounds = histogramDataPointExplicitBounds p
      counts = histogramDataPointBucketCounts p
      cum = V.scanl1' (+) counts
      bucketName = fromText hname <> "_bucket"
      finiteB =
        V.ifoldl'
          ( \acc i b ->
              let c = cum V.! i
              in acc
                   <> bucketName
                   <> formatLabels (Map.insert "le" (doubleToText b) lbls)
                   <> sp
                   <> buildWord64 c
                   <> nl
          )
          mempty
          bounds
  in finiteB
       <> bucketName
       <> formatLabels (Map.insert "le" "+Inf" lbls)
       <> sp
       <> buildWord64 (histogramDataPointCount p)
       <> exemplarSuffix (histogramDataPointExemplars p)
       <> nl
       <> fromText hname
       <> "_sum"
       <> formatLabels lbls
       <> sp
       <> buildDouble (histogramDataPointSum p)
       <> nl
       <> fromText hname
       <> "_count"
       <> formatLabels lbls
       <> sp
       <> buildWord64 (histogramDataPointCount p)
       <> nl


-- | Approximate @le@ upper bound for exponential bucket index (positive side).
leUpperBoundExp :: Int32 -> Int32 -> Double
leUpperBoundExp scale idx =
  2 ** ((fromIntegral idx + 1) / 2 ** fromIntegral scale)


renderExponentialHistogramPoint :: Map.Map Text Text -> Text -> ExponentialHistogramDataPoint -> Builder
renderExponentialHistogramPoint lbls hname p =
  let sc = exponentialHistogramDataPointScale p
      posOff = exponentialHistogramDataPointPositiveOffset p
      posCnt = exponentialHistogramDataPointPositiveBucketCounts p
      negOff = exponentialHistogramDataPointNegativeOffset p
      negCnt = exponentialHistogramDataPointNegativeBucketCounts p
      posCum = if V.null posCnt then V.empty else V.scanl1' (+) posCnt
      negCum = if V.null negCnt then V.empty else V.scanl1' (+) negCnt
      bucketName = fromText hname <> "_bucket"
      buildBuckets off buckets negateLe =
        V.ifoldl'
          ( \acc i c ->
              let idx = off + fromIntegral i
                  le = (if negateLe then negate else id) (leUpperBoundExp sc idx)
              in acc
                   <> bucketName
                   <> formatLabels (Map.insert "le" (doubleToText le) lbls)
                   <> sp
                   <> buildWord64 c
                   <> nl
          )
          mempty
          buckets
      zeroB =
        if exponentialHistogramDataPointZeroCount p == 0
          then mempty
          else
            bucketName
              <> formatLabels (Map.insert "le" "0" lbls)
              <> sp
              <> buildWord64 (exponentialHistogramDataPointZeroCount p)
              <> nl
  in zeroB
       <> buildBuckets negOff negCum True
       <> buildBuckets posOff posCum False
       <> bucketName
       <> formatLabels (Map.insert "le" "+Inf" lbls)
       <> sp
       <> buildWord64 (exponentialHistogramDataPointCount p)
       <> exemplarSuffix (exponentialHistogramDataPointExemplars p)
       <> nl
       <> fromText hname
       <> "_sum"
       <> formatLabels lbls
       <> sp
       <> buildDouble (fromMaybe 0 (exponentialHistogramDataPointSum p))
       <> nl
       <> fromText hname
       <> "_count"
       <> formatLabels lbls
       <> sp
       <> buildWord64 (exponentialHistogramDataPointCount p)
       <> nl


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
  DoubleAttribute d -> TL.toStrict $ toLazyText $ buildDouble d
  IntAttribute i -> TL.toStrict $ toLazyText $ decimal i


escapeLabelValue :: Text -> Text
escapeLabelValue t =
  T.concatMap
    ( \c -> case c of
        '\\' -> "\\\\"
        '"' -> "\\\""
        '\n' -> "\\n"
        _ -> T.singleton c
    )
    t


escapeHelp :: Text -> Text
escapeHelp = T.replace "\n" "\\n" . T.replace "\\" "\\\\"


sanitizeName :: Text -> Text
sanitizeName =
  T.map $ \c ->
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == ':'
      then c
      else '_'


isAsciiLetter :: Char -> Bool
isAsciiLetter c = isAsciiLower c || isAsciiUpper c


isAsciiAlphaNum :: Char -> Bool
isAsciiAlphaNum c = isAsciiLetter c || isDigit c


-- | Concatenate collisions in original key order, including generated scope labels.
normalizeLabels :: [(Text, Text)] -> Labels
normalizeLabels =
  Map.fromListWith (\new old -> old <> ";" <> new)
    . map (\(key, value) -> (sanitizeLabelName key, value))
    . sortOn fst


formatLabels :: Labels -> Builder
formatLabels labels
  | Map.null labels = mempty
  | otherwise =
      let render (key, value) = fromText key <> "=\"" <> fromText (escapeLabelValue value) <> singleton '"'
      in singleton '{'
           <> mconcat (intersperse (singleton ',') (map render (Map.toList labels)))
           <> singleton '}'


sanitizeLabelName :: Text -> Text
sanitizeLabelName t =
  if T.null t
    then "label"
    else
      let c0 = T.head t
          rest = T.tail t
          fixFirst =
            if isAsciiLetter c0 || c0 == '_'
              then T.singleton c0
              else "_"
      in fixFirst <> T.map (\c -> if isAsciiAlphaNum c || c == '_' then c else '_') rest
