module OpenTelemetry.Trace.EncodingSpec where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Short as SBS
import OpenTelemetry.Internal.Trace.Encoding
import OpenTelemetry.Trace.Id
import Test.Hspec


spec :: Spec
spec = describe "Base16 Encoding" $ do
  describe "encodeBase16" $ do
    it "encodes empty input" $ do
      encodeBase16 "" `shouldBe` ""

    it "encodes a single byte" $ do
      encodeBase16 (BS.pack [0x0a]) `shouldBe` "0a"
      encodeBase16 (BS.pack [0xff]) `shouldBe` "ff"
      encodeBase16 (BS.pack [0x00]) `shouldBe` "00"

    it "encodes known test vectors" $ do
      encodeBase16 "Hello" `shouldBe` "48656c6c6f"
      encodeBase16 (BS.pack [0xde, 0xad, 0xbe, 0xef]) `shouldBe` "deadbeef"

    it "encodes all byte values correctly" $ do
      let allBytes = BS.pack [0 .. 255]
          encoded = encodeBase16 allBytes
      BS.length encoded `shouldBe` 512
      BS.take 6 encoded `shouldBe` "000102"
      BS.drop 506 encoded `shouldBe` "fdfeff"

  describe "encodeBase16Short" $ do
    it "encodes a 16-byte TraceId-sized input" $ do
      let input = SBS.toShort $ BS.pack [0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe,
                                          0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]
      encodeBase16Short input `shouldBe` "deadbeefcafebabe0123456789abcdef"

    it "encodes an 8-byte SpanId-sized input" $ do
      let input = SBS.toShort $ BS.pack [0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe]
      encodeBase16Short input `shouldBe` "deadbeefcafebabe"

    it "encodes other sizes via fallback" $ do
      let input = SBS.toShort $ BS.pack [0x01, 0x02, 0x03]
      encodeBase16Short input `shouldBe` "010203"

  describe "decodeBase16" $ do
    it "decodes empty input" $ do
      decodeBase16 "" `shouldBe` Right ""

    it "decodes known test vectors" $ do
      decodeBase16 "48656c6c6f" `shouldBe` Right "Hello"
      decodeBase16 "deadbeef" `shouldBe` Right (BS.pack [0xde, 0xad, 0xbe, 0xef])

    it "handles uppercase hex digits" $ do
      decodeBase16 "DEADBEEF" `shouldBe` Right (BS.pack [0xde, 0xad, 0xbe, 0xef])

    it "handles mixed case" $ do
      decodeBase16 "DeAdBeEf" `shouldBe` Right (BS.pack [0xde, 0xad, 0xbe, 0xef])

    it "rejects odd-length input" $ do
      decodeBase16 "abc" `shouldSatisfy` isLeft

    it "rejects invalid hex chars" $ do
      decodeBase16 "zz" `shouldSatisfy` isLeft
      decodeBase16 "0g" `shouldSatisfy` isLeft

  describe "round-trip" $ do
    it "decode . encode == id for all byte values" $ do
      let allBytes = BS.pack [0 .. 255]
      decodeBase16 (encodeBase16 allBytes) `shouldBe` Right allBytes

    it "decode . encode == id for TraceId-sized input" $ do
      let input = BS.pack [0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe,
                            0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]
      decodeBase16 (encodeBase16 input) `shouldBe` Right input

    it "decode . encode == id for SpanId-sized input" $ do
      let input = BS.pack [0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe]
      decodeBase16 (encodeBase16 input) `shouldBe` Right input

    it "decode . encodeShort == id for TraceId-sized input" $ do
      let input = BS.pack [0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef,
                            0xfe, 0xdc, 0xba, 0x98, 0x76, 0x54, 0x32, 0x10]
      decodeBase16 (encodeBase16Short (SBS.toShort input)) `shouldBe` Right input

  describe "TraceId/SpanId encoding" $ do
    it "round-trips TraceId through hex" $ do
      let (Right tid) = baseEncodedToTraceId Base16 "0123456789abcdef0123456789abcdef"
      traceIdBaseEncodedByteString Base16 tid `shouldBe` "0123456789abcdef0123456789abcdef"

    it "round-trips SpanId through hex" $ do
      let (Right sid) = baseEncodedToSpanId Base16 "0123456789abcdef"
      spanIdBaseEncodedByteString Base16 sid `shouldBe` "0123456789abcdef"

    it "rejects wrong-length TraceId" $ do
      baseEncodedToTraceId Base16 "0123" `shouldSatisfy` isLeft

    it "rejects wrong-length SpanId" $ do
      baseEncodedToSpanId Base16 "0123" `shouldSatisfy` isLeft


isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft _ = False
