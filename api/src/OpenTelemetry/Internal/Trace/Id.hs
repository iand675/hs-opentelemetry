{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
-- | Trace and Span Id generation
--
-- No Aeson instances are provided since they've got the potential to be
-- transport-specific in format. Use newtypes for serialisation instead.

module OpenTelemetry.Internal.Trace.Id where
import OpenTelemetry.Trace.IdGenerator
import Control.Monad.IO.Class
import Data.ByteArray.Encoding
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.ByteString.Builder (Builder)
import qualified Data.ByteString.Builder as B
import Data.Hashable (Hashable)
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)

import Data.ByteString.Short.Internal
import GHC.Exts
import GHC.ST
import Prelude hiding (length)

-- TODO faster encoding decoding via something like
-- https://github.com/lemire/Code-used-on-Daniel-Lemire-s-blog/blob/03fc2e82fdef2c6fd25721203e1654428fee123d/2019/04/17/hexparse.cpp#L390

-- 16 bytes
newtype TraceId = TraceId ShortByteString
  deriving stock (Ord, Eq)
  deriving newtype (Hashable)

-- 8 bytes
newtype SpanId = SpanId ShortByteString
  deriving stock (Ord, Eq)
  deriving newtype (Hashable)

instance Show TraceId where
  show = show . traceIdBaseEncodedText Base16

instance IsString TraceId where
  fromString str = case baseEncodedToTraceId Base16 (fromString str) of
    Left err -> error err
    Right ok -> ok

instance Show SpanId where
  show = show . spanIdBaseEncodedText Base16

instance IsString SpanId where
  fromString str = case baseEncodedToSpanId Base16 (fromString str) of
    Left err -> error err
    Right ok -> ok


-- | bytes pointed to by src to the hexadecimal binary representation.
toHexadecimal :: ShortByteString -- ^ source bytes
              -> ShortByteString -- ^ hexadecimal output
