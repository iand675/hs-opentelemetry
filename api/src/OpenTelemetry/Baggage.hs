{-# LANGUAGE CPP #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      :  OpenTelemetry.Baggage
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Propagated key-value metadata for cross-service context
Stability   :  experimental

= Overview

Baggage is a set of key-value pairs that propagate alongside trace context
across service boundaries (typically via the @baggage@ HTTP header). Use it
to pass metadata like tenant IDs, feature flags, or routing hints through
your distributed system.

Baggage is /not/ for span-specific annotations. Use 'OpenTelemetry.Trace.addAttribute'
for that.

= Quick example

@
import OpenTelemetry.Baggage

-- Create baggage:
let bag = insert [token|tenant-id|] (element "abc123")
        $ insert [token|region|] (element "us-east-1")
        $ empty

-- Encode for HTTP propagation:
let headerValue = encodeBaggageHeader bag
-- "tenant-id=abc123,region=us-east-1"

-- Decode from an incoming header:
case decodeBaggageHeader headerBytes of
  Right bag -> -- use the baggage
  Left err  -> -- malformed header
@

= Thread-local baggage

Use the functions in "OpenTelemetry.Context.ThreadLocal" to get\/set baggage
on the current thread:

@
import OpenTelemetry.Context.ThreadLocal (getContext, adjustContext)
import OpenTelemetry.Context (insertBaggage, lookupBaggage)

-- Read:
mbag <- lookupBaggage \<$\> getContext
-- Write:
adjustContext (insertBaggage myBaggage)
@

= Limits

W3C Baggage specification enforces:

* Max 8192 bytes total serialized size
* Max 4096 bytes per member
* Max 180 members

'insertChecked' validates these limits and returns 'Left' 'InvalidBaggage'
on violation.

= Spec reference

<https://opentelemetry.io/docs/specs/otel/baggage/api/>
-}
module OpenTelemetry.Baggage (
  -- * Constructing 'Baggage' structures
  Baggage,
  empty,
  fromHashMap,
  values,
  Token,
  token,
  mkToken,
  tokenValue,
  Element (..),
  element,
  property,
  InvalidBaggage (..),

  -- * Limits (W3C Baggage specification)
  maxBaggageBytes,
  maxMemberBytes,
  maxMembers,

  -- * Modifying 'Baggage'
  insert,
  insertChecked,
  delete,

  -- * Querying 'Baggage'
  getValue,

  -- * Encoding and decoding 'Baggage'
  encodeBaggageHeader,
  encodeBaggageHeaderB,
  decodeBaggageHeader,
) where

import Control.Monad (when)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Builder.Extra as BS
import Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as B8
import qualified Data.ByteString.Internal as BS
import qualified Data.ByteString.Lazy as L
import Data.ByteString.Unsafe (unsafePackAddressLen)
import qualified Data.HashMap.Strict as H
import Data.Hashable
import Data.Text (Text)
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8', encodeUtf8)
import Data.Word (Word8)
import Language.Haskell.TH.Lib
import Language.Haskell.TH.Quote
import Language.Haskell.TH.Syntax
import System.IO.Unsafe


{- | A key for a baggage entry, restricted to the set of valid characters
 specified in the @token@ definition of RFC 2616:

 https://www.rfc-editor.org/rfc/rfc2616#section-2.2

 @since 0.0.1.0
-}
newtype Token = Token ByteString
  deriving stock (Show, Eq, Ord)
  deriving newtype (Hashable)


{- | Convert a 'Token' into a 'ByteString'

@since 0.0.1.0
-}
tokenValue :: Token -> ByteString
tokenValue (Token t) = t

#if MIN_VERSION_template_haskell(2, 17, 0)
instance Lift Token where
  liftTyped (Token tok) = liftCode $ unsafeTExpCoerce $ bsToExp tok
#else
instance Lift Token where
  liftTyped (Token tok) = unsafeTExpCoerce $ bsToExp tok
#endif


{- | An entry into the baggage

@since 0.0.1.0
-}
data Element = Element
  { value :: Text
  , properties :: [Property]
  }
  deriving stock (Show, Eq)


-- | @since 0.0.1.0
element :: Text -> Element
element t = Element t []


data Property = Property
  { propertyKey :: Token
  , propertyValue :: Maybe Text
  }
  deriving stock (Show, Eq)


-- | @since 0.0.1.0
property :: Token -> Maybe Text -> Property
property = Property


{- | Baggage is used to annotate telemetry, adding context and information to metrics, traces, and logs.
 It is a set of name/value pairs describing user-defined properties.
 Each name in Baggage is associated with exactly one value.

 @since 0.0.1.0
-}
newtype Baggage = Baggage (H.HashMap Token Element)
  deriving stock (Show, Eq)
  deriving newtype (Semigroup)


