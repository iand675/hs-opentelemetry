{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
-- See https://google.github.io/sqlcommenter/spec/
-- for the specification of the SQL Commenter protocol.
module SqlCommenter
  ( sqlCommenter
  , parseFirstSqlComment
  -- * OpenTelemetry integration
  , lookupSqlCommenterAttributes
  , getSqlCommenterAttributes
  , addTraceDataToAttributes
  , getSqlCommenterAttributesWithTraceData
  -- * Testing support
  , urlEncode
  ) where

import Control.Applicative
import Data.Attoparsec.Text
import Data.Bits
import qualified Data.ByteString as BS
import Data.Char
import Data.Foldable
import Data.Function ((&))
import Data.Text (Text)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as M
import Data.Maybe
import Data.Monoid
import Data.Word
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.IO as TIO
import Prelude hiding (take, takeWhile)
import Data.Text.Encoding (StrictBuilder)
import qualified Data.Text.Internal.StrictBuilder as B
import Network.HTTP.Types (urlDecode)
import qualified OpenTelemetry.Context as Ctxt
import qualified OpenTelemetry.Context.ThreadLocal as TL
import OpenTelemetry.Propagator.W3CTraceContext (encodeSpanContext)
import OpenTelemetry.Trace.Core as Core
import System.IO.Unsafe

sqlCommenterKey :: Ctxt.Key (Map Text Text)
sqlCommenterKey = unsafePerformIO $ Ctxt.newKey "sqlcommenter-attributes"
{-# NOINLINE sqlCommenterKey #-}

lookupSqlCommenterAttributes :: Ctxt.Context -> Map Text Text
lookupSqlCommenterAttributes ctxt = case Ctxt.lookup sqlCommenterKey ctxt of
  Nothing -> mempty
  Just attrs -> attrs

getSqlCommenterAttributes :: IO (Map Text Text)
getSqlCommenterAttributes = lookupSqlCommenterAttributes <$> TL.getContext

addTraceDataToAttributes :: Core.Span -> Map Text Text -> IO (Map Text Text)
addTraceDataToAttributes span attrs = do
  (traceparent, tracestate) <- encodeSpanContext span
  pure $ attrs
    & M.insert "traceparent" (unsafeConvert traceparent)
    & M.insert "tracestate" (unsafeConvert tracestate)
  where
    unsafeConvert = B.toText . B.unsafeFromByteString

getSqlCommenterAttributesWithTraceData :: IO (Map Text Text)
getSqlCommenterAttributesWithTraceData = do
  ctxt <- TL.getContext
  let attrs = lookupSqlCommenterAttributes ctxt
  case Ctxt.lookupSpan ctxt of
    Nothing -> pure attrs
    Just span -> addTraceDataToAttributes span attrs

-- Represents a set of Word8 values using four Word64 values for 256 bits.
data Word8Set = Word8Set !Word64 !Word64 !Word64 !Word64 deriving (Eq, Show)

-- | Unsafe conversion between 'Char' and 'Word8'. This is a no-op and
-- silently truncates to 8 bits Chars > '\255'.
c2w :: Char -> Word8
c2w = fromIntegral . ord
{-# INLINE c2w #-}

-- Creates an empty Word8Set.
empty :: Word8Set
empty = Word8Set 0 0 0 0

-- Helper function to determine which Word64 to use and the bit position.
selectWord64 :: Word8 -> (Word8, Word8)
selectWord64 val = val `divMod` 64

-- Adds a Word8 value to the set.
insert :: Word8 -> Word8Set -> Word8Set
insert val (Word8Set w0 w1 w2 w3) = case selectWord64 val of
    (0, pos) -> Word8Set (setBit w0 $ fromIntegral pos) w1 w2 w3
    (1, pos) -> Word8Set w0 (setBit w1 $ fromIntegral pos) w2 w3
    (2, pos) -> Word8Set w0 w1 (setBit w2 $ fromIntegral pos) w3
    (3, pos) -> Word8Set w0 w1 w2 (setBit w3 $ fromIntegral pos)
    _        -> error "Word8 value out of bounds"

-- Removes a Word8 value from the set.
delete :: Word8 -> Word8Set -> Word8Set
delete val (Word8Set w0 w1 w2 w3) = case selectWord64 val of
    (0, pos) -> Word8Set (clearBit w0 $ fromIntegral pos) w1 w2 w3
    (1, pos) -> Word8Set w0 (clearBit w1 $ fromIntegral pos) w2 w3
    (2, pos) -> Word8Set w0 w1 (clearBit w2 $ fromIntegral pos) w3
    (3, pos) -> Word8Set w0 w1 w2 (clearBit w3 $ fromIntegral pos)
    _        -> error "Word8 value out of bounds"

-- Checks if a Word8 value is in the set.
member :: Word8 -> Word8Set -> Bool
member val (Word8Set w0 w1 w2 w3) = case selectWord64 val of
    (0, pos) -> testBit w0 $ fromIntegral pos
    (1, pos) -> testBit w1 $ fromIntegral pos
    (2, pos) -> testBit w2 $ fromIntegral pos
    (3, pos) -> testBit w3 $ fromIntegral pos
    _        -> error "Word8 value out of bounds"

-- SQL Commenter spec wants them escaped with a slash, but this should
-- probably solve the same issue
unreservedQS :: Word8Set
unreservedQS = foldr insert SqlCommenter.empty $ map c2w "-_.~'"

intersperse :: Foldable f => a -> f a -> [a]
intersperse sep a = case toList a of
  [] -> []
  (x:xs) -> x : prependToAll sep xs where
    prependToAll sep = \case
      [] -> []
      (x:xs) -> sep : x : prependToAll sep xs
{-# INLINE intersperse #-}

intercalate :: (Monoid a, Foldable f) => a -> f a -> a
intercalate delim l = mconcat (intersperse delim l)
{-# INLINE intercalate #-}

-- | Percent-encoding for URLs.
--
-- This will substitute every byte with its percent-encoded equivalent unless:
--
-- * The byte is alphanumeric. (i.e. one of @/[A-Za-z0-9]/@)
--
-- * The byte is one of the 'Word8' listed in the first argument.
urlEncodeBuilder' :: Word8Set -> Text -> StrictBuilder
urlEncodeBuilder' extraUnreserved =
  BS.foldl' (\acc c -> acc <> encodeChar c) mempty . T.encodeUtf8
  where
    encodeChar ch
        | unreserved ch = B.unsafeFromWord8 ch
        | otherwise = h2 ch

    unreserved ch
        | ch >= 65 && ch <= 90 = True -- A-Z
        | ch >= 97 && ch <= 122 = True -- a-z
        | ch >= 48 && ch <= 57 = True -- 0-9
    unreserved c = c `member` extraUnreserved

    -- must be upper-case
    h2 v = B.unsafeFromWord8 37 `mappend` B.unsafeFromWord8 (h a) `mappend` B.unsafeFromWord8 (h b) -- 37 = %
      where
        (a, b) = v `divMod` 16
    h i
        | i < 10 = 48 + i -- zero (0)
        | otherwise = 65 + i - 10 -- 65: A

urlEncodeBuilder :: Text -> StrictBuilder
urlEncodeBuilder = urlEncodeBuilder' unreservedQS

-- Parser for single-line comments
singleLineComment :: Parser Text
singleLineComment = "--" *> takeTill isEndOfLine <* (endOfLine <|> endOfInput)

-- Parser for multi-line comments
multiLineComment :: Parser Text
multiLineComment = do
  "/*"
  commentInner mempty
  where
    commentInner :: B.StrictBuilder -> Parser Text
    commentInner !builder = do
      txt <- takeWhile (/= '*')
      c <- char '*'
      mSlash <- peekChar
      case mSlash of
        Just '/' -> char '/' *> pure (B.toText (builder <> B.fromText txt))
        _ -> commentInner (builder <> B.fromText txt <> B.fromChar c)


-- Parser for SQL strings (ignores content inside strings)
sqlString :: Parser Text
sqlString = char '\'' *> takeTill (== '\'') <* char '\''

-- Parser for quoted identifiers (table or column names)
quotedIdentifier :: Parser Text
quotedIdentifier = (char '"' *> takeTill (== '"') <* char '"')
               <|> (char '`' *> takeTill (== '`') <* char '`')

-- Parser that ignores SQL strings and quoted identifiers
ignoreNonComments :: Parser (Maybe a)
ignoreNonComments = Nothing <$ (sqlString <|> quotedIdentifier <|> take 1)

-- Combined parser for comments, ignoring strings and identifiers
sqlComment :: Parser (Maybe Text)
sqlComment = Just <$> (singleLineComment <|> multiLineComment)

-- Function to check for comments, ignoring strings and identifiers
hasSqlComment :: Text -> Bool
hasSqlComment input =
  case parseOnly (many' (sqlComment <|> ignoreNonComments)) input of
    Left _ -> False
    Right parts -> any isJust parts

urlEncode :: Text -> Text
urlEncode = B.toText . urlEncodeBuilder

sqlCommenter :: Text -> Map Text Text -> Text
sqlCommenter query attributes = if B.sbLength concatenatedAttributes == 0 || hasSqlComment query
  then query
  else B.toText
    ( B.fromText query <>
      B.fromText " /* " <>
      concatenatedAttributes <>
      B.fromText " */"
    )
  where
    concatenatedAttributes = intercalate (B.fromChar ',') $ M.foldrWithKey
      (\key value acc -> urlEncodeBuilder key <> B.fromText "='" <> B.fromText (T.replace "'" "\\'" (B.toText $ urlEncodeBuilder value)) <> B.fromChar '\'': acc)
      []
      attributes

parseAttribute :: Parser (Text, Text)
parseAttribute = do
  key <- takeWhile1 (/= '=')
  _ <- string "='"
  val <- valueInner mempty
  pure (T.decodeUtf8 $ urlDecode True $ T.encodeUtf8 key, T.decodeUtf8 $ urlDecode True $ T.encodeUtf8 val)
  where
    valueInner !builder = do
      txt <- takeWhile (\c -> c /= '\\' && c /= '\'')
      mNext <- peekChar
      case mNext of
        Just '\\' -> do
          _ <- string "\\'"
          valueInner (builder <> B.fromText txt <> B.fromChar '\'')
        Just '\'' -> do
          _ <- char '\''
          pure $ B.toText (builder <> B.fromText txt)
        _ -> fail "Unterminated quoted attribute value"

parseSqlCommentAsAttributes :: Parser (Maybe (Map Text Text))
parseSqlCommentAsAttributes = do
  c <- sqlComment
  let innerParser = do
        skipSpace
        attrPairs <- parseAttribute `sepBy` char ','
        skipSpace
        endOfInput
        pure $ M.fromList $ attrPairs
  case c of
    Nothing -> pure Nothing
    Just txt -> pure $ Just $ case parseOnly innerParser txt of
      Left _ -> mempty
      Right vals -> vals

parseFirstSqlComment :: Text -> Map Text Text
parseFirstSqlComment input = case parseOnly (many' (parseSqlCommentAsAttributes <|> ignoreNonComments)) input of
  Left _ -> M.empty
  Right parts -> case catMaybes parts of
    [] -> M.empty
    (comment:_) -> comment
