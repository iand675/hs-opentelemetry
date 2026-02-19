{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Baggage
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Serializable annotations to add user-defined values to telemetry
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Baggage is used to annotate telemetry, adding context and information to metrics, traces, and logs.
 It is a set of name/value pairs describing user-defined properties.

 Note: if you are trying to add data annotations specific to a single trace span, you should use
 'OpenTelemetry.Trace.addAttribute' and 'OpenTelemetry.Trace.addAttributes'
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

  -- * Modifying 'Baggage'
  insert,
  delete,

  -- * Encoding and decoding 'Baggage'
  encodeBaggageHeader,
  encodeBaggageHeaderB,
  decodeBaggageHeader,
) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Builder.Extra as BS
import Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Internal as BS
import qualified Data.ByteString.Lazy as L
import Data.ByteString.Unsafe (unsafePackAddressLen)
import qualified Data.HashMap.Strict as H
import Data.Hashable
import Data.List (intersperse)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8, encodeUtf8)
import Data.Word (Word8)
import Language.Haskell.TH.Lib
import Language.Haskell.TH.Quote
import Language.Haskell.TH.Syntax
import System.IO.Unsafe


{- | A key for a baggage entry, restricted to the set of valid characters
 specified in the @token@ definition of RFC 2616:

 https://www.rfc-editor.org/rfc/rfc2616#section-2.2
-}
newtype Token = Token ByteString
  deriving stock (Show, Eq, Ord)
  deriving newtype (Hashable)


-- | Convert a 'Token' into a 'ByteString'
tokenValue :: Token -> ByteString
tokenValue (Token t) = t

#if MIN_VERSION_template_haskell(2, 17, 0)
instance Lift Token where
  liftTyped (Token tok) = liftCode $ unsafeTExpCoerce $ bsToExp tok
#else
instance Lift Token where
  liftTyped (Token tok) = unsafeTExpCoerce $ bsToExp tok
#endif


-- | An entry into the baggage
data Element = Element
  { value :: Text
  , properties :: [Property]
  }
  deriving stock (Show, Eq)


element :: Text -> Element
element t = Element t []


data Property = Property
  { propertyKey :: Token
  , propertyValue :: Maybe Text
  }
  deriving stock (Show, Eq)


property :: Token -> Maybe Text -> Property
property = Property


{- | Baggage is used to annotate telemetry, adding context and information to metrics, traces, and logs.
 It is a set of name/value pairs describing user-defined properties.
 Each name in Baggage is associated with exactly one value.
-}
newtype Baggage = Baggage (H.HashMap Token Element)
  deriving stock (Show, Eq)
  deriving newtype (Semigroup)


isTokenChar :: Char -> Bool
isTokenChar c = c `BS8.elem` tokenCharsBS


