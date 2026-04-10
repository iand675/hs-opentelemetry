{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}

{- |
Module      : OpenTelemetry.Internal.Trace.Id
Description : Internal representation of trace and span identifiers with hex encoding via C FFI.
Stability   : experimental
-}
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
  newTraceAndSpanId,
  isEmptySpanId,
  spanIdBytes,
  bytesToSpanId,
  Base (..),
  baseEncodedToSpanId,
  spanIdBaseEncodedBuilder,
  spanIdBaseEncodedByteString,
  spanIdBaseEncodedText,

  -- * Nil (all-zero) IDs
  nilTraceId,
  nilSpanId,

  -- * Traceparent codec (C FFI)
  decodeTraceparent,
  encodeTraceparent,
) where

import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.Bits (shiftR, (.&.), (.|.))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.ByteString.Builder (Builder)
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Internal as BI
import Data.ByteString.Short (ShortByteString, fromShort)
import qualified Data.ByteString.Unsafe as BU
import Data.Hashable (Hashable (..))
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import Data.Word (Word64, Word8)
import Foreign.C.Types (CInt (..), CSize (..))
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Ptr (Ptr, castPtr, plusPtr)
import Foreign.Storable (peek, peekElemOff, poke)
import GHC.Exts (IsString (fromString))
import GHC.Generics (Generic)
import OpenTelemetry.Trace.Id.Generator (IdGenerator (..))
import System.IO.Unsafe (unsafeDupablePerformIO)
import Prelude hiding (length)


-- ---------------------------------------------------------------------------
-- C FFI
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "hs_otel_encode_trace_id"
  c_encodeTraceId :: Ptr Word8 -> Ptr Word8 -> IO ()


foreign import ccall unsafe "hs_otel_encode_span_id"
  c_encodeSpanId :: Ptr Word8 -> Ptr Word8 -> IO ()


foreign import ccall unsafe "hs_otel_decode_hex"
  c_decodeHex :: Ptr Word8 -> Ptr Word8 -> CSize -> IO CInt


foreign import ccall unsafe "hs_otel_xoshiro_next"
  c_xoshiroNext :: IO Word64


-- ---------------------------------------------------------------------------
-- TraceId
-- ---------------------------------------------------------------------------

