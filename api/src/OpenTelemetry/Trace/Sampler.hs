{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE RecordWildCards #-}

{- |
 Module      :  OpenTelemetry.Trace.Sampler
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Sampling strategies for reducing tracing overhead
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 This module provides several built-in sampling strategies, as well as the ability to define custom samplers.

 Sampling is the concept of selecting a few elements from a large collection and learning about the entire collection by extrapolating from the selected set. It's widely used throughout the world whenever trying to tackle a problem of scale: for example, a survey assumes that by asking a small group of people a set of questions, you can learn something about the opinions of the entire populace.

 While it's nice to believe that every event is precious, the reality of monitoring high volume production infrastructure is that there are some attributes to events that make them more interesting than the rest. Failures are often more interesting than successes! Rare events are more interesting than common events! Capturing some traffic from all customers can be better than capturing all traffic from some customers.

 Sampling as a basic technique for instrumentation is no different. By recording information about a representative subset of requests flowing through a system, you can learn about the overall performance of the system. And as with surveys and air monitoring, the way you choose your representative set (the sample set) can greatly influence the accuracy of your results.

 Sampling is widespread in observability systems because it lowers the cost of producing, collecting, and analyzing data in systems anywhere cost is a concern. Developers and operators in an observability system apply or attach key=value properties to observability data, spans and metrics, and we use these properties to investigate hypotheses about our systems after the fact. It is interesting to look at how sampling impacts our ability to analyze observability data, using key=value restrictions for some keys and grouping the output based on other keys.

 Sampling schemes let observability systems collect examples of data that are not merely exemplary, but also representative. Sampling schemes compute a set of representative items and, in doing so, score each item with what is commonly called the item's "sampling rate." A sampling rate of 10 indicates that the item represents an estimated 10 individuals in the original data set.
-}
module OpenTelemetry.Trace.Sampler (
  -- * Types
  Sampler (..),
  SamplingResult (..),
  SamplingDecision (..),
  ParentBasedOptions (..),

  -- * Running samplers
  shouldSample,
  getDescription,

  -- * Built-in samplers
  alwaysOn,
  alwaysOff,
  traceIdRatioBased,
  parentBased,
  parentBasedOptions,
  alwaysRecord,
) where

import Data.Bits
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (toLazyText)
import Data.Text.Lazy.Builder.RealFloat (realFloat)
import Data.Word (Word64, byteSwap64)
import GHC.ByteOrder (ByteOrder (..), targetByteOrder)
import OpenTelemetry.Attributes (toAttribute)
import OpenTelemetry.Context
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary)
import OpenTelemetry.Internal.Trace.Id (TraceId (..))
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.TraceState as TraceState


{- | Returns @RecordAndSample@ always.

 Description returns AlwaysOnSampler.

 @since 0.1.0.0
-}
alwaysOn :: Sampler
alwaysOn = AlwaysOnSampler


{- | Returns @Drop@ always.

 Description returns AlwaysOffSampler.

 @since 0.1.0.0
-}
alwaysOff :: Sampler
alwaysOff = AlwaysOffSampler


{- | The TraceIdRatioBased ignores the parent SampledFlag. To respect the parent SampledFlag,
 the TraceIdRatioBased should be used as a delegate of the @parentBased@ sampler specified below.

 Description returns a string of the form "TraceIdRatioBased{RATIO}" with RATIO replaced with the Sampler
 instance's trace sampling ratio represented as a decimal number.

 @since 0.1.0.0
-}
traceIdRatioBased :: Double -> Sampler
traceIdRatioBased fraction =
  TraceIdRatioSampler safeFraction traceIdUpperBound sampleRate
  where
    safeFraction = max 0 (min 1 fraction)
    sampleRate =
      if safeFraction > 0
        then toAttribute ((round (1 / safeFraction)) :: Int)
        else toAttribute (0 :: Int)
    traceIdUpperBound = floor (safeFraction * fromIntegral ((1 :: Word64) `shiftL` 63)) :: Word64


{- | This is a composite sampler. ParentBased helps distinguish between the following cases:

 No parent (root span).

 Remote parent (SpanContext.IsRemote() == true) with SampledFlag equals true

 Remote parent (SpanContext.IsRemote() == true) with SampledFlag equals false

 Local parent (SpanContext.IsRemote() == false) with SampledFlag equals true

 Local parent (SpanContext.IsRemote() == false) with SampledFlag equals false

 @since 0.1.0.0
-}

{- | A smart constructor for 'ParentBasedOptions' with reasonable starting
 defaults.

 @since 0.1.0.0
-}
parentBasedOptions
  :: Sampler
  -- ^ Root sampler
  -> ParentBasedOptions
parentBasedOptions root =
  ParentBasedOptions
    { rootSampler = root
    , remoteParentSampled = alwaysOn
    , remoteParentNotSampled = alwaysOff
    , localParentSampled = alwaysOn
    , localParentNotSampled = alwaysOff
    }


{- | A sampler which behaves differently based on the incoming sampling decision.

 In general, this will sample spans that have parents that were sampled, and will not sample spans whose parents were not sampled.

 @since 0.1.0.0
-}
parentBased :: ParentBasedOptions -> Sampler
parentBased = ParentBasedSampler


