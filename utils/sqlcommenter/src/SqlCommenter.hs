{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : SqlCommenter
Description : Attach metadata to SQL queries for observability
Stability   : experimental
Portability : POSIX

This module implements the
<https://google.github.io/sqlcommenter/spec/ sqlcommenter spec>.

== Overview

The sqlcommenter algorithm adds structured comments to SQL queries in the format:

@
SELECT * FROM users /* key1='value1',key2='value2' */
@

The module provides functions to:
* Add sqlcommenter attributes to queries
* Parse sqlcommenter attributes from queries
* Integrate with OpenTelemetry tracing

== Key Concepts

sqlcommenter works by adding structured metadata to your SQL queries. This metadata comes in two forms:

1. __Custom Attributes__: Key-value pairs that you define, like @db_driver='postgresql'@.
   These help identify the context of your queries (e.g., which service made the request,
   what operation it was performing).

2. __Trace Context__: OpenTelemetry's distributed tracing information, which includes:
   * @traceparent@: A unique identifier for the trace, containing:
     - The trace ID (identifies the entire request flow)
     - The span ID (identifies this specific operation)
     - Trace flags (e.g., whether the trace is sampled)
   * @tracestate@: Additional tracing metadata that can be used to correlate
     traces across different systems

All attribute values are URL-encoded to ensure they can be safely included in SQL comments.
This encoding preserves the meaning of special characters while making them safe for SQL syntax.

== Attribute Propagation

Unlike some sqlcommenter implementations, this module does not automatically propagate
all parent span attributes to SQL queries. This is because:

* Query size can grow significantly with many attributes
* Not all attributes are relevant for database observability
* Some attributes may contain sensitive information

Instead, you must explicitly opt into which attributes you want to propagate by adding
them to the OpenTelemetry context using 'lookupSqlCommenterAttributes'. This gives you
fine-grained control over:

* Which attributes are included in queries
* The size of the generated comments
* What information is exposed to database tools

== Usage

The 'sqlCommenter' function provides the basic building block for adding comments to SQL queries.
It takes a query and a map of attributes, and returns the query with the attributes added as a comment.
This function is independent of OpenTelemetry: you can use it to add any attributes you want,
whether they're trace-related or not.

To add sqlcommenter attributes to a query:

>>> let query = "SELECT * FROM users"
>>> let attrs = M.fromList [("db_driver", "postgresql")]
>>> sqlCommenter query attrs
"SELECT * FROM users /* db_driver='postgresql' */"

To parse sqlcommenter attributes from a query:

>>> let query = "SELECT * FROM users /* db_driver='postgresql' */"
>>> parseFirstSqlComment query
fromList [("db_driver","postgresql")]

== OpenTelemetry Integration

The module integrates with OpenTelemetry by:
* Storing sqlcommenter attributes in the OpenTelemetry context
* Adding trace context to SQL queries
* Propagating distributed tracing information

== Example: Query Performance Analysis

sqlcommenter enables powerful query analysis workflows. Consider this scenario:

You're investigating a slow API endpoint. Your observability platform shows the request
took 2 seconds, but you need to understand why. The trace shows several database queries,
but which one is the culprit?

With sqlcommenter, each query carries its trace context. This means when a query is slow,
you can not only identify which query it was, but also get its actual execution plan and
performance metrics. Tools like auto_explain can capture:

* The exact query plan that was used
* How many rows were processed at each step
* Which indexes were used (or missed)
* Where time was spent in the query
* Whether the plan changed from what the planner expected

This detailed performance data is correlated with your application trace, so you can see:
* Which user action triggered the slow query
* What the database was doing at that exact moment
* How the query's performance impacted the user experience

By preserving trace context in queries, sqlcommenter helps bridge the gap between
application and database observability, making it easier to understand and optimize
your system's performance.
-}
module SqlCommenter (
  sqlCommenter,
  parseFirstSqlComment,

  -- * OpenTelemetry integration
  lookupSqlCommenterAttributes,
  getSqlCommenterAttributes,
  addTraceDataToAttributes,
  getSqlCommenterAttributesWithTraceData,

  -- * Testing support
  urlEncode,
) where

