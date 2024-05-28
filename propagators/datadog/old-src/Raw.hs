{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Strict #-}

module Raw (
  newTraceIdFromHeader,
  newSpanIdFromHeader,
  newHeaderFromTraceId,
  newHeaderFromSpanId,
  showWord64BS,
  readWord64BS,
  asciiWord8ToWord8,
  word8ToAsciiWord8,
) where

import Control.Monad.ST (ST, runST)
import Data.Bits (Bits (complement, shift, (.&.)))
import Data.ByteString (ByteString)
import qualified Data.ByteString.Internal as BI
import Data.ByteString.Short (ShortByteString)
import qualified Data.ByteString.Short.Internal as SBI
import qualified Data.Char as C
import Data.Primitive.ByteArray (
  ByteArray (ByteArray),
  MutableByteArray,
  freezeByteArray,
  indexByteArray,
  newByteArray,
  writeByteArray,
 )
import Data.Primitive.Ptr (writeOffPtr)
import Data.Word (Word64, Word8)
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Storable (peekElemOff)
import System.IO.Unsafe (unsafeDupablePerformIO)


newTraceIdFromHeader
  :: ByteString
  -- ^ ASCII numeric text
  -> ShortByteString
newTraceIdFromHeader bs =
  let len = 16 :: Int
      !(ByteArray ba) =
        runST $ do
          mba <- newByteArray len
          let w64 = readWord64BS bs
          writeByteArray mba 0 (0 :: Word64) -- fill zeros to one upper Word64-size area
          writeByteArrayNbo mba 1 w64 -- offset one Word64-size
          freezeByteArray mba 0 len
  in SBI.SBS ba


newSpanIdFromHeader
  :: ByteString
  -- ^ ASCII numeric text
  -> ShortByteString
newSpanIdFromHeader bs =
  let len = 8 :: Int
      !(ByteArray ba) =
        runST $ do
          mba <- newByteArray len
          let w64 = readWord64BS bs
          writeByteArrayNbo mba 0 w64
          freezeByteArray mba 0 len
  in SBI.SBS ba


{- | Write a primitive value to the byte array with network-byte-order (big-endian).
The offset is given in elements of type @a@ rather than in bytes.
-}
writeByteArrayNbo :: MutableByteArray s -> Int -> Word64 -> ST s ()
writeByteArrayNbo mba offset value = do
  writeByteArray mba offset (0 :: Word64)
  loop 0 value
  where
    loop _ 0 = pure ()
    loop 8 _ = pure ()
    loop n v = do
      let
        -- equivelent:
        --   (p, q) = v `divMod` (2 ^ (8 :: Int))
        p = shift v (-8)
        q = v .&. complement (shift p 8)
      writeByteArray mba (8 * (offset + 1) - n - 1) (fromIntegral q :: Word8)
      loop (n + 1) p


readWord64BS :: ByteString -> Word64
readWord64BS (BI.PS fptr _ len) =
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


newHeaderFromTraceId :: ShortByteString -> ByteString
newHeaderFromTraceId (SBI.SBS ba) =
  let w64 = indexByteArrayNbo (ByteArray ba) 1
  in showWord64BS w64


newHeaderFromSpanId :: ShortByteString -> ByteString
newHeaderFromSpanId (SBI.SBS ba) =
  let w64 = indexByteArrayNbo (ByteArray ba) 0
  in showWord64BS w64


indexByteArrayNbo :: ByteArray -> Int -> Word64
indexByteArrayNbo ba offset =
  loop 0 0
  where
    loop 8 acc = acc
    loop n acc = loop (n + 1) $ shift acc 8 + word8ToWord64 (indexByteArray ba $ 8 * offset + n)


showWord64BS :: Word64 -> ByteString
showWord64BS v =
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