{- | A decorator that ensures spans always reach processors (IsRecording=true)
even when the wrapped sampler would DROP them. Per spec:

  - DROP         -> RECORD_ONLY (upgraded: processors see it, exporters don't)
  - RECORD_ONLY  -> RECORD_ONLY (unchanged)
  - RECORD_AND_SAMPLE -> RECORD_AND_SAMPLE (unchanged)

Useful for span-to-metrics processors or debugging processors that need
visibility into all spans without increasing export volume.

@since 0.2.0.0
-}
alwaysRecord :: Sampler -> Sampler
alwaysRecord = AlwaysRecordSampler


{- | Execute the sampling decision for a 'Sampler'.

The 'InstrumentationLibrary' parameter is the instrumentation scope of the
'Tracer' creating the span, as required by the spec.
Spec: <https://opentelemetry.io/docs/specs/otel/trace/sdk/#shouldsample>

Non-recursive wrapper handles the two most common leaf samplers
(AlwaysOn / AlwaysOff) inline.

@since 0.0.1.0
-}
shouldSample :: Sampler -> Context -> TraceId -> Text -> SpanArguments -> InstrumentationLibrary -> IO SamplingDecision
shouldSample AlwaysOnSampler ctxt _tid _name _args _scope =
  let !ts = parentTraceState ctxt
  in pure $! SamplingDecision RecordAndSample H.empty ts
shouldSample AlwaysOffSampler ctxt _tid _name _args _scope =
  let !ts = parentTraceState ctxt
  in pure $! SamplingDecision Drop H.empty ts
shouldSample sampler ctxt tid name args scope =
  shouldSampleComplex sampler ctxt tid name args scope
{-# INLINE shouldSample #-}


shouldSampleComplex :: Sampler -> Context -> TraceId -> Text -> SpanArguments -> InstrumentationLibrary -> IO SamplingDecision
shouldSampleComplex (TraceIdRatioSampler frac upperBound sampleRateAttr) ctxt tid _name _args _scope =
  let !ts = parentTraceState ctxt
  in if frac >= 1
      then pure $! SamplingDecision RecordAndSample (H.singleton "sampleRate" sampleRateAttr) ts
      else
        let !(TraceId _ lo) = tid
            !loBE = case targetByteOrder of
              BigEndian -> lo
              LittleEndian -> byteSwap64 lo
            !x = loBE `shiftR` 1
        in if x < upperBound
            then pure $! SamplingDecision RecordAndSample (H.singleton "sampleRate" sampleRateAttr) ts
            else pure $! SamplingDecision Drop H.empty ts
shouldSampleComplex (ParentBasedSampler ParentBasedOptions {..}) ctxt tid name args scope =
  case parentSpanContext ctxt of
    Nothing -> shouldSample rootSampler ctxt tid name args scope
    Just sc ->
      if OpenTelemetry.Internal.Trace.Types.isRemote sc
        then
          if isSampled (traceFlags sc)
            then shouldSample remoteParentSampled ctxt tid name args scope
            else shouldSample remoteParentNotSampled ctxt tid name args scope
        else
          if isSampled (traceFlags sc)
            then shouldSample localParentSampled ctxt tid name args scope
            else shouldSample localParentNotSampled ctxt tid name args scope
shouldSampleComplex (AlwaysRecordSampler inner) ctxt tid name args scope = do
  decision <- shouldSample inner ctxt tid name args scope
  let !outcome' = case samplingOutcome decision of
        Drop -> RecordOnly
        other -> other
  pure $! decision {samplingOutcome = outcome'}
shouldSampleComplex (CustomSampler _ f) ctxt tid name args scope = f ctxt tid name args scope
shouldSampleComplex AlwaysOnSampler ctxt tid name args scope = shouldSample AlwaysOnSampler ctxt tid name args scope
shouldSampleComplex AlwaysOffSampler ctxt tid name args scope = shouldSample AlwaysOffSampler ctxt tid name args scope
{-# NOINLINE shouldSampleComplex #-}


{- | Get the sampler's description string.

@since 0.0.1.0
-}
getDescription :: Sampler -> Text
getDescription AlwaysOnSampler = "AlwaysOnSampler"
getDescription AlwaysOffSampler = "AlwaysOffSampler"
getDescription (TraceIdRatioSampler frac _ _) =
  "TraceIdRatioBased{" <> TL.toStrict (toLazyText (realFloat frac)) <> "}"
getDescription (ParentBasedSampler ParentBasedOptions {..}) =
  "ParentBased{root="
    <> getDescription rootSampler
    <> ", remoteParentSampled="
    <> getDescription remoteParentSampled
    <> ", remoteParentNotSampled="
    <> getDescription remoteParentNotSampled
    <> ", localParentSampled="
    <> getDescription localParentSampled
    <> ", localParentNotSampled="
    <> getDescription localParentNotSampled
    <> "}"
getDescription (AlwaysRecordSampler inner) =
  "AlwaysRecord{" <> getDescription inner <> "}"
getDescription (CustomSampler desc _) = desc


{- | Extract the parent's 'SpanContext' from the 'Context', if present.
Pure: 'getSpanContext' on all 'Span' constructors is non-effectful.
-}
parentSpanContext :: Context -> Maybe SpanContext
parentSpanContext ctxt = case lookupSpan ctxt of
  Nothing -> Nothing
  Just (Span imm) -> Just (spanContext imm)
  Just (FrozenSpan sc) -> Just sc
  Just (Dropped sc) -> Just sc
{-# INLINE parentSpanContext #-}


-- | Extract the parent's 'TraceState', defaulting to empty.
parentTraceState :: Context -> TraceState
parentTraceState ctxt = case parentSpanContext ctxt of
  Nothing -> TraceState.empty
  Just sc -> traceState sc
{-# INLINE parentTraceState #-}
