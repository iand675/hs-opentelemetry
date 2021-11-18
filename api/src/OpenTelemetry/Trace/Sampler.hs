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
import OpenTelemetry.Resource (toAttribute)
import OpenTelemetry.Context
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.TraceState as TraceState

-- | Returns @RecordAndSample@ always.
--
-- Description returns AlwaysOnSampler.
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
      , shouldSample = \ctxt tid _ csa -> do
        mspanCtxt <- sequence (getSpanContext <$> lookupSpan ctxt)
        let x = runGet getWord64be (L.fromStrict $ B.take 8 $ traceIdBytes tid) `shiftR` 1
        if x < traceIdUpperBound
          then do
            pure (RecordAndSample, [("sampleRate", sampleRate)], maybe TraceState.empty traceState mspanCtxt)
          else
            pure (Drop, startingAttributes csa, maybe TraceState.empty traceState mspanCtxt)
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
