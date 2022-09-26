{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Instrumentation.PostgresqlSimple (
  staticConnectionAttributes,
  {-
  -- * Queries that return results
    query
  , query_
  -- ** Queries taking parser as argument
  , queryWith
  , queryWith_
  -- * Queries that stream results
  , fold
  , foldWithOptions
  , fold_
  , foldWithOptions_
  , forEach
  , forEach_
  , returning
  -- ** Queries that stream results taking a parser as an argument
  , foldWith
  , foldWithOptionsAndParser
  , foldWith_
  , foldWithOptionsAndParser_
  , forEachWith
  , forEachWith_
  , returningWith
  -- * Statements that do not return results
  , execute
  , execute_
  , executeMany
  -- * Reexported functions
  , module X
  -}
) where

import Control.Monad.IO.Class
import qualified Data.ByteString.Char8 as C
import Data.IP
import Data.Int (Int64)
import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Database.PostgreSQL.LibPQ as LibPQ
import Database.PostgreSQL.Simple as X hiding (
  execute,
  executeMany,
  execute_,
  fold,
  foldWith,
  foldWithOptions,
  foldWithOptionsAndParser,
  foldWithOptionsAndParser_,
  foldWithOptions_,
  foldWith_,
  fold_,
  forEach,
  forEachWith,
  forEachWith_,
  forEach_,
  query,
  queryWith,
  queryWith_,
  query_,
  returning,
  returningWith,
 )
import qualified Database.PostgreSQL.Simple as Simple
import qualified Database.PostgreSQL.Simple.FromRow as Simple
import Database.PostgreSQL.Simple.Internal (
  Connection (Connection, connectionHandle),
 )
import GHC.Stack
import OpenTelemetry.Resource ((.=), (.=?))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Monad
import Text.Read (readMaybe)
import UnliftIO


-- | Get attributes that can be attached to a span denoting some database action
staticConnectionAttributes :: MonadIO m => Connection -> m [(T.Text, Attribute)]
staticConnectionAttributes Connection {connectionHandle} = liftIO $ do
  (mDb, mUser, mHost, mPort) <- withMVar connectionHandle $ \pqConn -> do
    (,,,)
      <$> LibPQ.db pqConn
      <*> LibPQ.user pqConn
      <*> LibPQ.host pqConn
      <*> LibPQ.port pqConn
  pure $
    ("db.system", toAttribute ("postgresql" :: T.Text))
      : catMaybes
        [ "db.user" .=? (TE.decodeUtf8 <$> mUser)
        , "db.name" .=? (TE.decodeUtf8 <$> mDb)
        , "net.peer.port"
            .=? ( do
                    port <- TE.decodeUtf8 <$> mPort
                    (readMaybe $ T.unpack port) :: Maybe Int
                )
        , case (readMaybe . C.unpack) =<< mHost of
            Nothing -> "net.peer.name" .=? (TE.decodeUtf8 <$> mHost)
            Just (IPv4 ipv4) -> "net.peer.ip" .= T.pack (show ipv4)
            Just (IPv6 ipv6) -> "net.peer.ip" .= T.pack (show ipv6)
        ]

{-
-- | Perform a @SELECT@ or other SQL query that is expected to return
-- results. All results are retrieved and converted before this
-- function returns.
--
-- When processing large results, this function will consume a lot of
-- client-side memory.  Consider using 'fold' instead.
--
-- Exceptions that may be thrown:
--
-- * 'FormatError': the query string could not be formatted correctly.
--
-- * 'QueryError': the result contains no columns (i.e. you should be
--   using 'execute' instead of 'query').
--
-- * 'ResultError': result conversion failed.
--
-- * 'SqlError':  the postgresql backend returned an error,  e.g.
--   a syntax or type error,  or an incorrect table or column name.
query :: (MonadIO m, MonadGetContext m, ToRow q, FromRow r) => Connection -> Query -> q -> m [r]
query = liftIO $ Simple.query

-- | A version of 'query' that does not perform query substitution.
query_ :: (MonadIO m, MonadGetContext m, FromRow r) => Connection -> Query -> m [r]
query_ = _

-- | A version of 'query' taking parser as argument
queryWith :: (MonadIO m, MonadGetContext m, ToRow q) => Simple.RowParser r -> Connection -> Query -> q -> m [r]
queryWith parser conn template qs = _

-- | A version of 'query_' taking parser as argument
queryWith_ :: (MonadIO m, MonadGetContext m) => Simple.RowParser r -> Connection -> Query -> m [r]
queryWith_ parser conn q = _

-- | Perform a @SELECT@ or other SQL query that is expected to return
-- results. Results are streamed incrementally from the server, and
-- consumed via a left fold.
--
-- When dealing with small results, it may be simpler (and perhaps
-- faster) to use 'query' instead.
--
-- This fold is /not/ strict. The stream consumer is responsible for
-- forcing the evaluation of its result to avoid space leaks.
--
-- This is implemented using a database cursor.    As such,  this requires
-- a transaction.   This function will detect whether or not there is a
-- transaction in progress,  and will create a 'ReadCommitted' 'ReadOnly'
-- transaction if needed.   The cursor is given a unique temporary name,
-- so the consumer may itself call fold.
--
-- Exceptions that may be thrown:
--
-- * 'FormatError': the query string could not be formatted correctly.
--
-- * 'QueryError': the result contains no columns (i.e. you should be
--   using 'execute' instead of 'query').
--
-- * 'ResultError': result conversion failed.
--
-- * 'SqlError':  the postgresql backend returned an error,  e.g.
--   a syntax or type error,  or an incorrect table or column name.
fold            :: (MonadBracketError m, MonadLocalContext m, FromRow row, ToRow params)
                => Connection
                -> Query
                -> params
                -> a
                -> (a -> row -> m a)
                -> m a
fold = _

-- | A version of 'fold' taking a parser as an argument
foldWith        :: (MonadBracketError m, MonadLocalContext m, ToRow params)
                => Simple.RowParser row
                -> Connection
                -> Query
                -> params
                -> a
                -> (a -> row -> m a)
                -> m a
foldWith = _
-- | The same as 'fold',  but this provides a bit more control over
--   lower-level details.  Currently,  the number of rows fetched per
--   round-trip to the server and the transaction mode may be adjusted
--   accordingly.    If the connection is already in a transaction,
--   then the existing transaction is used and thus the 'transactionMode'
--   option is ignored.
foldWithOptions :: (MonadBracketError m, MonadLocalContext m, FromRow row, ToRow params)
                => FoldOptions
                -> Connection
                -> Query
                -> params
                -> a
                -> (a -> row -> m a)
                -> m a
foldWithOptions opts = _

-- | A version of 'foldWithOptions' taking a parser as an argument
foldWithOptionsAndParser :: (MonadBracketError m, MonadLocalContext m, ToRow params)
                         => FoldOptions
                         -> Simple.RowParser row
                         -> Connection
                         -> Query
                         -> params
                         -> a
                         -> (a -> row -> m a)
                         -> m a
foldWithOptionsAndParser opts parser conn template qs a f = _

-- | A version of 'fold' that does not perform query substitution.
fold_ :: (MonadBracketError m, MonadLocalContext m, FromRow r) =>
         Connection
      -> Query                  -- ^ Query.
      -> a                      -- ^ Initial state for result consumer.
      -> (a -> r -> m a)       -- ^ Result consumer.
      -> m a
fold_ = _

-- | A version of 'fold_' taking a parser as an argument
foldWith_ :: (MonadUnliftIO m, MonadBracketError m, MonadLocalContext m) =>
             Simple.RowParser r
          -> Connection
          -> Query
          -> a
          -> (a -> r -> m a)
          -> m a
foldWith_ = _

foldWithOptions_ :: (MonadUnliftIO m, MonadBracketError m, MonadLocalContext m, FromRow r) =>
                    FoldOptions
                 -> Connection
                 -> Query             -- ^ Query.
                 -> a                 -- ^ Initial state for result consumer.
                 -> (a -> r -> m a)  -- ^ Result consumer.
                 -> m a
foldWithOptions_ opts conn query' a f = Simple.foldWithOptions_ opts conn query' a f

-- | A version of 'foldWithOptions_' taking a parser as an argument
foldWithOptionsAndParser_ :: FoldOptions
                          -> Simple.RowParser r
                          -> Connection
                          -> Query             -- ^ Query.
                          -> a                 -- ^ Initial state for result consumer.
                          -> (a -> r -> IO a)  -- ^ Result consumer.
                          -> IO a
foldWithOptionsAndParser_ opts parser conn query' a f = _

-- | A version of 'fold' that does not transform a state value.
forEach :: (MonadUnliftIO m, MonadBracketError m, MonadLocalContext m, ToRow q, FromRow r) =>
           Connection
        -> Query                -- ^ Query template.
        -> q                    -- ^ Query parameters.
        -> (r -> m ())         -- ^ Result consumer.
        -> m ()
forEach = _
{-# INLINE forEach #-}

-- | A version of 'forEach' taking a parser as an argument
forEachWith :: (MonadBracketError m, MonadLocalContext m, ToRow q)
            => Simple.RowParser r
            -> Connection
            -> Query
            -> q
            -> (r -> m ())
            -> m ()
forEachWith parser conn template qs = _
{-# INLINE forEachWith #-}

-- | A version of 'forEach' that does not perform query substitution.
forEach_ :: (MonadBracketError m, MonadLocalContext m, FromRow r) =>
            Connection
         -> Query                -- ^ Query template.
         -> (r -> m ())         -- ^ Result consumer.
         -> m ()
forEach_ = _
{-# INLINE forEach_ #-}

forEachWith_ :: (MonadBracketError m, MonadLocalContext m) =>
                Simple.RowParser r
             -> Connection
             -> Query
             -> (r -> m ())
             -> m ()
forEachWith_ parser conn template = _
{-# INLINE forEachWith_ #-}

-- | Execute @INSERT ... RETURNING@, @UPDATE ... RETURNING@, or other SQL
-- query that accepts multi-row input and is expected to return results.
-- Note that it is possible to write
--    @'query' conn "INSERT ... RETURNING ..." ...@
-- in cases where you are only inserting a single row,  and do not need
-- functionality analogous to 'executeMany'.
--
-- If the list of parameters is empty,  this function will simply return @[]@
-- without issuing the query to the backend.   If this is not desired,
-- consider using the 'Values' constructor instead.
--
-- Throws 'FormatError' if the query could not be formatted correctly.
returning :: (MonadIO m, MonadGetContext m, ToRow q, FromRow r) => Connection -> Query -> [q] -> m [r]
returning = _

-- | A version of 'returning' taking parser as argument
returningWith :: (MonadIO m, MonadGetContext m, ToRow q) => Simple.RowParser r -> Connection -> Query -> [q] -> m [r]
returningWith = _

-- | Execute an @INSERT@, @UPDATE@, or other SQL query that is not
-- expected to return results.
--
-- Returns the number of rows affected.
--
-- Throws 'FormatError' if the query could not be formatted correctly, or
-- a 'SqlError' exception if the backend returns an error.
execute :: (MonadIO m, MonadGetContext m, ToRow q) => Connection -> Query -> q -> m Int64
execute conn template qs = _

-- | A version of 'execute' that does not perform query substitution.
execute_ :: (MonadIO m, MonadGetContext m) => Connection -> Query -> m Int64
execute_ = _

-- | Execute a multi-row @INSERT@, @UPDATE@, or other SQL query that is not
-- expected to return results.
--
-- Returns the number of rows affected.   If the list of parameters is empty,
-- this function will simply return 0 without issuing the query to the backend.
-- If this is not desired, consider using the 'Values' constructor instead.
--
-- Throws 'FormatError' if the query could not be formatted correctly, or
-- a 'SqlError' exception if the backend returns an error.
--
-- For example,  here's a command that inserts two rows into a table
-- with two columns:
--
-- @
-- executeMany c [sql|
--     INSERT INTO sometable VALUES (?,?)
--  |] [(1, \"hello\"),(2, \"world\")]
-- @
--
-- Here's an canonical example of a multi-row update command:
--
-- @
-- executeMany c [sql|
--     UPDATE sometable
--        SET y = upd.y
--       FROM (VALUES (?,?)) as upd(x,y)
--      WHERE sometable.x = upd.x
--  |] [(1, \"hello\"),(2, \"world\")]
-- @

executeMany :: (MonadIO m, MonadGetContext m, ToRow q) => Connection -> Query -> [q] -> m Int64
executeMany = _
-}