{- | A valid trace identifier is a 16-byte array with at least one non-zero byte.

Stored as two machine-word @Word64@ values in native byte order.
When @UNPACK@ed into a containing record (e.g. 'SpanContext'), both
words are stored inline. No separate heap object, no pointer chase.

 @since 0.0.1.0
-}
data TraceId
  = TraceId
      {-# UNPACK #-} !Word64
      {-# UNPACK #-} !Word64
  deriving stock (Eq, Ord, Generic)


instance Hashable TraceId where
  hashWithSalt s (TraceId hi lo) = s `hashWithSalt` hi `hashWithSalt` lo
  {-# INLINE hashWithSalt #-}


instance Show TraceId where
  showsPrec d i = showParen (d > 10) $ showString "TraceId " . showsPrec 11 (traceIdBaseEncodedText Base16 i)


instance IsString TraceId where
  fromString str = case baseEncodedToTraceId Base16 (fromString str) of
    Left err -> error err
    Right ok -> ok


{- | All-zero 'TraceId'.

@since 0.0.1.0
-}
nilTraceId :: TraceId
nilTraceId = TraceId 0 0
{-# INLINE nilTraceId #-}


{- | Generate a 'TraceId' using the provided 'IdGenerator'.

 @since 0.1.0.0
-}
newTraceId :: (MonadIO m) => IdGenerator -> m TraceId
newTraceId DefaultIdGenerator = liftIO generateTraceId
newTraceId (CustomIdGenerator _ genTrace) = liftIO $ sbsToTraceId <$> genTrace
{-# INLINE newTraceId #-}


-- | @since 0.1.0.0
isEmptyTraceId :: TraceId -> Bool
isEmptyTraceId (TraceId hi lo) = (hi .|. lo) == 0
{-# INLINE isEmptyTraceId #-}


-- | @since 0.1.0.0
traceIdBytes :: TraceId -> ByteString
traceIdBytes (TraceId hi lo) =
  BI.unsafeCreate 16 $ \ptr -> do
    poke (castPtr ptr) hi
    poke (castPtr (ptr `plusPtr` 8)) lo


{- | Convert a 'ByteString' to a 'TraceId'. Will fail if the 'ByteString'
 is not exactly 16 bytes long.

 @since 0.1.0.0
-}
bytesToTraceId :: ByteString -> Either String TraceId
bytesToTraceId bs
  | BS.length bs /= 16 = Left "bytesToTraceId: TraceId must be 16 bytes long"
  | otherwise = unsafeDupablePerformIO $
      BU.unsafeUseAsCString bs $ \src -> do
        let !p = castPtr src :: Ptr Word64
        !hi <- peekElemOff p 0
        !lo <- peekElemOff p 1
        pure $! Right $! TraceId hi lo


{- | Convert a hex-encoded 'ByteString' into a 'TraceId'.

 @since 0.1.0.0
-}
baseEncodedToTraceId :: Base -> ByteString -> Either String TraceId
baseEncodedToTraceId Base16 bs
  | BS.length bs /= 32 = Left "baseEncodedToTraceId: expected 32 hex chars"
  | otherwise = unsafeDupablePerformIO $
      BU.unsafeUseAsCStringLen bs $ \(src, _) ->
        allocaBytes 16 $ \dst -> do
          rc <- c_decodeHex (castPtr src) dst 16
          if rc == 0
            then do
              let !p = castPtr dst :: Ptr Word64
              !hi <- peekElemOff p 0
              !lo <- peekElemOff p 1
              pure $! Right $! TraceId hi lo
            else pure $ Left "invalid hex character"


-- | @since 0.1.0.0
traceIdBaseEncodedBuilder :: Base -> TraceId -> Builder
traceIdBaseEncodedBuilder Base16 = B.byteString . traceIdBaseEncodedByteString Base16


{- | SIMD-accelerated hex encoding (SSSE3 on x86_64, NEON on aarch64).

 @since 0.1.0.0
-}
traceIdBaseEncodedByteString :: Base -> TraceId -> ByteString
traceIdBaseEncodedByteString Base16 (TraceId hi lo) =
  BI.unsafeCreate 32 $ \dst ->
    allocaBytes 16 $ \src -> do
      poke (castPtr src :: Ptr Word64) hi
      poke (castPtr (src `plusPtr` 8) :: Ptr Word64) lo
      c_encodeTraceId src dst


-- | @since 0.1.0.0
traceIdBaseEncodedText :: Base -> TraceId -> Text
traceIdBaseEncodedText b = decodeUtf8 . traceIdBaseEncodedByteString b


-- ---------------------------------------------------------------------------
-- SpanId
-- ---------------------------------------------------------------------------

{- | A valid span identifier is an 8-byte array with at least one non-zero byte.

Stored as a single machine-word @Word64@ in native byte order.

 @since 0.0.1.0
-}
data SpanId
  = SpanId
      {-# UNPACK #-} !Word64
  deriving stock (Eq, Ord, Generic)


instance Hashable SpanId where
  hashWithSalt s (SpanId w) = hashWithSalt s w
  {-# INLINE hashWithSalt #-}


instance Show SpanId where
  showsPrec d i = showParen (d > 10) $ showString "SpanId " . showsPrec 11 (spanIdBaseEncodedText Base16 i)


instance IsString SpanId where
  fromString str = case baseEncodedToSpanId Base16 (fromString str) of
    Left err -> error err
    Right ok -> ok


{- | All-zero 'SpanId'.

@since 0.0.1.0
-}
nilSpanId :: SpanId
nilSpanId = SpanId 0
{-# INLINE nilSpanId #-}


{- | Generate a 'SpanId' using the provided 'IdGenerator'.

 @since 0.1.0.0
-}
newSpanId :: (MonadIO m) => IdGenerator -> m SpanId
newSpanId DefaultIdGenerator = liftIO generateSpanId
newSpanId (CustomIdGenerator genSpan _) = liftIO $ sbsToSpanId <$> genSpan
{-# INLINE newSpanId #-}


{- | Generate both a TraceId and SpanId. For 'DefaultIdGenerator', this is a
single FFI call (3 xoshiro steps) instead of 3 separate calls. Used for
root spans where both IDs need generating.
-}
newTraceAndSpanId :: (MonadIO m) => IdGenerator -> m (TraceId, SpanId)
newTraceAndSpanId DefaultIdGenerator = liftIO generateTraceAndSpanId
newTraceAndSpanId gen = liftIO $ do
  !tid <- newTraceId gen
  !sid <- newSpanId gen
  pure (tid, sid)
{-# INLINE newTraceAndSpanId #-}


-- | @since 0.1.0.0
isEmptySpanId :: SpanId -> Bool
isEmptySpanId (SpanId w) = w == 0
{-# INLINE isEmptySpanId #-}


-- | @since 0.1.0.0
spanIdBytes :: SpanId -> ByteString
spanIdBytes (SpanId w) =
  BI.unsafeCreate 8 $ \ptr -> poke (castPtr ptr) w


-- | @since 0.1.0.0
bytesToSpanId :: ByteString -> Either String SpanId
bytesToSpanId bs
  | BS.length bs /= 8 = Left "bytesToSpanId: SpanId must be 8 bytes long"
  | otherwise = unsafeDupablePerformIO $
      BU.unsafeUseAsCString bs $ \src -> do
        !w <- peek (castPtr src :: Ptr Word64)
        pure $! Right $! SpanId w


-- | @since 0.1.0.0
baseEncodedToSpanId :: Base -> ByteString -> Either String SpanId
baseEncodedToSpanId Base16 bs
  | BS.length bs /= 16 = Left "baseEncodedToSpanId: expected 16 hex chars"
  | otherwise = unsafeDupablePerformIO $
      BU.unsafeUseAsCStringLen bs $ \(src, _) ->
        allocaBytes 8 $ \dst -> do
          rc <- c_decodeHex (castPtr src) dst 8
          if rc == 0
            then do
              !w <- peek (castPtr dst :: Ptr Word64)
              pure $! Right $! SpanId w
            else pure $ Left "invalid hex character"


-- | @since 0.1.0.0
spanIdBaseEncodedBuilder :: Base -> SpanId -> Builder
spanIdBaseEncodedBuilder Base16 = B.byteString . spanIdBaseEncodedByteString Base16


-- | @since 0.1.0.0
spanIdBaseEncodedByteString :: Base -> SpanId -> ByteString
spanIdBaseEncodedByteString Base16 (SpanId w) =
  BI.unsafeCreate 16 $ \dst ->
    allocaBytes 8 $ \src -> do
      poke (castPtr src :: Ptr Word64) w
      c_encodeSpanId src dst


-- | @since 0.1.0.0
spanIdBaseEncodedText :: Base -> SpanId -> Text
spanIdBaseEncodedText b = decodeUtf8 . spanIdBaseEncodedByteString b


-- ---------------------------------------------------------------------------
-- Generation: xoshiro256++ (DefaultIdGenerator)
-- ---------------------------------------------------------------------------

{- | Generate a 'TraceId' via thread-local xoshiro256++.
Two FFI calls returning Word64 directly. No buffer, no ByteArray#.
-}
generateTraceId :: IO TraceId
generateTraceId = do
  !hi <- c_xoshiroNext
  !lo <- c_xoshiroNext
  pure $! TraceId hi lo
{-# INLINE generateTraceId #-}


-- | Generate a 'SpanId' via thread-local xoshiro256++.
generateSpanId :: IO SpanId
generateSpanId = do
  !w <- c_xoshiroNext
  pure $! SpanId w
{-# INLINE generateSpanId #-}


{- | Generate a TraceId + SpanId for root spans.

Three sequential @unsafe@ FFI calls to xoshiro256++ (~9 ns total).
A Cmm primop returning an unboxed triple via Sp-allocated out-pointers
was benchmarked at the same cost (~9.7 ns) because the per-call FFI
overhead (~3 ns) is already lower than the Cmm stack manipulation.
-}
generateTraceAndSpanId :: IO (TraceId, SpanId)
generateTraceAndSpanId = do
  !hi <- c_xoshiroNext
  !lo <- c_xoshiroNext
  !sid <- c_xoshiroNext
  pure (TraceId hi lo, SpanId sid)
{-# INLINE generateTraceAndSpanId #-}


-- ---------------------------------------------------------------------------
-- CustomIdGenerator SBS -> Word64 conversion
-- ---------------------------------------------------------------------------

sbsToTraceId :: ShortByteString -> TraceId
sbsToTraceId sbs =
  let !bs = fromShort sbs
  in case bytesToTraceId bs of
       Right tid -> tid
       Left _ -> nilTraceId


sbsToSpanId :: ShortByteString -> SpanId
sbsToSpanId sbs =
  let !bs = fromShort sbs
  in case bytesToSpanId bs of
       Right sid -> sid
       Left _ -> nilSpanId


{- | Base encoding scheme. Only 'Base16' (hexadecimal) is supported.

@since 0.0.1.0
-}
data Base = Base16
  deriving (Show, Eq)


-- ---------------------------------------------------------------------------
-- Traceparent codec (C FFI)
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "hs_otel_parse_traceparent"
  c_parseTraceparent :: Ptr Word8 -> CSize -> Ptr Word64 -> IO CInt


foreign import ccall unsafe "hs_otel_encode_traceparent"
  c_encodeTraceparent
    :: Word64
    -> Word64
    -> Word64
    -> Word8
    -> Word8
    -> Ptr Word8
    -> IO ()


{- | Parse a W3C traceparent header in a single SIMD-accelerated C call.

 Returns the version, trace ID, span ID, and flags byte, or 'Nothing'
 on any format error (bad hex, wrong length, missing dashes, all-zero IDs).

 @since 0.4.0.0
-}
decodeTraceparent :: ByteString -> Maybe (Word8, TraceId, SpanId, Word8)
decodeTraceparent bs = unsafeDupablePerformIO $
  BU.unsafeUseAsCStringLen bs $ \(src, len) ->
    allocaBytes 32 $ \buf -> do
      let !p = castPtr buf :: Ptr Word64
      rc <- c_parseTraceparent (castPtr src) (fromIntegral len) p
      if rc == 0
        then do
          !hi <- peekElemOff p 0
          !lo <- peekElemOff p 1
          !sid <- peekElemOff p 2
          !meta <- peekElemOff p 3
          let !ver = fromIntegral (meta `shiftR` 8) :: Word8
              !fl = fromIntegral (meta .&. 0xFF) :: Word8
          pure $! Just (ver, TraceId hi lo, SpanId sid, fl)
        else pure Nothing


{- | Encode a traceparent header (55 bytes) in a single SIMD-accelerated C call.

 @since 0.4.0.0
-}
encodeTraceparent :: Word8 -> TraceId -> SpanId -> Word8 -> ByteString
encodeTraceparent ver (TraceId hi lo) (SpanId sid) fl =
  BI.unsafeCreate 55 $ \dst ->
    c_encodeTraceparent hi lo sid ver fl dst
