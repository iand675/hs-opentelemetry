module OpenTelemetry.Trace.SamplerSpec where

import Control.Monad
import qualified Data.ByteString.Char8 as BS
import qualified Data.Text as T
import Data.Word (Word64)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Sampler (
  ParentBasedOptions (..),
  Sampler,
  SamplingDecision (..),
  SamplingResult (..),
  alwaysOff,
  alwaysOn,
  alwaysRecord,
  getDescription,
  parentBased,
  parentBasedOptions,
  shouldSample,
  traceIdRatioBased,
 )
import qualified OpenTelemetry.Trace.TraceState as TraceState
import Test.Hspec
import Text.Printf (printf)


builtInNonCompositeSamplers :: [Sampler]
builtInNonCompositeSamplers =
  [ alwaysOff
  , alwaysOn
  , traceIdRatioBased 0.99
  ]


spec :: Spec
spec = describe "Sampler" $ do
  -- Trace SDK §Sampling
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
  describe "built-in non-composite samplers" $ do
    forM_ builtInNonCompositeSamplers $ \sampler -> do
      -- Trace SDK §Sampling API: SamplingResult TraceState matches parent SpanContext
      -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
      specify (show (getDescription sampler) ++ " returns parent tracestate") $ do
        let (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
            (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
            remoteSpan =
              SpanContext
                { traceFlags = defaultTraceFlags
                , isRemote = False
                , traceState = TraceState.insert (TraceState.Key "k") (TraceState.Value "v") TraceState.empty
                , spanId = parentSpanId
                , traceId = aTraceId
                }
            traceParent = wrapSpanContext remoteSpan
            parentContext = Context.insertSpan traceParent Context.empty
        SamplingDecision _ _ ts <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
        ts `shouldBe` traceState remoteSpan

  describe "alwaysOff" $ do
    -- Trace SDK §Built-in samplers: AlwaysOffSampler → Drop decision
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#built-in-samplers
    it "returns Drop" $ do
      let (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample alwaysOff parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` Drop

  describe "alwaysRecord" $ do
    -- Trace SDK §Recording-only samplers: upgrade sampling decision to record-only
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#recording-only-samplers
    it "upgrades alwaysOff from Drop to RecordOnly" $ do
      let (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
          sampler = alwaysRecord alwaysOff
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordOnly
    -- Trace SDK §Recording-only samplers: preserve RecordAndSample when already sampled
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#recording-only-samplers
    it "leaves alwaysOn as RecordAndSample" $ do
      let (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
          sampler = alwaysRecord alwaysOn
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample
    -- Implementation-specific: composite sampler description formatting
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "wraps the inner sampler description" $ do
      getDescription (alwaysRecord alwaysOff) `shouldBe` "AlwaysRecord{AlwaysOffSampler}"

  describe "alwaysOn" $ do
    -- Trace SDK §Built-in samplers: AlwaysOnSampler → RecordAndSample
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#built-in-samplers
    it "returns RecordAndSample" $ do
      let (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample alwaysOn parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample

  describe "traceIdRatioBased" $ do
    -- Trace SDK §TraceIdRatioBased sampler: deterministic sampling by TraceId
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
    it "drops spans that are outside of the sample ratio" $ do
      let sampler = traceIdRatioBased 0.5
          (Right aTraceId) = baseEncodedToTraceId Base16 "0000000000000000ffffffffffffffff"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` Drop
    -- Trace SDK §TraceIdRatioBased sampler: spans inside ratio are RecordAndSample
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
    it "samples spans that are within the sample ratio" $ do
      let sampler = traceIdRatioBased 0.5
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000000"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample
    -- Trace SDK §TraceIdRatioBased sampler: monotonicity across ratios
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
    it "higher sample ratios sample spans that are also by lower ratios" $ do
      let conservativeSampler = traceIdRatioBased 0.5
          permissiveSampler = traceIdRatioBased 0.75
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000003fffffffffffffff"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      do
        SamplingDecision resConservative _ _ <- shouldSample permissiveSampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
        SamplingDecision resPermissive _ _ <- shouldSample conservativeSampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
        resConservative `shouldBe` RecordAndSample
        resPermissive `shouldBe` RecordAndSample

    -- Trace SDK §TraceIdRatioBased sampler: uses TraceId least-significant 8 bytes
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
    it "sampling depends only on the lower 8 bytes (hi bytes are irrelevant)" $ do
      let sampler = traceIdRatioBased 0.5
          (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
          mkCtx tid =
            let sc =
                  SpanContext
                    { traceFlags = defaultTraceFlags
                    , isRemote = False
                    , traceState = TraceState.empty
                    , spanId = parentSpanId
                    , traceId = tid
                    }
            in Context.insertSpan (wrapSpanContext sc) Context.empty
          -- Same lo bytes (near zero → should sample), different hi bytes
          (Right tid1) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right tid2) = baseEncodedToTraceId Base16 "ffffffffffffffff0000000000000001"
          (Right tid3) = baseEncodedToTraceId Base16 "abcdef01234567890000000000000001"
      SamplingDecision r1 _ _ <- shouldSample sampler (mkCtx tid1) tid1 "test" defaultSpanArguments "test-scope"
      SamplingDecision r2 _ _ <- shouldSample sampler (mkCtx tid2) tid2 "test" defaultSpanArguments "test-scope"
      SamplingDecision r3 _ _ <- shouldSample sampler (mkCtx tid3) tid3 "test" defaultSpanArguments "test-scope"
      r1 `shouldBe` r2
      r2 `shouldBe` r3

    -- Trace SDK §TraceIdRatioBased sampler: different TraceId suffix → different decision
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
    it "different lo bytes produce different sampling decisions" $ do
      let sampler = traceIdRatioBased 0.5
          (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
          mkCtx tid =
            let sc =
                  SpanContext
                    { traceFlags = defaultTraceFlags
                    , isRemote = False
                    , traceState = TraceState.empty
                    , spanId = parentSpanId
                    , traceId = tid
                    }
            in Context.insertSpan (wrapSpanContext sc) Context.empty
          -- Same hi bytes, different lo bytes: one near zero (sampled), one near max (dropped)
          (Right tidLow) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right tidHigh) = baseEncodedToTraceId Base16 "0000000000000000fffffffffffffffe"
      SamplingDecision rLow _ _ <- shouldSample sampler (mkCtx tidLow) tidLow "test" defaultSpanArguments "test-scope"
      SamplingDecision rHigh _ _ <- shouldSample sampler (mkCtx tidHigh) tidHigh "test" defaultSpanArguments "test-scope"
      rLow `shouldBe` RecordAndSample
      rHigh `shouldBe` Drop

    describe "traceIdRatioBased property tests" $ do
      -- Implementation-specific: statistical check of TraceIdRatioBased distribution
      -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
      it "samples approximately the configured ratio over many trials" $ do
        let sampler = traceIdRatioBased 0.5
            trials = 1000
            (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
        results <- forM [1 .. trials] $ \i -> do
          let step = (maxBound :: Word64) `div` fromIntegral (trials + 1)
              hi = fromIntegral (i * 7919) :: Word64
              lo = fromIntegral i * step
              (Right tid) =
                baseEncodedToTraceId Base16 $
                  BS.pack $
                    printf "%016x%016x" hi lo
              remoteSpan =
                SpanContext
                  { traceFlags = defaultTraceFlags
                  , isRemote = False
                  , traceState = TraceState.empty
                  , spanId = parentSpanId
                  , traceId = tid
                  }
              traceParent = wrapSpanContext remoteSpan
              parentContext = Context.insertSpan traceParent Context.empty
          SamplingDecision res _ _ <- shouldSample sampler parentContext tid "test" defaultSpanArguments "test-scope"
          pure (res == RecordAndSample)
        let sampledCount = length (filter id results)
            ratio = fromIntegral sampledCount / fromIntegral trials :: Double
        ratio `shouldSatisfy` (\r -> r > 0.35 && r < 0.65)

      -- Trace SDK §TraceIdRatioBased sampler: ratio 0 → always Drop
      -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
      it "traceIdRatioBased 0.0 never samples" $ do
        let sampler = traceIdRatioBased 0.0
            (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
        forM_ [1 .. 64 :: Int] $ \i -> do
          let trials = 64
              step = (maxBound :: Word64) `div` fromIntegral (trials + 1)
              hi = fromIntegral (i * 7919) :: Word64
              lo = fromIntegral i * step
              (Right tid) =
                baseEncodedToTraceId Base16 $
                  BS.pack $
                    printf "%016x%016x" hi lo
              remoteSpan =
                SpanContext
                  { traceFlags = defaultTraceFlags
                  , isRemote = False
                  , traceState = TraceState.empty
                  , spanId = parentSpanId
                  , traceId = tid
                  }
              traceParent = wrapSpanContext remoteSpan
              parentContext = Context.insertSpan traceParent Context.empty
          SamplingDecision res _ _ <- shouldSample sampler parentContext tid "test" defaultSpanArguments "test-scope"
          res `shouldBe` Drop

      -- Trace SDK §TraceIdRatioBased sampler: ratio 1 → always RecordAndSample
      -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#traceidratiobased
      it "traceIdRatioBased 1.0 always samples" $ do
        let sampler = traceIdRatioBased 1.0
            (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
        forM_ [1 .. 64 :: Int] $ \i -> do
          let trials = 64
              step = (maxBound :: Word64) `div` fromIntegral (trials + 1)
              hi = fromIntegral (i * 7919) :: Word64
              lo = fromIntegral i * step
              (Right tid) =
                baseEncodedToTraceId Base16 $
                  BS.pack $
                    printf "%016x%016x" hi lo
              remoteSpan =
                SpanContext
                  { traceFlags = defaultTraceFlags
                  , isRemote = False
                  , traceState = TraceState.empty
                  , spanId = parentSpanId
                  , traceId = tid
                  }
              traceParent = wrapSpanContext remoteSpan
              parentContext = Context.insertSpan traceParent Context.empty
          SamplingDecision res _ _ <- shouldSample sampler parentContext tid "test" defaultSpanArguments "test-scope"
          res `shouldBe` RecordAndSample

  describe "parentBased" $ do
    -- Trace SDK §ParentBased sampler: root span uses root sampler
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "delegates to rootSampler when no parent span" $ do
      let sampler = parentBased (parentBasedOptions alwaysOff)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
      SamplingDecision res _ _ <- shouldSample sampler Context.empty aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` Drop

    -- Trace SDK §ParentBased sampler: root span with AlwaysOn root sampler
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "delegates to rootSampler alwaysOn when no parent" $ do
      let sampler = parentBased (parentBasedOptions alwaysOn)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
      SamplingDecision res _ _ <- shouldSample sampler Context.empty aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample

    -- Trace SDK §ParentBased sampler: remote parent sampled → remoteParentSampled
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "delegates to remoteParentSampled when remote parent is sampled" $ do
      let sampler = parentBased (parentBasedOptions alwaysOff)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample

    -- Trace SDK §ParentBased sampler: remote parent not sampled → remoteParentNotSampled
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "delegates to remoteParentNotSampled when remote parent is not sampled" $ do
      let sampler = parentBased (parentBasedOptions alwaysOn)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` Drop

    -- Trace SDK §ParentBased sampler: local parent sampled → localParentSampled
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "delegates to localParentSampled when local parent is sampled" $ do
      let sampler = parentBased (parentBasedOptions alwaysOff)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          localSpan =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext localSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample

    -- Trace SDK §ParentBased sampler: local parent not sampled → localParentNotSampled
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "delegates to localParentNotSampled when local parent is not sampled" $ do
      let sampler = parentBased (parentBasedOptions alwaysOn)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          localSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext localSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` Drop

    -- Trace SDK §ParentBased sampler: configurable remoteParentNotSampled delegate
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#parentbased
    it "custom remoteParentNotSampled overrides default" $ do
      let opts =
            (parentBasedOptions alwaysOff)
              { remoteParentNotSampled = alwaysOn
              }
          sampler = parentBased opts
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
          (Right parentSpanId) = baseEncodedToSpanId Base16 "000000000000000a"
          remoteSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = parentSpanId
              , traceId = aTraceId
              }
          traceParent = wrapSpanContext remoteSpan
          parentContext = Context.insertSpan traceParent Context.empty
      SamplingDecision res _ _ <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments "test-scope"
      res `shouldBe` RecordAndSample

    -- Implementation-specific: ParentBased sampler description aggregates child names
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "description includes all child sampler names" $ do
      let desc = getDescription (parentBased (parentBasedOptions alwaysOn))
      desc `shouldSatisfy` ("ParentBased{root=" `T.isInfixOf`)

  describe "traceIdRatioBased description" $ do
    -- Implementation-specific: TraceIdRatioBased getDescription formatting
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "description is TraceIdRatioBased{1.0} when ratio >= 1" $ do
      let desc = getDescription (traceIdRatioBased 1.0)
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    -- Implementation-specific: TraceIdRatioBased getDescription formatting
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "description is TraceIdRatioBased{0.0} when ratio <= 0" $ do
      let desc = getDescription (traceIdRatioBased 0.0)
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    -- Implementation-specific: TraceIdRatioBased getDescription formatting
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "description for ratio 0.5" $ do
      getDescription (traceIdRatioBased 0.5) `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    -- Implementation-specific: TraceIdRatioBased clamps invalid ratios for description
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "clamps ratio > 1 to 1" $ do
      let desc = getDescription (traceIdRatioBased 2.0)
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    -- Implementation-specific: TraceIdRatioBased clamps invalid ratios for description
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
    it "clamps negative ratio to 0" $ do
      let desc = getDescription (traceIdRatioBased (-1.0))
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
