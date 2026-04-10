module OpenTelemetry.Trace.SamplerSpec where

import Control.Monad
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Sampler
import qualified OpenTelemetry.Trace.TraceState as TraceState
import Test.Hspec


builtInNonCompositeSamplers :: [Sampler]
builtInNonCompositeSamplers =
  [ alwaysOff
  , alwaysOn
  , traceIdRatioBased 0.99
  ]


-- TODO, these would largely be good candidates for quickcheck
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
