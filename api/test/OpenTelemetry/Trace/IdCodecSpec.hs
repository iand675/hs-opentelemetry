{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Trace.IdCodecSpec (spec) where

import Data.Bits (shiftR, (.&.))
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8
import Data.Char (toLower)
import Data.Word (Word8)
import qualified Hedgehog as H
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import OpenTelemetry.Internal.Trace.Id
import Test.Hspec
import Test.Hspec.Hedgehog (hedgehog)


genHexChar :: H.Gen Char
genHexChar = Gen.element $ ['0' .. '9'] ++ ['a' .. 'f']


genHexCharMixed :: H.Gen Char
genHexCharMixed = Gen.element $ ['0' .. '9'] ++ ['a' .. 'f'] ++ ['A' .. 'F']


genHexBS :: Int -> H.Gen BS.ByteString
genHexBS n = C8.pack <$> Gen.list (Range.singleton n) genHexChar


genHexBSMixed :: Int -> H.Gen BS.ByteString
genHexBSMixed n = C8.pack <$> Gen.list (Range.singleton n) genHexCharMixed


genNonZeroHexBS :: Int -> H.Gen BS.ByteString
genNonZeroHexBS n = Gen.filter (not . BS.all (== 0x30)) (genHexBS n)


genTraceId :: H.Gen TraceId
genTraceId = do
  hex <- genNonZeroHexBS 32
  case baseEncodedToTraceId Base16 hex of
    Right tid -> pure tid
    Left _ -> genTraceId


genSpanId :: H.Gen SpanId
genSpanId = do
  hex <- genNonZeroHexBS 16
  case baseEncodedToSpanId Base16 hex of
    Right sid -> pure sid
    Left _ -> genSpanId


genFlags :: H.Gen Word8
genFlags = Gen.word8 Range.constantBounded


nibToHex :: Int -> Char
nibToHex n
  | n < 10 = toEnum (n + fromEnum '0')
  | otherwise = toEnum (n - 10 + fromEnum 'a')


isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft _ = False


spec :: Spec
spec = do
  -- Trace API §SpanContext: TraceId (16-byte id, lowercase hex)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "TraceId hex round-trip" $ do
    it "encode . decode = identity for random lowercase hex" $ hedgehog $ do
      hex <- H.forAll $ genHexBS 32
      let Right tid = baseEncodedToTraceId Base16 hex
      traceIdBaseEncodedByteString Base16 tid H.=== hex

    it "normalizes uppercase hex to lowercase" $ hedgehog $ do
      hex <- H.forAll $ genHexBSMixed 32
      let Right tid = baseEncodedToTraceId Base16 hex
          rehex = traceIdBaseEncodedByteString Base16 tid
      rehex H.=== C8.map toLower hex

    it "rejects wrong length" $ do
      baseEncodedToTraceId Base16 "00" `shouldSatisfy` isLeft
      baseEncodedToTraceId Base16 (C8.replicate 31 'a') `shouldSatisfy` isLeft
      baseEncodedToTraceId Base16 (C8.replicate 33 'a') `shouldSatisfy` isLeft

    it "rejects invalid hex characters" $ do
      baseEncodedToTraceId Base16 "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" `shouldSatisfy` isLeft
      baseEncodedToTraceId Base16 "0000000000000000000000000000000g" `shouldSatisfy` isLeft
      baseEncodedToTraceId Base16 "000000000000000000000000000000 0" `shouldSatisfy` isLeft

    it "correctly decodes known value" $ do
      let Right tid = baseEncodedToTraceId Base16 "4bf92f3577b34da6a3ce929d0e0e4736"
          bs = traceIdBytes tid
      BS.length bs `shouldBe` 16
      BS.index bs 0 `shouldBe` 0x4b
      BS.index bs 1 `shouldBe` 0xf9
      BS.index bs 15 `shouldBe` 0x36

  -- Trace API §SpanContext: SpanId (8-byte id, lowercase hex)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "SpanId hex round-trip" $ do
    it "encode . decode = identity" $ hedgehog $ do
      hex <- H.forAll $ genHexBS 16
      let Right sid = baseEncodedToSpanId Base16 hex
      spanIdBaseEncodedByteString Base16 sid H.=== hex

    it "rejects wrong length" $ do
      baseEncodedToSpanId Base16 "00" `shouldSatisfy` isLeft
      baseEncodedToSpanId Base16 (C8.replicate 15 'a') `shouldSatisfy` isLeft

    it "correctly decodes known value" $ do
      let Right sid = baseEncodedToSpanId Base16 "00f067aa0ba902b7"
          bs = spanIdBytes sid
      BS.length bs `shouldBe` 8
      BS.index bs 0 `shouldBe` 0x00
      BS.index bs 1 `shouldBe` 0xf0
      BS.index bs 7 `shouldBe` 0xb7

  -- Trace API §SpanContext: TraceId binary form (16 bytes)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "TraceId bytes round-trip" $ do
    it "bytesToTraceId (traceIdBytes tid) = Right tid" $ hedgehog $ do
      tid <- H.forAll genTraceId
      bytesToTraceId (traceIdBytes tid) H.=== Right tid

    it "rejects wrong length bytes" $ do
      bytesToTraceId (BS.replicate 15 0) `shouldSatisfy` isLeft
      bytesToTraceId (BS.replicate 17 0) `shouldSatisfy` isLeft

  -- Trace API §SpanContext: SpanId binary form (8 bytes)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "SpanId bytes round-trip" $ do
    it "bytesToSpanId (spanIdBytes sid) = Right sid" $ hedgehog $ do
      sid <- H.forAll genSpanId
      bytesToSpanId (spanIdBytes sid) H.=== Right sid

  -- Trace API §SpanContext: invalid zero TraceId / SpanId (OTel + W3C traceparent rules)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "isEmptyTraceId / isEmptySpanId" $ do
    it "nilTraceId is empty" $
      isEmptyTraceId nilTraceId `shouldBe` True

    it "nilSpanId is empty" $
      isEmptySpanId nilSpanId `shouldBe` True

    it "non-zero TraceId is not empty" $ hedgehog $ do
      tid <- H.forAll genTraceId
      H.assert $ not (isEmptyTraceId tid)

    it "non-zero SpanId is not empty" $ hedgehog $ do
      sid <- H.forAll genSpanId
      H.assert $ not (isEmptySpanId sid)

  -- Propagators API §W3C Trace Context: traceparent header (version 00)
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
  describe "decodeTraceparent" $ do
    it "parses valid v00 traceparent" $ do
      let Just (ver, tid, sid, fl) =
            decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
      ver `shouldBe` 0
      fl `shouldBe` 1
      traceIdBaseEncodedByteString Base16 tid `shouldBe` "4bf92f3577b34da6a3ce929d0e0e4736"
      spanIdBaseEncodedByteString Base16 sid `shouldBe` "00f067aa0ba902b7"

    it "parses flags=00" $ do
      let Just (_, _, _, fl) =
            decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-00"
      fl `shouldBe` 0

    it "round-trips through encode/decode" $ hedgehog $ do
      tid <- H.forAll genTraceId
      sid <- H.forAll genSpanId
      fl <- H.forAll genFlags
      let encoded = encodeTraceparent 0 tid sid fl
          Just (ver', tid', sid', fl') = decodeTraceparent encoded
      ver' H.=== 0
      tid' H.=== tid
      sid' H.=== sid
      fl' H.=== fl

    it "encodeTraceparent produces correct format" $ do
      let Right tid = baseEncodedToTraceId Base16 "4bf92f3577b34da6a3ce929d0e0e4736"
          Right sid = baseEncodedToSpanId Base16 "00f067aa0ba902b7"
      encodeTraceparent 0 tid sid 1 `shouldBe` "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"

    it "encodeTraceparent has length 55" $ hedgehog $ do
      tid <- H.forAll genTraceId
      sid <- H.forAll genSpanId
      BS.length (encodeTraceparent 0 tid sid 1) H.=== 55

    it "encodeTraceparent has dashes at correct positions" $ hedgehog $ do
      tid <- H.forAll genTraceId
      sid <- H.forAll genSpanId
      let bs = encodeTraceparent 0 tid sid 1
      BS.index bs 2 H.=== 0x2d
      BS.index bs 35 H.=== 0x2d
      BS.index bs 52 H.=== 0x2d

    it "rejects too-short input" $
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-0" `shouldBe` Nothing

    it "rejects too-long input for v00" $
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01-extra" `shouldBe` Nothing

    it "rejects missing dashes" $ do
      decodeTraceparent "00X4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01" `shouldBe` Nothing
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736X00f067aa0ba902b7-01" `shouldBe` Nothing
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7X01" `shouldBe` Nothing

    it "rejects all-zero trace ID" $
      decodeTraceparent "00-00000000000000000000000000000000-00f067aa0ba902b7-01" `shouldBe` Nothing

    it "rejects all-zero span ID" $
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-0000000000000000-01" `shouldBe` Nothing

    it "rejects invalid hex in trace ID" $
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e473g-00f067aa0ba902b7-01" `shouldBe` Nothing

    it "rejects invalid hex in span ID" $
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902bx-01" `shouldBe` Nothing

    it "rejects invalid hex in version" $
      decodeTraceparent "0g-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01" `shouldBe` Nothing

    it "rejects invalid hex in flags" $
      decodeTraceparent "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-0z" `shouldBe` Nothing

    it "rejects uppercase hex (W3C TC2 HEXDIGLC)" $ do
      decodeTraceparent "00-4BF92F3577B34DA6A3CE929D0E0E4736-00F067AA0BA902B7-01"
        `shouldBe` Nothing

    it "rejects version ff (W3C TC2)" $ do
      decodeTraceparent "ff-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
        `shouldBe` Nothing

  -- Implementation-specific: SIMD-accelerated hex decode validation
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "SIMD hex decode edge cases" $ do
    it "decodes every possible byte value correctly" $ do
      mapM_
        ( \i -> do
            let hi = i `shiftR` 4
                lo = i .&. 0x0f
                hexStr =
                  C8.pack [nibToHex hi, nibToHex lo]
                    <> C8.replicate 14 '0'
            case baseEncodedToSpanId Base16 hexStr of
              Right sid -> BS.index (spanIdBytes sid) 0 `shouldBe` fromIntegral i
              Left err -> expectationFailure $ "Failed for " ++ show i ++ ": " ++ err
        )
        [0 .. 255 :: Int]

    it "rejects each non-hex ASCII char at every position" $ do
      let badChars = ['\0', ' ', '/', ':', '@', 'G', '`', 'g', '\127']
      mapM_
        ( \bad ->
            mapM_
              ( \pos -> do
                  let base = replicate 16 '0'
                      withBad = take pos base ++ [bad] ++ drop (pos + 1) base
                  baseEncodedToSpanId Base16 (C8.pack withBad) `shouldSatisfy` isLeft
              )
              [0 .. 15 :: Int]
        )
        badChars

    it "rejects chars just outside hex ranges" $ do
      let justOutside = ['/', ':', '@', 'G', '`', 'g']
      mapM_
        ( \c -> do
            let hex = c : replicate 15 '0'
            baseEncodedToSpanId Base16 (C8.pack hex) `shouldSatisfy` isLeft
        )
        justOutside
