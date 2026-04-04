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
import qualified Data.ByteString as BS
import Data.Char (isAsciiLower, isAsciiUpper, isDigit)
import qualified Data.HashMap.Strict as H
import Data.Int (Int32, Int64)
import Data.List (sort)
import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (Builder, fromText, singleton, toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Text.Lazy.Builder.RealFloat (realFloat)
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


-- | Render Prometheus text (lines separated by @\\n@, trailing newline).
renderPrometheusText :: [ResourceMetricsExport] -> Text
renderPrometheusText [] = ""
renderPrometheusText batches = TL.toStrict $ toLazyText $ go batches
  where
    go [] = mempty
    go [b] = renderResource b
    go (b : bs) = renderResource b <> nl <> go bs


renderResource :: ResourceMetricsExport -> Builder
renderResource ResourceMetricsExport {..} =
  let resMap = attributesToLabelMap (getMaterializedResourcesAttributes resourceMetricsResource)
      scopes = V.toList resourceMetricsScopes
  in mconcat $ intersperse nl $ fmap (renderScope resMap) scopes


renderScope :: Map.Map Text Text -> ScopeMetricsExport -> Builder
renderScope resMap ScopeMetricsExport {..} =
  let jobMap =
        if T.null (libraryName scopeMetricsScope)
          then resMap
          else Map.insert "job" (libraryName scopeMetricsScope) resMap
      metrics = V.toList scopeMetricsExports
  in mconcat $ intersperse nl $ fmap (renderMetric jobMap) metrics


intersperse :: a -> [a] -> [a]
intersperse _ [] = []
intersperse _ [x] = [x]
intersperse sep (x : xs) = x : sep : intersperse sep xs


renderMetric :: Map.Map Text Text -> MetricExport -> Builder
renderMetric baseLabels = \case
  MetricExportSum name desc _unit _lib monotonic _isInt _temp pts ->
    let typ = if monotonic then "counter" else "gauge"
        nm = sanitizeName name
    in helpLine nm desc
        <> typeLine nm typ
        <> V.foldl'
          ( \acc p ->
              acc
                <> fromText nm
                <> formatLabels (mergeLabels baseLabels (attributesToLabelMap (sumDataPointAttributes p)))
                <> sp
                <> numberValue (sumDataPointValue p)
                <> exemplarSuffix (sumDataPointExemplars p)
                <> nl
          )
          mempty
          pts
  MetricExportGauge name desc _unit _lib _isInt pts ->
    let nm = sanitizeName name
    in helpLine nm desc
        <> typeLine nm "gauge"
        <> V.foldl'
          ( \acc p ->
              acc
                <> fromText nm
                <> formatLabels (mergeLabels baseLabels (attributesToLabelMap (gaugeDataPointAttributes p)))
                <> sp
                <> numberValue (gaugeDataPointValue p)
                <> exemplarSuffix (gaugeDataPointExemplars p)
                <> nl
          )
          mempty
          pts
  MetricExportHistogram name desc _unit _lib _temp pts ->
    let nm = sanitizeName name
    in helpLine nm desc
        <> typeLine nm "histogram"
        <> V.foldl' (\acc p -> acc <> renderHistogramPoint baseLabels nm p) mempty pts
  MetricExportExponentialHistogram name desc _unit _lib _temp pts ->
    let nm = sanitizeName name
    in helpLine nm desc
        <> typeLine nm "histogram"
        <> V.foldl' (\acc p -> acc <> renderExponentialHistogramPoint baseLabels nm p) mempty pts


helpLine :: Text -> Text -> Builder
helpLine nm desc =
  "# HELP " <> fromText nm <> sp <> fromText (escapeHelp desc) <> nl


typeLine :: Text -> Builder -> Builder
typeLine nm typ =
  "# TYPE " <> fromText nm <> sp <> typ <> nl


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
renderHistogramPoint baseLabels hname p =
  let lbls = mergeLabels baseLabels (attributesToLabelMap (histogramDataPointAttributes p))
      bounds = histogramDataPointExplicitBounds p
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
renderExponentialHistogramPoint baseLabels hname p =
  let lbls = mergeLabels baseLabels (attributesToLabelMap (exponentialHistogramDataPointAttributes p))
      sc = exponentialHistogramDataPointScale p
      posOff = exponentialHistogramDataPointPositiveOffset p
      posCnt = exponentialHistogramDataPointPositiveBucketCounts p
      negOff = exponentialHistogramDataPointNegativeOffset p
      negCnt = exponentialHistogramDataPointNegativeBucketCounts p
      posCum = if V.null posCnt then V.empty else V.scanl1' (+) posCnt
      negCum = if V.null negCnt then V.empty else V.scanl1' (+) negCnt
      bucketName = fromText hname <> "_bucket"
      buildBuckets off cum negate_ =
        V.ifoldl'
          ( \acc i c ->
              let idx = off + fromIntegral i
                  le = (if negate_ then negate else id) (leUpperBoundExp sc idx)
              in acc
                  <> bucketName
                  <> formatLabels (Map.insert "le" (doubleToText le) lbls)
                  <> sp
                  <> buildWord64 c
                  <> nl
          )
          mempty
          cum
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


formatLabels :: Map.Map Text Text -> Builder
formatLabels m
  | Map.null m = mempty
  | otherwise =
      let pairs =
            sort $
              fmap
                (\(k, v) -> (sanitizeLabelName k, escapeLabelValue v))
                (Map.toList m)
      in singleton '{'
          <> mconcat (intersperse (singleton ',') (fmap (\(k, v) -> fromText k <> "=\"" <> fromText v <> singleton '"') pairs))
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
