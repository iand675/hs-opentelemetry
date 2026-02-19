{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

module Main where

import Criterion.Main
import Data.Bits (shiftR, (.&.))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Internal as BSI
import Data.ByteString.Short (ShortByteString)
import qualified Data.ByteString.Short as SBS
import Data.ByteString.Short.Internal (ShortByteString (SBS))
import Data.Word (Word8, Word16)
import Foreign.C.Types (CSize (..), CInt (..))
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Ptr (Ptr)
import Foreign.Storable (peekByteOff, pokeByteOff)
import GHC.Exts (ByteArray#, byteArrayContents#, Ptr (..), keepAlive#, State#, RealWorld)
import GHC.IO (unsafeDupablePerformIO, IO (..))


-- ── FFI declarations ──

foreign import ccall unsafe "hs_hex_encode_lut"
  c_hex_encode_lut :: Ptr Word8 -> CSize -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_lut_unrolled"
  c_hex_encode_lut_unrolled :: Ptr Word8 -> CSize -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_arith"
  c_hex_encode_arith :: Ptr Word8 -> CSize -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_16"
  c_hex_encode_16 :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_8"
  c_hex_encode_8 :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_wide"
  c_hex_encode_wide :: Ptr Word8 -> CSize -> Ptr Word8 -> IO ()


-- ── Haskell strategies ──

-- Strategy A: current code (nibble table, peekByteOff/pokeByteOff loop)
{-# NOINLINE hexTable #-}
hexTable :: ByteString
hexTable = "0123456789abcdef"

encodeHaskellNibbleTable :: ByteString -> ByteString
encodeHaskellNibbleTable (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
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

encodeHaskellNibbleTableShort :: ShortByteString -> ByteString
encodeHaskellNibbleTableShort sbs = unsafeDupablePerformIO $ do
  let slen = SBS.length sbs
  BSI.createAndTrim (slen * 2) $ \dptr ->
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


-- ── C-backed wrappers ──

encodeCLut :: ByteString -> ByteString
encodeCLut (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create (slen * 2) $ \dptr ->
      c_hex_encode_lut sptr (fromIntegral slen) dptr

encodeCLutUnrolled :: ByteString -> ByteString
encodeCLutUnrolled (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create (slen * 2) $ \dptr ->
      c_hex_encode_lut_unrolled sptr (fromIntegral slen) dptr

encodeCArith :: ByteString -> ByteString
encodeCArith (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create (slen * 2) $ \dptr ->
      c_hex_encode_arith sptr (fromIntegral slen) dptr

encodeCWide :: ByteString -> ByteString
encodeCWide (BSI.BS sfp slen) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create (slen * 2) $ \dptr ->
      c_hex_encode_wide sptr (fromIntegral slen) dptr

-- Fixed-size wrappers that avoid the length parameter
encodeCFixed16 :: ByteString -> ByteString
encodeCFixed16 (BSI.BS sfp _) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create 32 $ \dptr ->
      c_hex_encode_16 sptr dptr

encodeCFixed8 :: ByteString -> ByteString
encodeCFixed8 (BSI.BS sfp _) = unsafeDupablePerformIO $
  withForeignPtr sfp $ \sptr ->
    BSI.create 16 $ \dptr ->
      c_hex_encode_8 sptr dptr

-- ShortByteString variants for C (need to copy to pinned memory first)
encodeCLutShort :: ShortByteString -> ByteString
encodeCLutShort sbs = encodeCLut (SBS.fromShort sbs)

encodeCFixed16Short :: ShortByteString -> ByteString
encodeCFixed16Short sbs = encodeCFixed16 (SBS.fromShort sbs)


-- ── Direct ByteArray# access (avoids fromShort copy) ──

foreign import ccall unsafe "hs_hex_encode_16_raw"
  c_hex_encode_16_raw :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_hex_encode_8_raw"
  c_hex_encode_8_raw :: Ptr Word8 -> Ptr Word8 -> IO ()

-- Use keepAlive# to pin the ByteArray# during the FFI call.
-- byteArrayContents# gives us a raw pointer into the ByteArray#'s payload;
-- keepAlive# ensures the GC won't move or collect it until we're done.
encodeCFixed16ShortDirect :: ShortByteString -> ByteString
encodeCFixed16ShortDirect (SBS ba#) = unsafeDupablePerformIO $
  BSI.create 32 $ \dptr -> IO $ \s ->
    keepAlive# ba# s $ \s' ->
      case unIO (c_hex_encode_16_raw (Ptr (byteArrayContents# ba#)) dptr) s' of
        (# s'', () #) -> (# s'', () #)

encodeCFixed8ShortDirect :: ShortByteString -> ByteString
encodeCFixed8ShortDirect (SBS ba#) = unsafeDupablePerformIO $
  BSI.create 16 $ \dptr -> IO $ \s ->
    keepAlive# ba# s $ \s' ->
      case unIO (c_hex_encode_8_raw (Ptr (byteArrayContents# ba#)) dptr) s' of
        (# s'', () #) -> (# s'', () #)

unIO :: IO a -> State# RealWorld -> (# State# RealWorld, a #)
unIO (IO f) = f


-- ── Haskell with 256-entry Word16 LUT ──

{-# NOINLINE hexLUT16 #-}
hexLUT16 :: ByteString
hexLUT16 = BSI.unsafePackLenBytes 512 $ do
  b <- [0..255 :: Int]
  let w = fromIntegral b :: Word8
      hi = w `shiftR` 4
      lo = w .&. 0x0f
      hexNibble n = if n < 10 then 0x30 + n else 0x57 + n
  [hexNibble hi, hexNibble lo]

encodeHaskellLUT16Short :: ShortByteString -> ByteString
encodeHaskellLUT16Short sbs = unsafeDupablePerformIO $ do
  let slen = SBS.length sbs
  withForeignPtr lutFp $ \lut ->
    BSI.create (slen * 2) $ \dptr -> do
      let go !si !di
            | si >= slen = pure ()
            | otherwise = do
                let idx = fromIntegral (SBS.index sbs si) * 2
                h <- peekByteOff lut idx :: IO Word8
                l <- peekByteOff lut (idx + 1) :: IO Word8
                pokeByteOff dptr di h
                pokeByteOff dptr (di + 1) l
                go (si + 1) (di + 2)
      go 0 0
  where
    (BSI.BS lutFp _) = hexLUT16

-- Word16 write variant: read 2 bytes from LUT as Word16, write as Word16
encodeHaskellLUT16ShortW16 :: ShortByteString -> ByteString
encodeHaskellLUT16ShortW16 sbs = unsafeDupablePerformIO $ do
  let slen = SBS.length sbs
  withForeignPtr lutFp $ \lut ->
    BSI.create (slen * 2) $ \dptr -> do
      let go !si !di
            | si >= slen = pure ()
            | otherwise = do
                let idx = fromIntegral (SBS.index sbs si) * 2
                w16 <- peekByteOff lut idx :: IO Word16
                pokeByteOff dptr di w16
                go (si + 1) (di + 2)
      go 0 0
  where
    (BSI.BS lutFp _) = hexLUT16


main :: IO ()
main = do
  -- 16 bytes = TraceId, 8 bytes = SpanId
  let traceBytes = BS.pack [0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe,
                             0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]
  let spanBytes  = BS.pack [0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe]
  let traceSBS   = SBS.toShort traceBytes
  let spanSBS    = SBS.toShort spanBytes

  let expected16 = "deadbeefcafebabe0123456789abcdef"
  let expected8  = "deadbeefcafebabe"

  -- Sanity checks
  let check name f input expected =
        let result = f input
        in if result /= expected
           then error $ name ++ ": got " ++ show result ++ " expected " ++ show expected
           else putStrLn $ name ++ ": OK"

  check "haskell-nibble-16"     encodeHaskellNibbleTable traceBytes expected16
  check "haskell-nibble-8"      encodeHaskellNibbleTable spanBytes  expected8
  check "c-lut-16"              encodeCLut               traceBytes expected16
  check "c-lut-unrolled-16"     encodeCLutUnrolled       traceBytes expected16
  check "c-arith-16"            encodeCArith             traceBytes expected16
  check "c-wide-16"             encodeCWide              traceBytes expected16
  check "c-fixed-16"            encodeCFixed16           traceBytes expected16
  check "c-fixed-8"             encodeCFixed8            spanBytes  expected8
  check "haskell-nibble-short-16" encodeHaskellNibbleTableShort traceSBS expected16
  check "c-lut-short-16"        encodeCLutShort          traceSBS expected16
  check "c-fixed16-short-16"    encodeCFixed16Short      traceSBS expected16
  check "c-fixed16-short-direct" encodeCFixed16ShortDirect traceSBS expected16
  check "c-fixed8-short-direct"  encodeCFixed8ShortDirect  spanSBS  expected8
  check "haskell-lut16-short"   encodeHaskellLUT16Short  traceSBS expected16
  check "haskell-lut16w16-short" encodeHaskellLUT16ShortW16 traceSBS expected16

  defaultMain
    [ bgroup "encode-traceId-16B"
      [ bench "haskell-nibble-table"   $ whnf encodeHaskellNibbleTable traceBytes
      , bench "c-lut"                  $ whnf encodeCLut               traceBytes
      , bench "c-lut-unrolled"         $ whnf encodeCLutUnrolled       traceBytes
      , bench "c-arith"               $ whnf encodeCArith             traceBytes
      , bench "c-wide-64bit"           $ whnf encodeCWide              traceBytes
      , bench "c-fixed-16"             $ whnf encodeCFixed16           traceBytes
      ]
    , bgroup "encode-spanId-8B"
      [ bench "haskell-nibble-table"   $ whnf encodeHaskellNibbleTable spanBytes
      , bench "c-lut"                  $ whnf encodeCLut               spanBytes
      , bench "c-lut-unrolled"         $ whnf encodeCLutUnrolled       spanBytes
      , bench "c-arith"               $ whnf encodeCArith             spanBytes
      , bench "c-wide-64bit"           $ whnf encodeCWide              spanBytes
      , bench "c-fixed-8"              $ whnf encodeCFixed8            spanBytes
      ]
    , bgroup "encode-traceId-short-16B"
      [ bench "haskell-nibble-table"    $ whnf encodeHaskellNibbleTableShort traceSBS
      , bench "haskell-lut16"           $ whnf encodeHaskellLUT16Short       traceSBS
      , bench "haskell-lut16-w16"       $ whnf encodeHaskellLUT16ShortW16    traceSBS
      , bench "c-lut-via-fromShort"     $ whnf encodeCLutShort               traceSBS
      , bench "c-fixed16-via-fromShort" $ whnf encodeCFixed16Short           traceSBS
      , bench "c-fixed16-direct"        $ whnf encodeCFixed16ShortDirect     traceSBS
      ]
    , bgroup "encode-spanId-short-8B"
      [ bench "haskell-nibble-table"    $ whnf encodeHaskellNibbleTableShort spanSBS
      , bench "haskell-lut16-w16"       $ whnf encodeHaskellLUT16ShortW16    spanSBS
      , bench "c-fixed8-direct"         $ whnf encodeCFixed8ShortDirect      spanSBS
      ]
    ]
