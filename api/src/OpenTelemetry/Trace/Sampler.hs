-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Trace.Sampler
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Sampling strategies for reducing tracing overhead
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- This module provides several built-in sampling strategies, as well as the ability to define custom samplers.
--
-- Sampling is the concept of selecting a few elements from a large collection and learning about the entire collection by extrapolating from the selected set. It’s widely used throughout the world whenever trying to tackle a problem of scale: for example, a survey assumes that by asking a small group of people a set of questions, you can learn something about the opinions of the entire populace.
--
-- While it’s nice to believe that every event is precious, the reality of monitoring high volume production infrastructure is that there are some attributes to events that make them more interesting than the rest. Failures are often more interesting than successes! Rare events are more interesting than common events! Capturing some traffic from all customers can be better than capturing all traffic from some customers.
--
-- Sampling as a basic technique for instrumentation is no different—by recording information about a representative subset of requests flowing through a system, you can learn about the overall performance of the system. And as with surveys and air monitoring, the way you choose your representative set (the sample set) can greatly influence the accuracy of your results.
--
-- Sampling is widespread in observability systems because it lowers the cost of producing, collecting, and analyzing data in systems anywhere cost is a concern. Developers and operators in an observability system apply or attach key=value properties to observability data–spans and metrics–and we use these properties to investigate hypotheses about our systems after the fact. It is interesting to look at how sampling impacts our ability to analyze observability data, using key=value restrictions for some keys and grouping the output based on other keys.
--
-- Sampling schemes let observability systems collect examples of data that are not merely exemplary, but also representative. Sampling schemes compute a set of representative items and, in doing so, score each item with what is commonly called the item's "sampling rate." A sampling rate of 10 indicates that the item represents an estimated 10 individuals in the original data set.
-----------------------------------------------------------------------------
module OpenTelemetry.Trace.Sampler (
  Sampler(..),
  SamplingResult(..),
  parentBased,
  parentBasedOptions,
  ParentBasedOptions(..),
  traceIdRatioBased,
  alwaysOn,
  alwaysOff
) where
import Data.Binary.Get
import Data.Bits
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Data.Text
import Data.Word (Word64)
import OpenTelemetry.Trace.Id
import OpenTelemetry.Context
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Attributes (toAttribute)

-- | Returns @RecordAndSample@ always.
--
-- Description returns AlwaysOnSampler.
--
-- @since 0.1.0.0
alwaysOn :: Sampler
alwaysOn = Sampler
  { getDescription = "AlwaysOnSampler"
  , shouldSample = \ctxt _ _ _ -> do
      mspanCtxt <- sequence (getSpanContext <$> lookupSpan ctxt)
      pure (RecordAndSample, [], maybe TraceState.empty traceState mspanCtxt)
  }

-- | Returns @RecordAndSample@ always.
--
-- Description returns AlwaysOffSampler.
--
-- @since 0.1.0.0
alwaysOff :: Sampler
alwaysOff = Sampler
  { getDescription = "AlwaysOffSampler"
  , shouldSample = \ctxt _ _ _ -> do
      mspanCtxt <- sequence (getSpanContext <$> lookupSpan ctxt)
      pure (Drop, [], maybe TraceState.empty traceState mspanCtxt)
  }

-- | The TraceIdRatioBased ignores the parent SampledFlag. To respect the parent SampledFlag, 
-- the TraceIdRatioBased should be used as a delegate of the @parentBased@ sampler specified below.
-- 
-- Description returns a string of the form "TraceIdRatioBased{RATIO}" with RATIO replaced with the Sampler 
-- instance's trace sampling ratio represented as a decimal number.
--
-- @since 0.1.0.0
traceIdRatioBased :: Double -> Sampler
traceIdRatioBased fraction = if fraction >= 1
  then alwaysOn
  else sampler
  where
    safeFraction = max fraction 0
    sampleRate = if safeFraction > 0 
      then toAttribute ((round (1 / safeFraction)) :: Int)
      else toAttribute (0 :: Int)

    traceIdUpperBound = floor (fraction * fromIntegral ((1 :: Word64) `shiftL` 63)) :: Word64
    sampler = Sampler
      { getDescription = "TraceIdRatioBased{" <> pack (show fraction) <> "}"
      , shouldSample = \ctxt tid _ _ -> do
        mspanCtxt <- sequence (getSpanContext <$> lookupSpan ctxt)
        let x = runGet getWord64be (L.fromStrict $ B.take 8 $ traceIdBytes tid) `shiftR` 1
        if x < traceIdUpperBound
          then do
            pure (RecordAndSample, [("sampleRate", sampleRate)], maybe TraceState.empty traceState mspanCtxt)
          else
            pure (Drop, [], maybe TraceState.empty traceState mspanCtxt)
      }

-- | This is a composite sampler. ParentBased helps distinguish between the following cases:
--
-- No parent (root span).
--
-- Remote parent (SpanContext.IsRemote() == true) with SampledFlag equals true
-- 
-- Remote parent (SpanContext.IsRemote() == true) with SampledFlag equals false
--
-- Local parent (SpanContext.IsRemote() == false) with SampledFlag equals true
--
-- Local parent (SpanContext.IsRemote() == false) with SampledFlag equals false
--
-- @since 0.1.0.0
data ParentBasedOptions = ParentBasedOptions 
  { rootSampler :: Sampler
  -- ^ Sampler called for spans with no parent (root spans)
  , remoteParentSampled :: Sampler
  -- ^ default: alwaysOn
  , remoteParentNotSampled :: Sampler
  -- ^ default: alwaysOff
  , localParentSampled :: Sampler
  -- ^ default: alwaysOn
  , localParentNotSampled :: Sampler
  -- ^ default: alwaysOff
  }

-- | A smart constructor for 'ParentBasedOptions' with reasonable starting
-- defaults.
--
-- @since 0.1.0.0
parentBasedOptions 
  :: Sampler 
  -- ^ Root sampler
  -> ParentBasedOptions
parentBasedOptions root = ParentBasedOptions
  { rootSampler = root
  , remoteParentSampled = alwaysOn
  , remoteParentNotSampled = alwaysOff
  , localParentSampled = alwaysOn
  , localParentNotSampled = alwaysOff
  }

-- | A sampler which behaves differently based on the incoming sampling decision. 
--
-- In general, this will sample spans that have parents that were sampled, and will not sample spans whose parents were not sampled.
--
-- @since 0.1.0.0
parentBased :: ParentBasedOptions -> Sampler
parentBased ParentBasedOptions{..} = Sampler
  { getDescription = 
      "ParentBased{root=" <> 
      getDescription rootSampler <>
      ", remoteParentSampled=" <>
      getDescription remoteParentSampled <>
      ", remoteParentNotSampled=" <>
      getDescription remoteParentNotSampled <>
      ", localParentSampled=" <>
      getDescription localParentSampled <>
      ", localParentNotSampled=" <>
      getDescription localParentNotSampled <>
      "}"
  , shouldSample = \ctx tid name csa -> do
      mspanCtxt <- sequence (getSpanContext <$> lookupSpan ctx)
      case mspanCtxt of
        Nothing -> shouldSample rootSampler ctx tid name csa
        Just root -> if OpenTelemetry.Internal.Trace.Types.isRemote root
          then if isSampled $ traceFlags root
            then shouldSample remoteParentSampled ctx tid name csa
            else shouldSample remoteParentNotSampled ctx tid name csa
          else if isSampled $ traceFlags root
            then shouldSample localParentSampled ctx tid name csa
            else shouldSample localParentNotSampled ctx tid name csa
  }