toHexadecimal (SBS bin) = runST $ ST $ \s ->
  case newByteArray# (n *# 2# ) s of 
    (# s1, mba #) -> case loop 0# mba s1 of
      s2 -> case unsafeFreezeByteArray# mba s2 of
        (# s3, ba #) -> (# s3, SBS ba #)
  where 
    !n = sizeofByteArray# bin
    loop i bout s
      | isTrue# (i ==# n) = s
      | otherwise = do
          let !w = indexWord8Array# bin i
          let !(# w1, w2 #) = convertByte w
          case writeWord8Array# bout (i *# 2#) w1 s of
            s1 -> case writeWord8Array# bout ((i *# 2#) +# 1#) w2 s1 of
              s2 -> loop (i +# 1#) bout s2

-- | Convert a value Word# to two Word#s containing
-- the hexadecimal representation of the Word#
convertByte :: Word# -> (# Word#, Word# #)
convertByte b = (# r tableHi b, r tableLo b #)
  where
        r :: Addr# -> Word# -> Word#
        r table ix = indexWord8OffAddr# table (word2Int# ix)

        !tableLo =
            "0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef\
            \0123456789abcdef0123456789abcdef"#
        !tableHi =
            "00000000000000001111111111111111\
            \22222222222222223333333333333333\
            \44444444444444445555555555555555\
            \66666666666666667777777777777777\
            \88888888888888889999999999999999\
            \aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbb\
            \ccccccccccccccccdddddddddddddddd\
            \eeeeeeeeeeeeeeeeffffffffffffffff"#
{-# INLINE convertByte #-}

-- | Convert a base16 @src to the byte equivalent.
--
-- length of the 'ShortByteString' input must be even
--
-- TODO, not working right
fromHexadecimal :: ShortByteString -> (Maybe ShortByteString)
fromHexadecimal src@(SBS sbs)
  | odd (length src) = Nothing
  | otherwise = runST $ ST $ \s -> case newByteArray# newLen# s of 
      (# s1, dst #) -> case loop dst 0# 0# s1 of
        (# s2, Just _ #) -> (# s2, Nothing #)
        (# s2, Nothing #) -> case unsafeFreezeByteArray# dst s2 of
          (# s3, sbs' #) -> (# s3, Just $ SBS sbs' #)
  where 
    !(I# newLen#) = length src `div` 2
    loop dst di i s
      | isTrue# (i ==# newLen#) = (# s, Nothing #)
      | otherwise = do
        let a = rHi (indexWord8Array# sbs i)
        let b = rLo (indexWord8Array# sbs (i +# 1#))
        if isTrue# (eqWord# a (int2Word# 0xff#)) || isTrue# (eqWord# b (int2Word# 0xff#))
            then (# s, Just (I# i) #) 
            else 
              case writeWord8Array# dst di (or# a b) s of 
                s1 -> loop dst (di +# 1#) (i +# 2#) s1

    rLo ix = indexWord8OffAddr# tableLo (word2Int# ix)
    rHi ix = indexWord8OffAddr# tableHi (word2Int# ix)

    !tableLo =
            "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\xff\xff\xff\xff\xff\xff\
              \\xff\x0a\x0b\x0c\x0d\x0e\x0f\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\x0a\x0b\x0c\x0d\x0e\x0f\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"#
    !tableHi =
            "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\x00\x10\x20\x30\x40\x50\x60\x70\x80\x90\xff\xff\xff\xff\xff\xff\
              \\xff\xa0\xb0\xc0\xd0\xe0\xf0\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xa0\xb0\xc0\xd0\xe0\xf0\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\
              \\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"#

newTraceId :: MonadIO m => IdGenerator -> m TraceId
newTraceId gen = liftIO ((TraceId . toShort) <$> generateTraceIdBytes gen)

isEmptyTraceId :: TraceId -> Bool
isEmptyTraceId (TraceId (SBS arr)) = 
  isTrue# 
    (eqWord# 
      (or# 
        (indexWord64Array# arr 0#)
        (indexWord64Array# arr 1#))
      (int2Word# 0#))

traceIdBytes :: TraceId -> ByteString
traceIdBytes (TraceId bytes) = fromShort bytes

bytesToTraceId :: ByteString -> Either String TraceId
bytesToTraceId bs = if BS.length bs == 16
  then Right $ TraceId $ toShort bs
  else Left "bytesToTraceId: TraceId must be 8 bytes long"

baseEncodedToTraceId :: Base -> ByteString -> Either String TraceId
baseEncodedToTraceId b bs = do
  r <- convertFromBase b bs
  bytesToTraceId r

traceIdBaseEncodedBuilder :: Base -> TraceId -> Builder
traceIdBaseEncodedBuilder b = B.byteString . convertToBase b . traceIdBytes

traceIdBaseEncodedByteString :: Base -> TraceId -> ByteString
traceIdBaseEncodedByteString b = convertToBase b . traceIdBytes

traceIdBaseEncodedText :: Base -> TraceId -> Text
traceIdBaseEncodedText b = decodeUtf8 . traceIdBaseEncodedByteString b

newSpanId :: MonadIO m => IdGenerator -> m SpanId
newSpanId gen = liftIO ((SpanId . toShort) <$> generateSpanIdBytes gen)

isEmptySpanId :: SpanId -> Bool
isEmptySpanId (SpanId (SBS arr)) = isTrue#
  (eqWord#
    (indexWord64Array# arr 0#)
    (int2Word# 0#))

spanIdBytes :: SpanId -> ByteString
spanIdBytes (SpanId bytes) = fromShort bytes

bytesToSpanId :: ByteString -> Either String SpanId
bytesToSpanId bs = if BS.length bs == 8
  then Right $ SpanId $ toShort bs
  else Left "bytesToSpanId: SpanId must be 8 bytes long"

baseEncodedToSpanId :: Base -> ByteString -> Either String SpanId
baseEncodedToSpanId b bs = do
  r <- convertFromBase b bs
  bytesToSpanId r

spanIdBaseEncodedBuilder :: Base -> SpanId -> Builder
spanIdBaseEncodedBuilder b = B.byteString . convertToBase b . spanIdBytes

spanIdBaseEncodedByteString :: Base -> SpanId -> ByteString
spanIdBaseEncodedByteString b = convertToBase b . spanIdBytes

spanIdBaseEncodedText :: Base -> SpanId -> Text
spanIdBaseEncodedText b = decodeUtf8 . spanIdBaseEncodedByteString b
