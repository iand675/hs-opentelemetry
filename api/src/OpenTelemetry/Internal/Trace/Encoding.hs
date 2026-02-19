{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}

module OpenTelemetry.Internal.Trace.Encoding (
  Base (..),
  convertToBase,
  convertFromBase,
  encodeBase16,
  encodeBase16Short,
  decodeBase16,
) where

import Data.Bits (shiftL, shiftR, (.&.), (.|.))
import Data.ByteString (ByteString)
import qualified Data.ByteString.Internal as BSI
import Data.ByteString.Short (ShortByteString)
import qualified Data.ByteString.Short as SBS
import Data.Word (Word8)
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Ptr (Ptr, plusPtr)
import Foreign.Storable (peekByteOff, pokeByteOff)
import GHC.IO (unsafeDupablePerformIO)


data Base = Base16


{-# INLINE convertToBase #-}
convertToBase :: Base -> ByteString -> ByteString
convertToBase Base16 = encodeBase16


{-# INLINE convertFromBase #-}
convertFromBase :: Base -> ByteString -> Either String ByteString
convertFromBase Base16 = decodeBase16


-- Nibble-to-hex lookup: branchless via table. The NOINLINE keeps one copy in
-- the data section; the inner loops index it through a pointer.
{-# NOINLINE hexTable #-}
hexTable :: ByteString
hexTable = "0123456789abcdef"


-- | Encode a ByteString to Base16 (hex). Allocates a single output buffer and
-- writes directly into it with no intermediate structures.
encodeBase16 :: ByteString -> ByteString
encodeBase16 (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    encodeToHex sptr slen


-- | Encode a ShortByteString to Base16 (hex) without an intermediate
-- ByteString copy. This avoids the fromShort allocation on the encode path.
encodeBase16Short :: ShortByteString -> ByteString
encodeBase16Short sbs = unsafeDupablePerformIO $ do
  -- Copy the short bytestring bytes into a temporary pinned buffer so we can
  -- hand a Ptr to the inner loop. ShortByteStrings live on the GC heap, so we
  -- can't take a stable pointer to them.  For 8-16 byte IDs the copy is cheap
  -- and keeps the hot loop simple.
  let slen = SBS.length sbs
  BSI.createAndTrim (slen * 2) $ \dptr -> do
    -- Write hex directly while reading from ShortByteString by index
    withForeignPtr htblFp $ \htbl -> do
      let go !si !di
            | si >= slen = pure (slen * 2)
            | otherwise = do
                let w = SBS.index sbs si
                    hi = w `shiftR` 4
                    lo = w .&. 0x0f
                h <- peekByteOff htbl (fromIntegral hi) :: IO Word8
                l <- peekByteOff htbl (fromIntegral lo) :: IO Word8
                pokeByteOff dptr di h
                pokeByteOff dptr (di + 1) l
                go (si + 1) (di + 2)
      go 0 0
  where
    (BSI.BS htblFp _) = hexTable


-- Shared encode loop: reads from raw Ptr, writes hex into a new ByteString.
{-# INLINE encodeToHex #-}
encodeToHex :: Ptr Word8 -> Int -> IO ByteString
encodeToHex sptr slen =
  withForeignPtr htblFp $ \htbl ->
    BSI.create (slen * 2) $ \dptr -> do
      let go !si !di
            | si >= slen = pure ()
            | otherwise = do
                w <- peekByteOff sptr si :: IO Word8
                let hi = w `shiftR` 4
                    lo = w .&. 0x0f
                h <- peekByteOff htbl (fromIntegral hi) :: IO Word8
                l <- peekByteOff htbl (fromIntegral lo) :: IO Word8
                pokeByteOff dptr di h
                pokeByteOff dptr (di + 1) l
                go (si + 1) (di + 2)
      go 0 0
  where
    (BSI.BS htblFp _) = hexTable


-- Decoding lookup table: 256 entries, 0xFF marks invalid hex chars.
-- Valid entries map ASCII hex digit to its 0-15 nibble value.
{-# NOINLINE decodeLUT #-}
decodeLUT :: ByteString
decodeLUT = BSI.unsafePackLenBytes 256 $ do
  i <- [0 .. 255 :: Int]
  let w = fromIntegral i :: Word8
  pure $
    if w >= 0x30 && w <= 0x39
      then w - 0x30
      else
        if w >= 0x41 && w <= 0x46
          then w - 0x37
          else
            if w >= 0x61 && w <= 0x66
              then w - 0x57
              else 0xFF


-- | Decode a Base16 (hex) encoded ByteString. Allocates a single output buffer.
decodeBase16 :: ByteString -> Either String ByteString
decodeBase16 (BSI.BS sfp slen)
  | slen == 0 = Right mempty
  | slen `mod` 2 /= 0 = Left "Base16-encoded data has odd length"
  | otherwise = unsafeDupablePerformIO $
      withForeignPtr sfp $ \sptr ->
        withForeignPtr lutFp $ \lut -> do
          let outLen = slen `div` 2
          out <- BSI.mallocByteString outLen
          result <- withForeignPtr out $ \dptr -> do
            let go !si !di
                  | si >= slen = pure True
                  | otherwise = do
                      hiRaw <- peekByteOff sptr si :: IO Word8
                      loRaw <- peekByteOff sptr (si + 1) :: IO Word8
                      hi <- peekByteOff lut (fromIntegral hiRaw) :: IO Word8
                      lo <- peekByteOff lut (fromIntegral loRaw) :: IO Word8
                      if hi == 0xFF || lo == 0xFF
                        then pure False
                        else do
                          pokeByteOff dptr di ((hi `shiftL` 4) .|. lo)
                          go (si + 2) (di + 1)
            go 0 0
          if result
            then pure $ Right $ BSI.BS out outLen
            else pure $ Left "Invalid hex digit in Base16-encoded data"
  where
    (BSI.BS lutFp _) = decodeLUT
