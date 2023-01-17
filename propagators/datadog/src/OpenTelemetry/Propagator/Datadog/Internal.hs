{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Strict #-}

{- | Conversion of the hs-opentelemetry internal representation of the trace ID and the span ID and the Datadog header representation of them each other.

+----------+-----------------+----------------+
|          | Trace ID        | Span ID        |
+----------+-----------------+----------------+
| Internal | 128-bit integer | 64-bit integer |
+----------+-----------------+----------------+
| Datadog  | ASCII text of   | ASCII text of  |
| Header   | 64-bit integer  | 64-bit integer |
+----------+-----------------+----------------+
-}
module OpenTelemetry.Propagator.Datadog.Internal (
  newTraceIdFromHeader,
  newSpanIdFromHeader,
  newHeaderFromTraceId,
  newHeaderFromSpanId,
  indexByteArrayNbo,
) where

import Data.Bits (Bits (shift))
import Data.ByteString (ByteString)
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Internal as BI
import qualified Data.ByteString.Lazy as BL
import Data.ByteString.Short (ShortByteString)
import qualified Data.ByteString.Short as SB
import qualified Data.ByteString.Short.Internal as SBI
import qualified Data.Char as C
import Data.Primitive.ByteArray (ByteArray (ByteArray), indexByteArray)
import Data.Primitive.Ptr (writeOffPtr)
import Data.Word (Word64, Word8)
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Storable (peekElemOff)
import System.IO.Unsafe (unsafeDupablePerformIO)


newTraceIdFromHeader ::
  -- | ASCII text of 64-bit integer
  ByteString ->
  -- | 128-bit integer
  ShortByteString
newTraceIdFromHeader bs =
  let
    w64 = readWord64BS bs
    builder = BB.word64BE 0 <> BB.word64BE w64
   in
    SB.toShort $ BL.toStrict $ BB.toLazyByteString builder


newSpanIdFromHeader ::
  -- | ASCII text of 64-bit integer
  ByteString ->
  -- | 64-bit integer
  ShortByteString
newSpanIdFromHeader bs =
  let
    w64 = readWord64BS bs
    builder = BB.word64BE w64
   in
    SB.toShort $ BL.toStrict $ BB.toLazyByteString builder


readWord64BS :: ByteString -> Word64
readWord64BS (BI.PS fptr _ len) =
  -- Safe.
  unsafeDupablePerformIO $
    withForeignPtr fptr readWord64Ptr
  where
    readWord64Ptr ptr =
      readWord64PtrOffset 0 0
      where
        readWord64PtrOffset offset acc
          | offset < len = do
              b <- peekElemOff ptr offset
              let n = fromIntegral $ asciiWord8ToWord8 b :: Word64
              readWord64PtrOffset (offset + 1) $ n + acc * 10
          | otherwise = pure acc


asciiWord8ToWord8 :: Word8 -> Word8
asciiWord8ToWord8 b = b - fromIntegral (C.ord '0')


newHeaderFromTraceId ::
  -- | 128-bit integer
  ShortByteString ->
  -- | ASCII text of 64-bit integer
  ByteString
newHeaderFromTraceId (SBI.SBS ba) =
  let w64 = indexByteArrayNbo (ByteArray ba) 1
   in showWord64BS w64


newHeaderFromSpanId ::
  -- | 64-bit integer
  ShortByteString ->
  -- | ASCII text of 64-bit integer
  ByteString
newHeaderFromSpanId (SBI.SBS ba) =
  let w64 = indexByteArrayNbo (ByteArray ba) 0
   in showWord64BS w64


-- | Read 'ByteArray' to 'Word64' with network-byte-order.
indexByteArrayNbo ::
  ByteArray ->
  -- | Offset in 'Word64'-size unit
  Int ->
  Word64
indexByteArrayNbo ba offset =
  loop 0 0
  where
    loop 8 acc = acc
    loop n acc = loop (n + 1) $ shift acc 8 + word8ToWord64 (indexByteArray ba $ 8 * offset + n)


showWord64BS :: Word64 -> ByteString
showWord64BS v =
  -- Safe.
  unsafeDupablePerformIO $
    BI.createUptoN 20 writeWord64Ptr -- 20 = length (show (maxBound :: Word64))
  where
    writeWord64Ptr ptr =
      loop (19 :: Int) v 0 False
      where
        loop 0 v offset _ = do
          writeOffPtr ptr offset (word8ToAsciiWord8 $ fromIntegral v)
          pure $ offset + 1
        loop n v offset upper = do
          let (p, q) = v `divMod` (10 ^ n)
          if p == 0 && not upper
            then loop (n - 1) q offset upper
            else do
              writeOffPtr ptr offset (word8ToAsciiWord8 $ fromIntegral p)
              loop (n - 1) q (offset + 1) True


word8ToAsciiWord8 :: Word8 -> Word8
word8ToAsciiWord8 b = b + fromIntegral (C.ord '0')


word8ToWord64 :: Word8 -> Word64
word8ToWord64 = fromIntegral
