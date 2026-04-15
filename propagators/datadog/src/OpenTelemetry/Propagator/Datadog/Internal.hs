{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Conversion between OTel trace/span IDs (Word64-based) and Datadog
header format (decimal ASCII of a 64-bit integer, big-endian byte order).

@
+----------+-----------------+----------------+
|          | Trace ID        | Span ID        |
+----------+-----------------+----------------+
| Internal | 2 x Word64 (LE)| 1 x Word64 (LE)|
+----------+-----------------+----------------+
| Datadog  | ASCII text of   | ASCII text of  |
| Header   | 64-bit integer  | 64-bit integer |
+----------+-----------------+----------------+
@
-}
module OpenTelemetry.Propagator.Datadog.Internal (
  newTraceIdFromHeader,
  newSpanIdFromHeader,
  newHeaderFromTraceId,
  newHeaderFromSpanId,
) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Internal as BI
import Data.Primitive.Ptr (writeOffPtr)
import Data.Word (Word64, Word8, byteSwap64)
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Storable (peekElemOff)
import OpenTelemetry.Internal.Trace.Id (SpanId (..), TraceId (..))
import System.IO.Unsafe (unsafeDupablePerformIO)


{- | Parse a decimal ASCII header value into a 'TraceId'.
Datadog uses the low 64 bits of the 128-bit trace ID, in big-endian.
The high 64 bits are set to zero.
-}
newTraceIdFromHeader :: ByteString -> TraceId
newTraceIdFromHeader bs =
  let !w64 = readWord64BS bs
  in TraceId 0 (byteSwap64 w64)


-- | Parse a decimal ASCII header value into a 'SpanId'.
newSpanIdFromHeader :: ByteString -> SpanId
newSpanIdFromHeader bs = SpanId (byteSwap64 (readWord64BS bs))


{- | Render the low 64 bits of a 'TraceId' as a decimal ASCII string
(Datadog header format).
-}
newHeaderFromTraceId :: TraceId -> ByteString
newHeaderFromTraceId (TraceId _hi lo) = showWord64BS (byteSwap64 lo)


-- | Render a 'SpanId' as a decimal ASCII string (Datadog header format).
newHeaderFromSpanId :: SpanId -> ByteString
newHeaderFromSpanId (SpanId w) = showWord64BS (byteSwap64 w)


-- ---------------------------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------------------------

readWord64BS :: ByteString -> Word64
readWord64BS (BI.PS fptr _ len) =
  unsafeDupablePerformIO $
    withForeignPtr fptr $ \ptr ->
      let go !offset !acc
            | offset < len = do
                b <- peekElemOff ptr offset
                let !n = fromIntegral (asciiDigit b) :: Word64
                go (offset + 1) (acc * 10 + n)
            | otherwise = pure acc
      in go 0 0


asciiDigit :: Word8 -> Word8
asciiDigit b = b - 0x30


showWord64BS :: Word64 -> ByteString
showWord64BS v =
  unsafeDupablePerformIO $
    BI.createUptoN 20 $ \ptr ->
      let go :: Int -> Word64 -> Int -> Bool -> IO Int
          go 0 v' offset _ = do
            writeOffPtr ptr offset (toAsciiDigit $ fromIntegral v')
            pure $ offset + 1
          go n v' offset upper = do
            let (!p, !q) = v' `divMod` (10 ^ n)
            if p == 0 && not upper
              then go (n - 1) q offset upper
              else do
                writeOffPtr ptr offset (toAsciiDigit $ fromIntegral p)
                go (n - 1) q (offset + 1) True
      in go (19 :: Int) v 0 False


toAsciiDigit :: Word8 -> Word8
toAsciiDigit b = b + 0x30
