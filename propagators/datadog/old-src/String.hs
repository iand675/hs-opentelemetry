module String where

import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Short as SB
import Data.Word (Word64)


newTraceIdFromHeader :: ByteString -> SB.ShortByteString
newTraceIdFromHeader = SB.toShort . fillLeadingZeros 16 . convertWord64ToBinaryByteString . read . BC.unpack


newSpanIdFromHeader :: ByteString -> SB.ShortByteString
newSpanIdFromHeader = SB.toShort . fillLeadingZeros 8 . convertWord64ToBinaryByteString . read . BC.unpack


newHeaderFromTraceId :: SB.ShortByteString -> ByteString
newHeaderFromTraceId = BC.pack . show . convertBinaryByteStringToWord64 . SB.fromShort


newHeaderFromSpanId :: SB.ShortByteString -> ByteString
newHeaderFromSpanId = BC.pack . show . convertBinaryByteStringToWord64 . SB.fromShort


convertWord64ToBinaryByteString :: Word64 -> ByteString
convertWord64ToBinaryByteString =
  B.pack . toWord8s []
  where
    toWord8s acc 0 = acc
    toWord8s acc n =
      let (p, q) = n `divMod` (2 ^ (8 :: Int))
      in toWord8s (fromIntegral q : acc) p


fillLeadingZeros :: Word -> ByteString -> ByteString
fillLeadingZeros len bs = B.replicate (fromIntegral len - B.length bs) 0 <> bs


convertBinaryByteStringToWord64 :: ByteString -> Word64
convertBinaryByteStringToWord64 = B.foldl (\acc b -> (2 ^ (8 :: Int)) * acc + fromIntegral b) 0 -- GHC.Prim.indexWord8ArrayAsWord64# とか駆使すると早くなりそう