{-# NOINLINE tokenCharsBS #-}
tokenCharsBS :: ByteString
tokenCharsBS = "!#$%&'*+-.^_`|~0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"


isTokenCharW8 :: Word8 -> Bool
isTokenCharW8 w = BS.elemIndex w tokenCharsBS /= Nothing


-- RFC 2616 baggage-octet character set
isValueChar :: Word8 -> Bool
isValueChar w =
  w == 0x21
    || (w >= 0x23 && w <= 0x2B)
    || (w >= 0x2D && w <= 0x3A)
    || (w >= 0x3C && w <= 0x5B)
    || (w >= 0x5D && w <= 0x7E)


isOWS :: Word8 -> Bool
isOWS w = w == 0x20 || w == 0x09


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


mkToken :: Text -> Maybe Token
mkToken txt
  | txt `T.compareLength` 4096 == GT = Nothing
  | T.all isTokenChar txt = Just $ Token $ encodeUtf8 txt
  | otherwise = Nothing


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


data InvalidBaggage
  = BaggageTooLong
  | MemberTooLong
  | TooManyListMembers
  | Empty


-- TODO: The fact that this can be a max of 8192 bytes
-- should allow this to optimized pretty heavily
encodeBaggageHeader :: Baggage -> ByteString
encodeBaggageHeader =
  L.toStrict
    . BS.toLazyByteStringWith (BS.untrimmedStrategy (8192 + 16) BS.smallChunkSize) L.empty
    . encodeBaggageHeaderB


encodeBaggageHeaderB :: Baggage -> B.Builder
encodeBaggageHeaderB (Baggage bmap) =
  mconcat $
    intersperse (B.char7 ',') $
      map go $
        H.toList bmap
  where
    go (Token k, Element v props) =
      B.byteString k
        <> B.char7 '='
        <> percentEncode (encodeUtf8 v)
        <> (mconcat $ intersperse (B.char7 ';') $ map propEncoder props)
    propEncoder (Property (Token k) mv) =
      B.byteString k
        <> maybe
          mempty
          (\v -> B.char7 '=' <> percentEncode (encodeUtf8 v))
          mv


decodeBaggageHeader :: ByteString -> Either String Baggage
decodeBaggageHeader input = case runParser parseBaggage input of
  Just (result, remaining)
    | BS.null remaining -> Right result
    | otherwise -> Left $ "Unexpected trailing content in baggage header"
  Nothing -> Left "Failed to parse baggage header"


-- Simple non-backtracking parser
newtype Parser a = Parser {runParser :: ByteString -> Maybe (a, ByteString)}


instance Functor Parser where
  fmap f (Parser p) = Parser $ \s -> case p s of
    Just (a, s') -> Just (f a, s')
    Nothing -> Nothing


instance Applicative Parser where
  pure a = Parser $ \s -> Just (a, s)
  Parser pf <*> Parser pa = Parser $ \s -> do
    (f, s') <- pf s
    (a, s'') <- pa s'
    Just (f a, s'')


instance Monad Parser where
  Parser pa >>= f = Parser $ \s -> do
    (a, s') <- pa s
    runParser (f a) s'


pChar8 :: Char -> Parser ()
pChar8 c = Parser $ \s ->
  case BS8.uncons s of
    Just (h, t) | h == c -> Just ((), t)
    _ -> Nothing


pTakeWhile :: (Word8 -> Bool) -> Parser ByteString
pTakeWhile predicate = Parser $ \s ->
  let (taken, rest) = BS.span predicate s
  in Just (taken, rest)


pTakeWhile1 :: (Word8 -> Bool) -> Parser ByteString
pTakeWhile1 predicate = Parser $ \s ->
  let (taken, rest) = BS.span predicate s
  in if BS.null taken
      then Nothing
      else Just (taken, rest)


pMany :: Parser a -> Parser [a]
pMany p = Parser $ \s -> Just (go s [])
  where
    go s acc = case runParser p s of
      Just (a, s') -> go s' (a : acc)
      Nothing -> (reverse acc, s)


pOption :: a -> Parser a -> Parser a
pOption def p = Parser $ \s -> case runParser p s of
  Just result -> Just result
  Nothing -> Just (def, s)


skipOWS :: Parser ()
skipOWS = pTakeWhile isOWS >> pure ()


parseToken :: Parser Token
parseToken = Token <$> pTakeWhile1 isTokenCharW8


parseValue :: Parser ByteString
parseValue = pTakeWhile isValueChar


parseProperty :: Parser Property
parseProperty = do
  key <- parseToken
  skipOWS
  val <- pOption Nothing $ do
    pChar8 '='
    skipOWS
    Just . decodeUtf8 . percentDecode <$> parseValue
  pure $ Property key val


parseMember :: Parser (Token, Element)
parseMember = do
  tok <- parseToken
  skipOWS
  pChar8 '='
  skipOWS
  val <- decodeUtf8 . percentDecode <$> parseValue
  props <- pMany $ do
    skipOWS
    pChar8 ';'
    skipOWS
    parseProperty
  pure (tok, Element val props)


parseBaggage :: Parser Baggage
parseBaggage = do
  skipOWS
  firstMember <- parseMember
  otherMembers <- pMany $ do
    skipOWS
    pChar8 ','
    skipOWS
    parseMember
  skipOWS
  pure $ Baggage $ H.fromList (firstMember : otherMembers)


-- Percent-encoding (RFC 3986 style, used for baggage values)
-- When formEncoding is False: encode everything except unreserved characters
percentEncode :: ByteString -> B.Builder
percentEncode = BS.foldl' step mempty
  where
    step acc w
      | isUnreserved w = acc <> B.word8 w
      | otherwise = acc <> B.char7 '%' <> hexByte w
    hexByte w =
      let hi = w `div` 16
          lo = w `mod` 16
      in B.word8 (toHexDigit hi) <> B.word8 (toHexDigit lo)
    toHexDigit x
      | x < 10 = x + 0x30
      | otherwise = x + 0x37
    isUnreserved w =
      (w >= 0x41 && w <= 0x5A) -- A-Z
        || (w >= 0x61 && w <= 0x7A) -- a-z
        || (w >= 0x30 && w <= 0x39) -- 0-9
        || w == 0x2D -- -
        || w == 0x2E -- .
        || w == 0x5F -- _
        || w == 0x7E -- ~


percentDecode :: ByteString -> ByteString
percentDecode bs = BS.pack $ go 0
  where
    len = BS.length bs
    go !i
      | i >= len = []
      | BS.index bs i == 0x25 -- '%'
      , i + 2 < len
      , Just hi <- fromHexDigitW8 (BS.index bs (i + 1))
      , Just lo <- fromHexDigitW8 (BS.index bs (i + 2)) =
          (hi * 16 + lo) : go (i + 3)
      | BS.index bs i == 0x2B = 0x20 : go (i + 1) -- '+' -> space
      | otherwise = BS.index bs i : go (i + 1)
    fromHexDigitW8 w
      | w >= 0x30 && w <= 0x39 = Just (w - 0x30)
      | w >= 0x41 && w <= 0x46 = Just (w - 0x37)
      | w >= 0x61 && w <= 0x66 = Just (w - 0x57)
      | otherwise = Nothing


-- | An empty initial baggage value
empty :: Baggage
empty = Baggage H.empty


insert
  :: Token
  -- ^ The name for which to set the value
  -> Element
  -- ^ The value to set. Use 'element' to construct a well-formed element value.
  -> Baggage
  -> Baggage
insert k v (Baggage c) = Baggage (H.insert k v c)


-- | Delete a key/value pair from the baggage.
delete :: Token -> Baggage -> Baggage
delete k (Baggage c) = Baggage (H.delete k c)


{- | Returns the name/value pairs in the `Baggage`. The order of name/value pairs
 is not significant.

 @since 0.0.1.0
-}
values :: Baggage -> H.HashMap Token Element
values (Baggage m) = m


-- | Convert a 'H.HashMap' into 'Baggage'
fromHashMap :: H.HashMap Token Element -> Baggage
fromHashMap = Baggage
