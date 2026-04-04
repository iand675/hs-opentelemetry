{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

module OpenTelemetry.Internal.Trace.Id (
  TraceId (..),
  newTraceId,
  isEmptyTraceId,
  traceIdBytes,
  bytesToTraceId,
  baseEncodedToTraceId,
  traceIdBaseEncodedBuilder,
  traceIdBaseEncodedByteString,
  traceIdBaseEncodedText,
  SpanId (..),
  newSpanId,
  isEmptySpanId,
  spanIdBytes,
  bytesToSpanId,
  Base (..),
  baseEncodedToSpanId,
  spanIdBaseEncodedBuilder,
  spanIdBaseEncodedByteString,
  spanIdBaseEncodedText,
  -- * Fast C-based ID generation
  generateTraceIdDirect,
  generateSpanIdDirect,
  generateTraceIdSBS,
  generateSpanIdSBS,
  generateTraceIdBS,
  generateSpanIdBS,
) where

import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.ByteString.Builder (Builder)
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Internal as BI
import Data.ByteString.Short.Internal (
  ShortByteString (SBS),
  fromShort,
  toShort,
 )
import qualified Data.ByteString.Unsafe as BU
import Data.Hashable (Hashable)
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import Data.Word (Word8)
import Foreign.C.Types (CInt (..), CSize (..))
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Ptr (Ptr, castPtr)
import GHC.Exts (
  Ptr (Ptr),
  IsString (fromString),
  eqWord#,
  indexWord64Array#,
  int2Word#,
  isTrue#,
  or#,
  newPinnedByteArray#,
  unsafeFreezeByteArray#,
  mutableByteArrayContents#,
 )
import GHC.IO (IO (IO))
import GHC.Int (Int (I#))


#if MIN_VERSION_base(4,17,0)
import GHC.Exts (word64ToWord#)
#endif

import GHC.Generics (Generic)
import OpenTelemetry.Trace.Id.Generator (
  IdGenerator (genSpanIdSBS, genTraceIdSBS),
 )
import Prelude hiding (length)
import System.IO.Unsafe (unsafePerformIO)


-- | Base encoding scheme. Only 'Base16' (hexadecimal) is supported.
data Base = Base16
  deriving (Show, Eq)


foreign import ccall unsafe "hs_otel_encode_trace_id"
  c_encodeTraceId :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_otel_encode_span_id"
  c_encodeSpanId :: Ptr Word8 -> Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_otel_decode_hex"
  c_decodeHex :: Ptr Word8 -> Ptr Word8 -> CSize -> IO CInt


-- | A valid trace identifier is a 16-byte array with at least one non-zero byte.
newtype TraceId = TraceId ShortByteString
  deriving stock (Ord, Eq, Generic)
  deriving newtype (Hashable)


-- | A valid span identifier is an 8-byte array with at least one non-zero byte.
newtype SpanId = SpanId ShortByteString
  deriving stock (Ord, Eq)
  deriving newtype (Hashable)


instance Show TraceId where
  showsPrec d i = showParen (d > 10) $ showString "TraceId " . showsPrec 11 (traceIdBaseEncodedText Base16 i)


instance IsString TraceId where
  fromString str = case baseEncodedToTraceId Base16 (fromString str) of
    Left err -> error err
    Right ok -> ok


instance Show SpanId where
  showsPrec d i = showParen (d > 10) $ showString "SpanId " . showsPrec 11 (spanIdBaseEncodedText Base16 i)


instance IsString SpanId where
  fromString str = case baseEncodedToSpanId Base16 (fromString str) of
    Left err -> error err
    Right ok -> ok


{- | Generate a 'TraceId' using the provided 'IdGenerator'

 This function is generally called by the @hs-opentelemetry-sdk@,
 but may be useful in some testing situations.

 @since 0.1.0.0
-}
newTraceId :: (MonadIO m) => IdGenerator -> m TraceId
newTraceId gen = liftIO (TraceId <$> genTraceIdSBS gen)
{-# INLINE newTraceId #-}


{- | Check whether all bytes in the 'TraceId' are zero.

 @since 0.1.0.0
-}
isEmptyTraceId :: TraceId -> Bool
#if MIN_VERSION_base(4,17,0)
isEmptyTraceId (TraceId (SBS arr)) =
  isTrue#
    (eqWord#
      (or#
        (word64ToWord# (indexWord64Array# arr 0#))
        (word64ToWord# (indexWord64Array# arr 1#)))
      (int2Word# 0#))
#else
isEmptyTraceId (TraceId (SBS arr)) =
  isTrue#
    (eqWord#
      (or#
        (indexWord64Array# arr 0#)
        (indexWord64Array# arr 1#))
      (int2Word# 0#))
#endif
{-# INLINE isEmptyTraceId #-}


{- | Access the byte-level representation of the provided 'TraceId'

 @since 0.1.0.0
-}
traceIdBytes :: TraceId -> ByteString
traceIdBytes (TraceId bytes) = fromShort bytes


{- | Convert a 'ByteString' to a 'TraceId'. Will fail if the 'ByteString'
 is not exactly 16 bytes long.

 @since 0.1.0.0
-}
bytesToTraceId :: ByteString -> Either String TraceId
bytesToTraceId bs =
  if BS.length bs == 16
    then Right $ TraceId $ toShort bs
    else Left "bytesToTraceId: TraceId must be 16 bytes long"


{- | Convert a 'ByteString' of a specified base-encoding into a 'TraceId'.
 Will fail if the decoded value is not exactly 16 bytes long.

 @since 0.1.0.0
-}
baseEncodedToTraceId :: Base -> ByteString -> Either String TraceId
baseEncodedToTraceId Base16 bs = do
  r <- decodeHex bs
  bytesToTraceId r


{- | Output a 'TraceId' into a base-encoded bytestring 'Builder'.

 @since 0.1.0.0
-}
traceIdBaseEncodedBuilder :: Base -> TraceId -> Builder
traceIdBaseEncodedBuilder Base16 = B.byteString . traceIdBaseEncodedByteString Base16


{- | Output a 'TraceId' into a base-encoded 'ByteString'.

 Uses SIMD-accelerated encoding (SSSE3 on x86_64, NEON on aarch64).

 @since 0.1.0.0
-}
traceIdBaseEncodedByteString :: Base -> TraceId -> ByteString
traceIdBaseEncodedByteString Base16 tid =
  BI.unsafeCreate 32 $ \dst ->
    BU.unsafeUseAsCStringLen (traceIdBytes tid) $ \(src, _) ->
      c_encodeTraceId (castPtr src) dst


{- | Output a 'TraceId' into a base-encoded 'Text'.

 @since 0.1.0.0
-}
traceIdBaseEncodedText :: Base -> TraceId -> Text
traceIdBaseEncodedText b = decodeUtf8 . traceIdBaseEncodedByteString b


{- | Generate a 'SpanId' using the provided 'IdGenerator'

 This function is generally called by the @hs-opentelemetry-sdk@,
 but may be useful in some testing situations.

 @since 0.1.0.0
-}
newSpanId :: (MonadIO m) => IdGenerator -> m SpanId
newSpanId gen = liftIO (SpanId <$> genSpanIdSBS gen)
{-# INLINE newSpanId #-}


{- | Check whether all bytes in the 'SpanId' are zero.

 @since 0.1.0.0
-}
isEmptySpanId :: SpanId -> Bool
#if MIN_VERSION_base(4,17,0)
isEmptySpanId (SpanId (SBS arr)) = isTrue#
  (eqWord#
    (word64ToWord# (indexWord64Array# arr 0#))
    (int2Word# 0#))
#else
isEmptySpanId (SpanId (SBS arr)) = isTrue#
  (eqWord#
    (indexWord64Array# arr 0#)
    (int2Word# 0#))
#endif
{-# INLINE isEmptySpanId #-}


{- | Access the byte-level representation of the provided 'SpanId'

 @since 0.1.0.0
-}
spanIdBytes :: SpanId -> ByteString
spanIdBytes (SpanId bytes) = fromShort bytes


{- | Convert a 'ByteString' of a specified base-encoding into a 'SpanId'.
 Will fail if the decoded value is not exactly 8 bytes long.

 @since 0.1.0.0
-}
bytesToSpanId :: ByteString -> Either String SpanId
bytesToSpanId bs =
  if BS.length bs == 8
    then Right $ SpanId $ toShort bs
    else Left "bytesToSpanId: SpanId must be 8 bytes long"


{- | Convert a 'ByteString' of a specified base-encoding into a 'SpanId'.
 Will fail if the decoded value is not exactly 8 bytes long.

 @since 0.1.0.0
-}
baseEncodedToSpanId :: Base -> ByteString -> Either String SpanId
baseEncodedToSpanId Base16 bs = do
  r <- decodeHex bs
  bytesToSpanId r


{- | Output a 'SpanId' into a base-encoded bytestring 'Builder'.

 @since 0.1.0.0
-}
spanIdBaseEncodedBuilder :: Base -> SpanId -> Builder
spanIdBaseEncodedBuilder Base16 = B.byteString . spanIdBaseEncodedByteString Base16


{- | Output a 'SpanId' into a base-encoded 'ByteString'.

 Uses SIMD-accelerated encoding (SSSE3 on x86_64, NEON on aarch64).

 @since 0.1.0.0
-}
spanIdBaseEncodedByteString :: Base -> SpanId -> ByteString
spanIdBaseEncodedByteString Base16 sid =
  BI.unsafeCreate 16 $ \dst ->
    BU.unsafeUseAsCStringLen (spanIdBytes sid) $ \(src, _) ->
      c_encodeSpanId (castPtr src) dst


{- | Output a 'SpanId' into a base-encoded 'Text'.

 @since 0.1.0.0
-}
spanIdBaseEncodedText :: Base -> SpanId -> Text
spanIdBaseEncodedText b = decodeUtf8 . spanIdBaseEncodedByteString b


foreign import ccall unsafe "hs_otel_gen_trace_id"
  c_genTraceId :: Ptr Word8 -> IO CInt

foreign import ccall unsafe "hs_otel_gen_span_id"
  c_genSpanId :: Ptr Word8 -> IO CInt


-- | Generate a 'TraceId' using the platform's native CSPRNG
-- (arc4random_buf on macOS, getrandom on Linux).
generateTraceIdDirect :: IO TraceId
generateTraceIdDirect = do
  sbs <- generateRandomSBS 16 c_genTraceId
  pure $! TraceId sbs
{-# INLINE generateTraceIdDirect #-}


-- | Generate a 'SpanId' using the platform's native CSPRNG
-- (arc4random_buf on macOS, getrandom on Linux).
generateSpanIdDirect :: IO SpanId
generateSpanIdDirect = do
  sbs <- generateRandomSBS 8 c_genSpanId
  pure $! SpanId sbs
{-# INLINE generateSpanIdDirect #-}


-- | Generate 16 random bytes as a 'ShortByteString' via the platform CSPRNG.
generateTraceIdSBS :: IO ShortByteString
generateTraceIdSBS = generateRandomSBS 16 c_genTraceId
{-# INLINE generateTraceIdSBS #-}


-- | Generate 8 random bytes as a 'ShortByteString' via the platform CSPRNG.
generateSpanIdSBS :: IO ShortByteString
generateSpanIdSBS = generateRandomSBS 8 c_genSpanId
{-# INLINE generateSpanIdSBS #-}


-- | Generate 16 random bytes as a strict 'ByteString' via the platform CSPRNG.
generateTraceIdBS :: IO ByteString
generateTraceIdBS = BI.create 16 $ \ptr -> do
  _ <- c_genTraceId ptr
  pure ()
{-# INLINE generateTraceIdBS #-}


-- | Generate 8 random bytes as a strict 'ByteString' via the platform CSPRNG.
generateSpanIdBS :: IO ByteString
generateSpanIdBS = BI.create 8 $ \ptr -> do
  _ <- c_genSpanId ptr
  pure ()
{-# INLINE generateSpanIdBS #-}


generateRandomSBS :: Int -> (Ptr Word8 -> IO CInt) -> IO ShortByteString
generateRandomSBS (I# n) cffi = IO $ \s0 ->
  case newPinnedByteArray# n s0 of
    (# s1, mba #) ->
      let !ptr = Ptr (mutableByteArrayContents# mba)
      in case unIO (cffi ptr) s1 of
        (# s2, _ #) ->
          case unsafeFreezeByteArray# mba s2 of
            (# s3, ba #) -> (# s3, SBS ba #)
  where
    unIO (IO f) = f
{-# INLINE generateRandomSBS #-}


-- | Decode a hex-encoded ByteString into raw bytes via C FFI.
decodeHex :: ByteString -> Either String ByteString
decodeHex hexBs
  | odd (BS.length hexBs) = Left "invalid hex: odd length"
  | BS.null hexBs = Right BS.empty
  | otherwise = unsafePerformIO $
      BU.unsafeUseAsCStringLen hexBs $ \(src, srcLen) -> do
        let outLen = srcLen `div` 2
        allocaBytes outLen $ \dst -> do
          rc <- c_decodeHex (castPtr src) dst (fromIntegral outLen)
          if rc == 0
            then do
              bs <- BS.packCStringLen (castPtr dst, outLen)
              pure (Right bs)
            else pure (Left "invalid hex character")