import Control.Applicative
import Data.Attoparsec.Text
import Data.Bits
import qualified Data.ByteString as BS
import Data.Char
import Data.Foldable
import Data.Function ((&))
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as M
import Data.Maybe
import Data.Monoid
import Data.Text (Text)
import qualified Data.Text as T
import Data.Text.Encoding (StrictBuilder)
import qualified Data.Text.Encoding as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Internal.StrictBuilder as B
import Data.Word
import Network.HTTP.Types (urlDecode)
import qualified OpenTelemetry.Context as Ctxt
import qualified OpenTelemetry.Context.ThreadLocal as TL
import OpenTelemetry.Propagator.W3CTraceContext (encodeSpanContext)
import OpenTelemetry.Trace.Core as Core
import System.IO.Unsafe
import Prelude hiding (take, takeWhile)


sqlCommenterKey :: Ctxt.Key (Map Text Text)
sqlCommenterKey = unsafePerformIO $ Ctxt.newKey "sqlcommenter-attributes"
{-# NOINLINE sqlCommenterKey #-}


{- | Looks up sqlcommenter attributes from an OpenTelemetry context.
Returns an empty map if no attributes are found.

>>> let ctxt = Ctxt.insert sqlCommenterKey (M.fromList [("db_driver", "postgresql")]) Ctxt.empty
>>> lookupSqlCommenterAttributes ctxt
fromList [("db_driver","postgresql")]
-}
lookupSqlCommenterAttributes :: Ctxt.Context -> Map Text Text
lookupSqlCommenterAttributes ctxt = case Ctxt.lookup sqlCommenterKey ctxt of
  Nothing -> mempty
  Just attrs -> attrs


{- | Retrieves sqlcommenter attributes from the current OpenTelemetry context.
Returns an empty map if no attributes are found.

>>> :{
do
  ctxt <- TL.getContext
  let attrs = M.fromList [("db_driver", "postgresql")]
  ctxt' <- TL.withContext (Ctxt.insert sqlCommenterKey attrs ctxt) $ do
    getSqlCommenterAttributes
:}
fromList [("db_driver","postgresql")]
-}
getSqlCommenterAttributes :: IO (Map Text Text)
getSqlCommenterAttributes = lookupSqlCommenterAttributes <$> TL.getContext


{- | Adds trace data (traceparent and tracestate) from a span to the existing sqlcommenter attributes.
This is used to propagate distributed tracing context in SQL queries.

>>> :{
do
  let span = Core.Span
        { spanTraceId = "4bf92f3577b34da6a3ce929d0e0e4736"
        , spanSpanId = "00f067aa0ba902b7"
        , spanTraceFlags = 1
        , spanTraceState = mempty
        }
      attrs = M.fromList [("db_driver", "postgresql")]
  attrs' <- addTraceDataToAttributes span attrs
:}
fromList [("db_driver","postgresql"),("traceparent","00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"),("tracestate","")]
-}
addTraceDataToAttributes :: Core.Span -> Map Text Text -> IO (Map Text Text)
addTraceDataToAttributes span attrs = do
  (traceparent, tracestate) <- encodeSpanContext span
  pure $
    attrs
      & M.insert "traceparent" (unsafeConvert traceparent)
      & M.insert "tracestate" (unsafeConvert tracestate)
  where
    unsafeConvert = B.toText . B.unsafeFromByteString


{- | Pure version of addTraceDataToAttributes that takes the encoded trace data directly.
This is useful for testing and when you already have the encoded trace data.
-}
addTraceDataToAttributesPure :: (Text, Text) -> Map Text Text -> Map Text Text
addTraceDataToAttributesPure (traceparent, tracestate) attrs =
  attrs
    & M.insert "traceparent" traceparent
    & M.insert "tracestate" tracestate


{- | Retrieves sqlcommenter attributes from the current context and adds trace data
if a span is available in the context. This combines the functionality of
'getSqlCommenterAttributes' and 'addTraceDataToAttributes'.

>>> :{
do
  let span = Core.Span
        { spanTraceId = "4bf92f3577b34da6a3ce929d0e0e4736"
        , spanSpanId = "00f067aa0ba902b7"
        , spanTraceFlags = 1
        , spanTraceState = mempty
        }
      attrs = M.fromList [("db_driver", "postgresql")]
  ctxt <- TL.getContext
  ctxt' <- TL.withContext (Ctxt.insert sqlCommenterKey attrs $ Ctxt.insertSpan span ctxt) $ do
    getSqlCommenterAttributesWithTraceData
:}
fromList [("db_driver","postgresql"),("traceparent","00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"),("tracestate","")]
-}
getSqlCommenterAttributesWithTraceData :: IO (Map Text Text)
getSqlCommenterAttributesWithTraceData = do
  ctxt <- TL.getContext
  let attrs = lookupSqlCommenterAttributes ctxt
  case Ctxt.lookupSpan ctxt of
    Nothing -> pure attrs
    Just span -> addTraceDataToAttributes span attrs


-- Represents a set of Word8 values using four Word64 values for 256 bits.
data Word8Set = Word8Set !Word64 !Word64 !Word64 !Word64 deriving (Eq, Show)


{- | Unsafe conversion between 'Char' and 'Word8'. This is a no-op and
silently truncates to 8 bits Chars > '\255'.
-}
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
  _ -> error "Word8 value out of bounds"


-- Removes a Word8 value from the set.
delete :: Word8 -> Word8Set -> Word8Set
delete val (Word8Set w0 w1 w2 w3) = case selectWord64 val of
  (0, pos) -> Word8Set (clearBit w0 $ fromIntegral pos) w1 w2 w3
  (1, pos) -> Word8Set w0 (clearBit w1 $ fromIntegral pos) w2 w3
  (2, pos) -> Word8Set w0 w1 (clearBit w2 $ fromIntegral pos) w3
  (3, pos) -> Word8Set w0 w1 w2 (clearBit w3 $ fromIntegral pos)
  _ -> error "Word8 value out of bounds"


-- Checks if a Word8 value is in the set.
member :: Word8 -> Word8Set -> Bool
member val (Word8Set w0 w1 w2 w3) = case selectWord64 val of
  (0, pos) -> testBit w0 $ fromIntegral pos
  (1, pos) -> testBit w1 $ fromIntegral pos
  (2, pos) -> testBit w2 $ fromIntegral pos
  (3, pos) -> testBit w3 $ fromIntegral pos
  _ -> error "Word8 value out of bounds"


-- sqlcommenter spec wants them escaped with a slash, but this should
-- probably solve the same issue
unreservedQS :: Word8Set
unreservedQS = foldr insert SqlCommenter.empty $ map c2w "-_.~'"


intersperse :: Foldable f => a -> f a -> [a]
intersperse sep a = case toList a of
  [] -> []
  (x : xs) -> x : prependToAll sep xs
    where
      prependToAll sep = \case
        [] -> []
        (x : xs) -> sep : x : prependToAll sep xs
{-# INLINE intersperse #-}


intercalate :: (Monoid a, Foldable f) => a -> f a -> a
intercalate delim l = mconcat (intersperse delim l)
{-# INLINE intercalate #-}


{- | Percent-encoding for URLs.

This will substitute every byte with its percent-encoded equivalent unless:

* The byte is alphanumeric. (i.e. one of @/[A-Za-z0-9]/@)

* The byte is one of the 'Word8' listed in the first argument.
-}
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
quotedIdentifier =
  (char '"' *> takeTill (== '"') <* char '"')
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


{- | Appends sqlcommenter attributes to a SQL query as a comment.
The attributes are URL-encoded and formatted according to the sqlcommenter specification.
If the query already contains a comment or if there are no attributes to add,
the original query is returned unchanged.

>>> sqlCommenter "SELECT * FROM users" (M.fromList [("db_driver", "postgresql")])
"SELECT * FROM users /* db_driver='postgresql' */"
-}
sqlCommenter :: Text -> Map Text Text -> Text
sqlCommenter query attributes =
  if B.sbLength concatenatedAttributes == 0 || hasSqlComment query
    then query
    else
      B.toText
        ( B.fromText query
            <> B.fromText " /* "
            <> concatenatedAttributes
            <> B.fromText " */"
        )
  where
    concatenatedAttributes =
      intercalate (B.fromChar ',') $
        M.foldrWithKey
          (\key value acc -> urlEncodeBuilder key <> B.fromText "='" <> B.fromText (T.replace "'" "\\'" (B.toText $ urlEncodeBuilder value)) <> B.fromChar '\'' : acc)
          []
          attributes


{- | Parses the first SQL comment in a query string and extracts the sqlcommenter attributes.
Returns an empty map if no valid sqlcommenter comment is found.

>>> parseFirstSqlComment "SELECT * FROM users /* db_driver='postgresql' */"
fromList [("db_driver","postgresql")]
-}
parseFirstSqlComment :: Text -> Map Text Text
parseFirstSqlComment input = case parseOnly (many' (parseSqlCommentAsAttributes <|> ignoreNonComments)) input of
  Left _ -> M.empty
  Right parts -> case catMaybes parts of
    [] -> M.empty
    (comment : _) -> comment


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
