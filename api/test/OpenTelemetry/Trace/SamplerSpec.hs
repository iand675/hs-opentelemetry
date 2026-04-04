module OpenTelemetry.Trace.SamplerSpec where

import Control.Monad
import qualified Data.ByteString.Char8 as BS
import qualified Data.Text as T
import Data.Word (Word64)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Sampler
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
  describe "built-in non-composite samplers" $ do
    forM_ builtInNonCompositeSamplers $ \sampler -> do
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
        (_, _, ts) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
        ts `shouldBe` traceState remoteSpan

  describe "alwaysOff" $ do
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
      (res, _, _) <- shouldSample alwaysOff parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` Drop

  describe "alwaysRecord" $ do
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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordOnly
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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample
    it "wraps the inner sampler description" $ do
      getDescription (alwaysRecord alwaysOff) `shouldBe` "AlwaysRecord{AlwaysOffSampler}"

  describe "alwaysOn" $ do
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
      (res, _, _) <- shouldSample alwaysOn parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample

  describe "traceIdRatioBased" $ do
    it "drops spans that are outside of the sample ratio" $ do
      let sampler = traceIdRatioBased 0.5
          (Right aTraceId) = baseEncodedToTraceId Base16 "ffffffffffffffff0000000000000000"
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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` Drop
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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample
    it "higher sample ratios sample spans that are also by lower ratios" $ do
      let conservativeSampler = traceIdRatioBased 0.5
          permissiveSampler = traceIdRatioBased 0.75
          (Right aTraceId) = baseEncodedToTraceId Base16 "3fffffffffffffff0000000000000000"
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
        (resConservative, _, _) <- shouldSample permissiveSampler parentContext aTraceId "test" defaultSpanArguments
        (resPermissive, _, _) <- shouldSample conservativeSampler parentContext aTraceId "test" defaultSpanArguments
        resConservative `shouldBe` RecordAndSample
        resPermissive `shouldBe` RecordAndSample

    describe "traceIdRatioBased property tests" $ do
      it "samples approximately the configured ratio over many trials" $ do
        let sampler = traceIdRatioBased 0.5
            trials = 1000
            (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
        results <- forM [1 .. trials] $ \i -> do
          let step = (maxBound :: Word64) `div` fromIntegral (trials + 1)
              hi = fromIntegral i * step
              lo = fromIntegral (i * 7919) :: Word64
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
          (res, _, _) <- shouldSample sampler parentContext tid "test" defaultSpanArguments
          pure (res == RecordAndSample)
        let sampledCount = length (filter id results)
            ratio = fromIntegral sampledCount / fromIntegral trials :: Double
        ratio `shouldSatisfy` (\r -> r > 0.35 && r < 0.65)

      it "traceIdRatioBased 0.0 never samples" $ do
        let sampler = traceIdRatioBased 0.0
            (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
        forM_ [1 .. 64 :: Int] $ \i -> do
          let trials = 64
              step = (maxBound :: Word64) `div` fromIntegral (trials + 1)
              hi = fromIntegral i * step
              lo = fromIntegral (i * 7919) :: Word64
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
          (res, _, _) <- shouldSample sampler parentContext tid "test" defaultSpanArguments
          res `shouldBe` Drop

      it "traceIdRatioBased 1.0 always samples" $ do
        let sampler = traceIdRatioBased 1.0
            (Right parentSpanId) = baseEncodedToSpanId Base16 "0000000000000001"
        forM_ [1 .. 64 :: Int] $ \i -> do
          let trials = 64
              step = (maxBound :: Word64) `div` fromIntegral (trials + 1)
              hi = fromIntegral i * step
              lo = fromIntegral (i * 7919) :: Word64
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
          (res, _, _) <- shouldSample sampler parentContext tid "test" defaultSpanArguments
          res `shouldBe` RecordAndSample

  describe "parentBased" $ do
    it "delegates to rootSampler when no parent span" $ do
      let sampler = parentBased (parentBasedOptions alwaysOff)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
      (res, _, _) <- shouldSample sampler Context.empty aTraceId "test" defaultSpanArguments
      res `shouldBe` Drop

    it "delegates to rootSampler alwaysOn when no parent" $ do
      let sampler = parentBased (parentBasedOptions alwaysOn)
          (Right aTraceId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
      (res, _, _) <- shouldSample sampler Context.empty aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample

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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample

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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` Drop

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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample

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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` Drop

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
      (res, _, _) <- shouldSample sampler parentContext aTraceId "test" defaultSpanArguments
      res `shouldBe` RecordAndSample

    it "description includes all child sampler names" $ do
      let desc = getDescription (parentBased (parentBasedOptions alwaysOn))
      desc `shouldSatisfy` ("ParentBased{root=" `T.isInfixOf`)

  describe "traceIdRatioBased description" $ do
    it "description is TraceIdRatioBased{1.0} when ratio >= 1" $ do
      let desc = getDescription (traceIdRatioBased 1.0)
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    it "description is TraceIdRatioBased{0.0} when ratio <= 0" $ do
      let desc = getDescription (traceIdRatioBased 0.0)
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    it "description for ratio 0.5" $ do
      getDescription (traceIdRatioBased 0.5) `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    it "clamps ratio > 1 to 1" $ do
      let desc = getDescription (traceIdRatioBased 2.0)
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
    it "clamps negative ratio to 0" $ do
      let desc = getDescription (traceIdRatioBased (-1.0))
      desc `shouldSatisfy` T.isPrefixOf "TraceIdRatioBased{"
