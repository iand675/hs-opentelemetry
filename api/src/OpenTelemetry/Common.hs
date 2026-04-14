{-# LANGUAGE NumericUnderscores #-}

module OpenTelemetry.Common (
  Timestamp (..),
  TraceFlags (..),
  OptionalTimestamp (NoTimestamp, SomeTimestamp),
  isEnded,
  optionalTimestampToMaybe,
  optionalTimestampFromMaybe,
  timestampToOptional,
  mkTimestamp,
  timestampToNanoseconds,
) where

import Data.Word (Word64, Word8)


{- | Wall-clock timestamp stored as nanoseconds since Unix epoch.
Matches the OTLP wire format directly (fixed64 nanoseconds).

@since 0.0.1.0
-}
newtype Timestamp = Timestamp Word64
  deriving (Read, Show, Eq, Ord)


{- | Contain details about the trace. Unlike TraceState values, TraceFlags are present in all traces. The current version of the specification only supports a single flag called sampled.

@since 0.0.1.0
-}
newtype TraceFlags = TraceFlags Word8
  deriving (Show, Eq, Ord)


{- | Unboxed optional timestamp. @SomeTimestamp@ stores a single unboxed
@Word64#@ directly in its closure: 2 words total vs 4 for
@Just (Timestamp ns)@.

@since 0.0.1.0
-}
data OptionalTimestamp
  = NoTimestamp
  | SomeTimestamp {-# UNPACK #-} !Word64
  deriving (Eq, Ord)


instance Show OptionalTimestamp where
  showsPrec _ NoTimestamp = showString "NoTimestamp"
  showsPrec d (SomeTimestamp ns) =
    showParen (d > 10) $
      showString "SomeTimestamp " . showsPrec 11 ns


-- | @since 0.0.1.0
isEnded :: OptionalTimestamp -> Bool
isEnded NoTimestamp = False
isEnded _ = True
{-# INLINE isEnded #-}


-- | @since 0.0.1.0
optionalTimestampToMaybe :: OptionalTimestamp -> Maybe Timestamp
optionalTimestampToMaybe NoTimestamp = Nothing
optionalTimestampToMaybe (SomeTimestamp ns) = Just (Timestamp ns)
{-# INLINE optionalTimestampToMaybe #-}


-- | @since 0.0.1.0
optionalTimestampFromMaybe :: Maybe Timestamp -> OptionalTimestamp
optionalTimestampFromMaybe Nothing = NoTimestamp
optionalTimestampFromMaybe (Just (Timestamp ns)) = SomeTimestamp ns
{-# INLINE optionalTimestampFromMaybe #-}


-- | @since 0.0.1.0
timestampToOptional :: Timestamp -> OptionalTimestamp
timestampToOptional (Timestamp ns) = SomeTimestamp ns
{-# INLINE timestampToOptional #-}


{- | Construct a 'Timestamp' from seconds and nanoseconds components.
Useful for tests and interop with @TimeSpec@-based APIs.

@since 0.0.1.0
-}
mkTimestamp :: Word64 -> Word64 -> Timestamp
mkTimestamp sec nsec = Timestamp (sec * 1_000_000_000 + nsec)
{-# INLINE mkTimestamp #-}


{- | Extract nanoseconds since epoch. Identity on the internal representation.

@since 0.0.1.0
-}
timestampToNanoseconds :: Timestamp -> Word64
timestampToNanoseconds (Timestamp ns) = ns
{-# INLINE timestampToNanoseconds #-}
