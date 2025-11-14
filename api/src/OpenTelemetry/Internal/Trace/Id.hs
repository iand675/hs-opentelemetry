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
) where

import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.ByteArray.Encoding (
  Base (Base16),
  convertFromBase,
  convertToBase,
 )
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.ByteString.Builder (Builder)
import qualified Data.ByteString.Builder as B
import Data.ByteString.Short.Internal (
  ShortByteString (SBS),
  fromShort,
  toShort,
 )
import Data.Hashable (Hashable)
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import GHC.Exts (
  IsString (fromString),
  eqWord#,
  indexWord64Array#,
  int2Word#,
  isTrue#,
  or#,
 )


#if MIN_VERSION_base(4,17,0)
import GHC.Exts (word64ToWord#)
#endif

import GHC.Generics (Generic)
import OpenTelemetry.Trace.Id.Generator (
  IdGenerator (generateSpanIdBytes, generateTraceIdBytes),
 )
import Prelude hiding (length)


-- TODO faster encoding decoding via something like
-- https://github.com/lemire/Code-used-on-Daniel-Lemire-s-blog/blob/03fc2e82fdef2c6fd25721203e1654428fee123d/2019/04/17/hexparse.cpp#L390

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
newTraceId gen = liftIO (TraceId . toShort <$> generateTraceIdBytes gen)


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
baseEncodedToTraceId b bs = do
  r <- convertFromBase b bs
  bytesToTraceId r


{- | Output a 'TraceId' into a base-encoded bytestring 'Builder'.

 @since 0.1.0.0
-}
traceIdBaseEncodedBuilder :: Base -> TraceId -> Builder
traceIdBaseEncodedBuilder b = B.byteString . convertToBase b . traceIdBytes


{- | Output a 'TraceId' into a base-encoded 'ByteString'.

 @since 0.1.0.0
-}
traceIdBaseEncodedByteString :: Base -> TraceId -> ByteString
traceIdBaseEncodedByteString b = convertToBase b . traceIdBytes


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
newSpanId gen = liftIO (SpanId . toShort <$> generateSpanIdBytes gen)


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
baseEncodedToSpanId b bs = do
  r <- convertFromBase b bs
  bytesToSpanId r


{- | Output a 'SpanId' into a base-encoded bytestring 'Builder'.

 @since 0.1.0.0
-}
spanIdBaseEncodedBuilder :: Base -> SpanId -> Builder
spanIdBaseEncodedBuilder b = B.byteString . convertToBase b . spanIdBytes


{- | Output a 'SpanId' into a base-encoded 'ByteString'.

 @since 0.1.0.0
-}
spanIdBaseEncodedByteString :: Base -> SpanId -> ByteString
spanIdBaseEncodedByteString b = convertToBase b . spanIdBytes


{- | Output a 'SpanId' into a base-encoded 'Text'.

 @since 0.1.0.0
-}
spanIdBaseEncodedText :: Base -> SpanId -> Text
spanIdBaseEncodedText b = decodeUtf8 . spanIdBaseEncodedByteString b
