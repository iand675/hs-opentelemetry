{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

module OpenTelemetry.Internal.Trace.Encoding (
  Base (..),
  convertToBase,
  convertFromBase,
  encodeBase16,
  encodeBase16Short,
  decodeBase16,
) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Internal as BSI
import Data.ByteString.Short (ShortByteString, fromShort)
import qualified Data.ByteString.Short as SBS
import Data.ByteString.Short.Internal (ShortByteString (SBS))
import Data.Word (Word8)
import Foreign.C.Types (CSize (..), CInt (..))
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Ptr (Ptr)
import GHC.Exts (ByteArray#, Ptr (..), byteArrayContents#, keepAlive#)
import GHC.IO (unsafeDupablePerformIO, IO (..))


data Base = Base16


{-# INLINE convertToBase #-}
convertToBase :: Base -> ByteString -> ByteString
convertToBase Base16 = encodeBase16


{-# INLINE convertFromBase #-}
convertFromBase :: Base -> ByteString -> Either String ByteString
convertFromBase Base16 = decodeBase16


-- ── C FFI ──

foreign import ccall unsafe "hs_hex_encode_lut"
  c_hex_encode :: Ptr Word8 -> CSize -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_16_raw"
  c_hex_encode_16 :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_8_raw"
  c_hex_encode_8 :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_decode"
  c_hex_decode :: Ptr Word8 -> CSize -> Ptr Word8 -> IO CInt


-- ── Encode ──

-- | Encode a ByteString to Base16 (hex) via a C 256-entry lookup table.
-- Each input byte becomes a single 16-bit write (two hex chars).
encodeBase16 :: ByteString -> ByteString
encodeBase16 (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create (slen * 2) $ \dptr ->
      c_hex_encode sptr (fromIntegral slen) dptr


-- | Encode a ShortByteString to Base16 (hex) with zero intermediate copies.
-- Uses keepAlive# to pin the ByteArray# during the C call, and fully-unrolled
-- C loops for the fixed 16-byte (TraceId) and 8-byte (SpanId) sizes.
encodeBase16Short :: ShortByteString -> ByteString
encodeBase16Short sbs@(SBS ba#) = case SBS.length sbs of
  16 -> encodeShortDirect ba# 32 c_hex_encode_16
  8  -> encodeShortDirect ba# 16 c_hex_encode_8
  _  -> encodeBase16 (fromShort sbs)


{-# INLINE encodeShortDirect #-}
encodeShortDirect :: ByteArray# -> Int -> (Ptr Word8 -> Ptr Word8 -> IO ()) -> ByteString
encodeShortDirect ba# outLen encoder = unsafeDupablePerformIO $
  BSI.create outLen $ \dptr -> IO $ \s ->
    keepAlive# ba# s $ \s' ->
      case encoder (Ptr (byteArrayContents# ba#)) dptr of
        IO f -> f s'


-- ── Decode ──

-- | Decode a Base16 (hex) encoded ByteString via a C 256-entry lookup table.
decodeBase16 :: ByteString -> Either String ByteString
decodeBase16 (BSI.BS sfp slen)
  | slen == 0 = Right mempty
  | slen `mod` 2 /= 0 = Left "Base16-encoded data has odd length"
  | otherwise = unsafeDupablePerformIO $
      withForeignPtr sfp $ \sptr -> do
        let outLen = slen `div` 2
        out <- BSI.mallocByteString outLen
        rc <- withForeignPtr out $ \dptr ->
          c_hex_decode sptr (fromIntegral slen) dptr
        if rc == 0
          then pure $ Right $ BSI.BS out outLen
          else pure $ Left "Invalid hex digit in Base16-encoded data"


