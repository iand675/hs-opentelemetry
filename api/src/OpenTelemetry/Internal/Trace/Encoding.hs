{-# LANGUAGE BangPatterns #-}

module OpenTelemetry.Internal.Trace.Encoding (
  Base (..),
  convertToBase,
  convertFromBase,
) where

import Data.Bits (shiftL, shiftR, (.&.), (.|.))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Word (Word8)


data Base = Base16


{-# INLINE convertToBase #-}
convertToBase :: Base -> ByteString -> ByteString
convertToBase Base16 = encodeBase16


{-# INLINE convertFromBase #-}
convertFromBase :: Base -> ByteString -> Either String ByteString
convertFromBase Base16 = decodeBase16


encodeBase16 :: ByteString -> ByteString
encodeBase16 input = BS.pack $ BS.foldr step [] input
  where
    step w acc =
      let hi = w `shiftR` 4
          lo = w .&. 0x0f
      in hexDigit hi : hexDigit lo : acc


decodeBase16 :: ByteString -> Either String ByteString
decodeBase16 input
  | BS.length input `mod` 2 /= 0 = Left "Base16-encoded data has odd length"
  | otherwise = go 0 []
  where
    len = BS.length input
    go !i !acc
      | i >= len = Right $ BS.pack $ reverse acc
      | otherwise =
          case (,) <$> fromHexDigit (BS.index input i) <*> fromHexDigit (BS.index input (i + 1)) of
            Nothing -> Left "Invalid hex digit in Base16-encoded data"
            Just (hi, lo) -> go (i + 2) ((hi `shiftL` 4 .|. lo) : acc)


{-# INLINE hexDigit #-}
hexDigit :: Word8 -> Word8
hexDigit x
  | x < 10 = 0x30 + x
  | otherwise = 0x57 + x


{-# INLINE fromHexDigit #-}
fromHexDigit :: Word8 -> Maybe Word8
fromHexDigit w
  | w >= 0x30 && w <= 0x39 = Just (w - 0x30)
  | w >= 0x41 && w <= 0x46 = Just (w - 0x37)
  | w >= 0x61 && w <= 0x66 = Just (w - 0x57)
  | otherwise = Nothing