-- | RFC 2616 token character predicate (no allocation, branchless via table)
isTokenChar :: Char -> Bool
isTokenChar c = w < 128 && tokenTable `BS.index` fromIntegral w /= 0
  where
    w = fromEnum c
{-# INLINE isTokenChar #-}


-- 128-byte lookup: 1 = valid token char, 0 = invalid
tokenTable :: ByteString
tokenTable =
  BS.pack
    [ 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0 -- 0x00-0x0f
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0 -- 0x10-0x1f
    , 0
    , 1
    , 0
    , 1
    , 1
    , 1
    , 1
    , 1
    , 0
    , 0
    , 1
    , 1
    , 0
    , 1
    , 1
    , 0 --  ! # $ % & ' * + - .
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0 -- 0-9
    , 0
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1 -- A-O
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 0
    , 0
    , 0
    , 1
    , 1 -- P-Z ^ _
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1 -- ` a-o
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 1
    , 0
    , 1
    , 0
    , 1
    , 0 -- p-z | ~
    ]
{-# NOINLINE tokenTable #-}


-- Ripped from file-embed-0.0.13
bsToExp :: (Monad m) => ByteString -> m Exp
#if MIN_VERSION_template_haskell(2, 5, 0)
bsToExp bs =
    return $ ConE 'Token
      `AppE` (VarE 'unsafePerformIO
      `AppE` (VarE 'unsafePackAddressLen
      `AppE` LitE (IntegerL $ fromIntegral $ BS.length bs)
#if MIN_VERSION_template_haskell(2, 16, 0)
      `AppE` LitE (bytesPrimL (
                let BS.PS ptr off sz = bs
                in  mkBytes ptr (fromIntegral off) (fromIntegral sz)))))
#elif MIN_VERSION_template_haskell(2, 8, 0)
      `AppE` LitE (StringPrimL $ B.unpack bs)))
#else
      `AppE` LitE (StringPrimL $ B8.unpack bs)))
#endif
#else
bsToExp bs = do
    helper <- [| stringToBs |]
    let chars = B8.unpack bs
    return $! AppE helper $! LitE $! StringL chars
#endif


-- | @since 0.0.1.0
mkToken :: Text -> Maybe Token
mkToken txt
  | T.null txt = Nothing
  | txt `T.compareLength` 4096 == GT = Nothing
  | T.all isTokenChar txt = Just $ Token $ encodeUtf8 txt
  | otherwise = Nothing


-- | @since 0.0.1.0
token :: QuasiQuoter
token =
  QuasiQuoter
    { quoteExp = parseExp
    , quotePat = \_ -> fail "Token as pattern not implemented"
    , quoteType = \_ -> fail "Can't use a Baggage Token as a type"
    , quoteDec = \_ -> fail "Can't use a Baggage Token as a declaration"
    }
  where
    parseExp = \str -> case mkToken $ T.pack str of
      Nothing -> fail (show str ++ " is not a valid Token.")
      Just tok -> lift tok


-- | @since 0.0.1.0
data InvalidBaggage
  = BaggageTooLong
  | MemberTooLong
  | TooManyListMembers
  | Empty
  deriving stock (Show, Eq)


-- | @since 0.0.1.0
encodeBaggageHeader :: Baggage -> ByteString
encodeBaggageHeader =
  L.toStrict
    . BS.toLazyByteStringWith (BS.untrimmedStrategy (8192 + 16) BS.smallChunkSize) L.empty
    . encodeBaggageHeaderB


-- | @since 0.0.1.0
encodeBaggageHeaderB :: Baggage -> B.Builder
encodeBaggageHeaderB (Baggage bmap) =
  go 0 True (take maxMembers $ H.toList bmap)
  where
    go :: Int -> Bool -> [(Token, Element)] -> B.Builder
    go _ _ [] = mempty
    go totalSoFar isFirst ((tok, el) : rest) =
      let memberBs = builderToStrict (encodeMemberB tok el)
          memberLen = BS.length memberBs
          sep = if isFirst then 0 else 1
          newTotal = totalSoFar + sep + memberLen
      in if memberLen > maxMemberBytes
          then go totalSoFar isFirst rest
          else
            if newTotal > maxBaggageBytes
              then mempty
              else
                (if isFirst then mempty else B.char7 ',')
                  <> B.byteString memberBs
                  <> go newTotal False rest


encodeMemberB :: Token -> Element -> B.Builder
encodeMemberB (Token k) (Element v props) =
  B.byteString k
    <> B.char7 '='
    <> percentEncodeBuilder (encodeUtf8 v)
    <> mconcat (map (\p -> B.char7 ';' <> propEncoderB p) props)


propEncoderB :: Property -> B.Builder
propEncoderB (Property (Token k) mv) =
  B.byteString k
    <> maybe
      mempty
      (\v -> B.char7 '=' <> percentEncodeBuilder (encodeUtf8 v))
      mv


builderToStrict :: B.Builder -> ByteString
builderToStrict = L.toStrict . B.toLazyByteString


{- | W3C Baggage: max 8192 bytes total, max 180 members, max 4096 bytes per member

@since 0.0.1.0
-}
maxBaggageBytes, maxMemberBytes, maxMembers :: Int
maxBaggageBytes = 8192
maxMemberBytes = 4096
maxMembers = 180


-- | @since 0.0.1.0
decodeBaggageHeader :: ByteString -> Either String Baggage
decodeBaggageHeader bs
  | BS.length bs > maxBaggageBytes = Left "Baggage header exceeds 8192 byte limit"
  | otherwise = parseBaggageHeader bs


parseBaggageHeader :: ByteString -> Either String Baggage
parseBaggageHeader input = do
  let stripped = stripOWS input
  when (BS.null stripped) $ Left "Empty baggage header"
  let rawMembers = splitOnByte 0x2C stripped -- ','
  when (length rawMembers > maxMembers) $
    Left ("Baggage has more than " ++ show maxMembers ++ " members")
  members <- mapM parseMember rawMembers
  pure $ Baggage $ H.fromList members


parseMember :: ByteString -> Either String (Token, Element)
parseMember raw = do
  let s = stripOWS raw
  let (keyBs, rest0) = B8.span isTokenChar s
  when (BS.null keyBs) $ Left "Expected token in baggage member"
  let rest1 = stripOWS rest0
  rest2 <- expectByte 0x3D rest1 -- '='
  let rest3 = stripOWS rest2
      (valBs, rest4) = BS.span isValueByte rest3
  val <- case decodeUtf8' (percentDecode valBs) of
    Right t -> Right t
    Left _ -> Left "Invalid UTF-8 in baggage value"
  props <- parseProperties rest4
  pure (Token keyBs, Element val props)


parseProperties :: ByteString -> Either String [Property]
parseProperties bs = go (stripOWS bs)
  where
    go s
      | BS.null s = Right []
      | BS.head s == 0x3B = do
          -- ';'
          let s1 = stripOWS (BS.tail s)
              (keyBs, rest0) = B8.span isTokenChar s1
          when (BS.null keyBs) $ Left "Expected token in baggage property"
          let rest1 = stripOWS rest0
          if not (BS.null rest1) && BS.head rest1 == 0x3D -- '='
            then do
              let rest2 = stripOWS (BS.tail rest1)
                  (valBs, rest3) = BS.span isValueByte rest2
              rest <- go (stripOWS rest3)
              propVal <- case decodeUtf8' (percentDecode valBs) of
                Right t -> Right t
                Left _ -> Left "Invalid UTF-8 in baggage property value"
              pure $ Property (Token keyBs) (Just propVal) : rest
            else do
              rest <- go rest1
              pure $ Property (Token keyBs) Nothing : rest
      | otherwise = Left $ "Unexpected byte in baggage: " ++ show (BS.head s)


isValueByte :: Word8 -> Bool
isValueByte w =
  w == 0x21
    || (w >= 0x23 && w <= 0x2B)
    || (w >= 0x2D && w <= 0x3A)
    || (w >= 0x3C && w <= 0x5B)
    || (w >= 0x5D && w <= 0x7E)
{-# INLINE isValueByte #-}


stripOWS :: ByteString -> ByteString
stripOWS = B8.dropWhile (\c -> c == ' ' || c == '\t') . B8.dropWhileEnd (\c -> c == ' ' || c == '\t')
{-# INLINE stripOWS #-}


expectByte :: Word8 -> ByteString -> Either String ByteString
expectByte expected bs
  | BS.null bs = Left $ "Expected " ++ show expected ++ " but got end of input"
  | BS.head bs == expected = Right (BS.tail bs)
  | otherwise = Left $ "Expected " ++ show expected ++ " but got " ++ show (BS.head bs)
{-# INLINE expectByte #-}


splitOnByte :: Word8 -> ByteString -> [ByteString]
splitOnByte w bs
  | BS.null bs = []
  | otherwise =
      let (before, rest) = BS.break (== w) bs
      in before : if BS.null rest then [] else splitOnByte w (BS.tail rest)


{- | An empty initial baggage value

@since 0.0.1.0
-}
empty :: Baggage
empty = Baggage H.empty


-- | @since 0.0.1.0
insert
  :: Token
  -- ^ The name for which to set the value
  -> Element
  -- ^ The value to set. Use 'element' to construct a well-formed element value.
  -> Baggage
  -> Baggage
insert k v (Baggage c) = Baggage (H.insert k v c)


{- | Insert a key\/value pair into the baggage with W3C limit enforcement.

Returns 'Left' 'InvalidBaggage' if adding the entry would violate:

* 'TooManyListMembers': exceeds 180 entries (W3C ABNF max)
* 'BaggageTooLong': serialized header would exceed 8192 bytes

@since 0.4.0.0
-}
insertChecked
  :: Token
  -> Element
  -> Baggage
  -> Either InvalidBaggage Baggage
insertChecked k v (Baggage c) =
  let c' = H.insert k v c
      newCount = H.size c'
      newBag = Baggage c'
  in if newCount > maxMembers
      then Left TooManyListMembers
      else
        let totalBytes = baggageSerializedSize c'
        in if totalBytes > maxBaggageBytes
            then Left BaggageTooLong
            else Right newBag


baggageSerializedSize :: H.HashMap Token Element -> Int
baggageSerializedSize m =
  let entries = H.toList m
      memberSizes = map (\(tok, el) -> memberByteLen tok el) entries
      separators = max 0 (length entries - 1)
  in sum memberSizes + separators
  where
    memberByteLen (Token k) (Element v props) =
      BS.length k
        + 1
        + BS.length (percentEncode (encodeUtf8 v))
        + sum (map propLen props)
    propLen (Property (Token pk) Nothing) = 1 + BS.length pk
    propLen (Property (Token pk) (Just pv)) = 1 + BS.length pk + 1 + BS.length (percentEncode (encodeUtf8 pv))


{- | Delete a key/value pair from the baggage.

@since 0.0.1.0
-}
delete :: Token -> Baggage -> Baggage
delete k (Baggage c) = Baggage (H.delete k c)


{- | Look up a baggage value by name.

Per the spec, this takes a name and returns the associated value, or
'Nothing' if the name is not present in the baggage.

@since 0.4.0.0
-}
getValue :: Token -> Baggage -> Maybe Text
getValue k (Baggage m) = case H.lookup k m of
  Just (Element v _) -> Just v
  Nothing -> Nothing


{- | Returns the name/value pairs in the `Baggage`. The order of name/value pairs
 is not significant.

 @since 0.0.1.0
-}
values :: Baggage -> H.HashMap Token Element
values (Baggage m) = m


{- | Convert a 'H.HashMap' into 'Baggage'

@since 0.0.1.0
-}
fromHashMap :: H.HashMap Token Element -> Baggage
fromHashMap = Baggage


-- Percent-encoding (RFC 3986 unreserved characters)
-- Spaces are always encoded as %20 (not +).

isUnreserved :: Word8 -> Bool
isUnreserved w =
  (w >= 65 && w <= 90) -- A-Z
    || (w >= 97 && w <= 122) -- a-z
    || (w >= 48 && w <= 57) -- 0-9
    || w == 45 -- -
    || w == 46 -- .
    || w == 95 -- _
    || w == 126 -- ~
{-# INLINE isUnreserved #-}


percentEncode :: ByteString -> ByteString
percentEncode = L.toStrict . B.toLazyByteString . percentEncodeBuilder
{-# INLINE percentEncode #-}


percentEncodeBuilder :: ByteString -> B.Builder
percentEncodeBuilder = BS.foldl' (\acc w -> acc <> encodeWord8 w) mempty
  where
    encodeWord8 w
      | isUnreserved w = B.word8 w
      | otherwise = B.char7 '%' <> hexWord8 w
    hexWord8 w =
      let (hi, lo) = w `divMod` 16
      in B.word8 (hexDigit hi) <> B.word8 (hexDigit lo)
    hexDigit n
      | n < 10 = n + 48 -- '0'
      | otherwise = n + 55 -- 'A' - 10


percentDecode :: ByteString -> ByteString
percentDecode bs = L.toStrict $ B.toLazyByteString $ go 0
  where
    len = BS.length bs
    go i
      | i >= len = mempty
      | BS.index bs i == 0x25
      , i + 2 < len -- '%'
      , Just hi <- unhex (BS.index bs (i + 1))
      , Just lo <- unhex (BS.index bs (i + 2)) =
          B.word8 (hi * 16 + lo) <> go (i + 3)
      | otherwise =
          B.word8 (BS.index bs i) <> go (i + 1)
    unhex w
      | w >= 48 && w <= 57 = Just (w - 48) -- 0-9
      | w >= 65 && w <= 70 = Just (w - 55) -- A-F
      | w >= 97 && w <= 102 = Just (w - 87) -- a-f
      | otherwise = Nothing
