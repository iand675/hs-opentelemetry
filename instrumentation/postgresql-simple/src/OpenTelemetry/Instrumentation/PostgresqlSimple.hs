{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
[Database semantic conventions have been declared stable.](https://opentelemetry.io/docs/specs/semconv/non-normative/db-migration/) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "database" - to use the stable conventions
- "database/dup" - to emit both the old and the stable conventions
Otherwise, the old conventions will be used. The stable conventions will replace the old conventions in the next major release of this library.
-}
module OpenTelemetry.Instrumentation.PostgresqlSimple (
  staticConnectionAttributes,

  -- * Queries that return results
  query,
  query_,

  -- ** Queries taking parser as argument
  queryWith,
  queryWith_,

  -- * Queries that stream results
  fold,
  foldWithOptions,
  fold_,
  foldWithOptions_,
  forEach,
  forEach_,
  returning,

  -- ** Queries that stream results taking a parser as an argument
  foldWith,
  foldWithOptionsAndParser,
  foldWith_,
  foldWithOptionsAndParser_,
  forEachWith,
  forEachWith_,
  returningWith,

  -- * Statements that do not return results
  execute,
  execute_,
  executeMany,

  -- * Reexported functions
  module X,

  -- * Utility functions
  pgsSpan,

  -- * Span naming helpers (exported for testing)
  extractOperationName,
) where

import Control.Monad.IO.Class
import Control.Monad.IO.Unlift
import qualified Data.ByteString.Char8 as C
import qualified Data.HashMap.Strict as H
import Data.IP
import Data.Int (Int64)
import Data.List
import Data.Maybe (catMaybes)
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
  withConnection,
 )
import GHC.Stack
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource ((.=), (.=?))
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core as TC
import Text.Read (readMaybe)
import UnliftIO


-- | Get attributes that can be attached to a span denoting some database action
staticConnectionAttributes :: (HasCallStack, MonadIO m) => Connection -> m (H.HashMap T.Text Attribute)
staticConnectionAttributes Connection {connectionHandle} = liftIO $ do
  (mDb, mUser, mHost, mPort) <- withMVar connectionHandle $ \pqConn -> do
    (,,,)
      <$> LibPQ.db pqConn
      <*> LibPQ.user pqConn
      <*> LibPQ.host pqConn
      <*> LibPQ.port pqConn

  let stableMaybeAttributes =
        [ unkey SC.db_system_name .= toAttribute ("postgresql" :: T.Text)
        , unkey SC.db_namespace .=? (TE.decodeUtf8 <$> mDb)
        , unkey SC.server_port
            .=? (mPort >>= fmap fst . C.readInt)
        , case (readMaybe . C.unpack) =<< mHost of
            Nothing -> unkey SC.server_address .=? (TE.decodeUtf8 <$> mHost)
            Just (IPv4 ipv4) -> unkey SC.server_address .= T.pack (show ipv4)
            Just (IPv6 ipv6) -> unkey SC.server_address .= T.pack (show ipv6)
        ]
      oldMaybeAttributes =
        [ unkey SC.db_system .= toAttribute ("postgresql" :: T.Text)
        , unkey SC.db_user .=? (TE.decodeUtf8 <$> mUser)
        , unkey SC.db_name .=? (TE.decodeUtf8 <$> mDb)
        , unkey SC.net_peer_port
            .=? (mPort >>= fmap fst . C.readInt)
        , case (readMaybe . C.unpack) =<< mHost of
            Nothing -> unkey SC.net_peer_name .=? (TE.decodeUtf8 <$> mHost)
            Just (IPv4 ipv4) -> unkey SC.net_peer_ip .= T.pack (show ipv4)
            Just (IPv6 ipv6) -> unkey SC.net_peer_ip .= T.pack (show ipv6)
        ]

  semanticsOptions <- getSemanticsOptions
  pure $
    H.fromList $
      catMaybes $
        case databaseOption semanticsOptions of
          Stable -> stableMaybeAttributes
          StableAndOld -> stableMaybeAttributes `union` oldMaybeAttributes
          Old -> oldMaybeAttributes


extractOperationName :: C.ByteString -> Maybe T.Text
extractOperationName stmt =
  let trimmed = C.dropWhile (\c -> c == ' ' || c == '\n' || c == '\r' || c == '\t') stmt
      keyword = C.takeWhile (\c -> c /= ' ' && c /= '\n' && c /= '\r' && c /= '\t' && c /= '(') trimmed
  in if C.null keyword
       then Nothing
       else Just $ T.toUpper $ TE.decodeUtf8 keyword


-- | Function to help with wrapping functions in postgresql-simple
pgsSpan :: HasCallStack => Connection -> C.ByteString -> IO a -> IO a
pgsSpan conn statement f = do
  connAttr <- staticConnectionAttributes conn
  dbName <- maybe "unknown db" TE.decodeUtf8 <$> withConnection conn LibPQ.db
  opts <- getSemanticsOptions
  let stmtText = TE.decodeUtf8 statement
      mOpName = extractOperationName statement
      stableAttrs =
        H.fromList $
          (unkey SC.db_query_text, toAttribute stmtText)
            : maybe [] (\op -> [(unkey SC.db_operation_name, toAttribute op)]) mOpName
      oldAttrs = H.fromList [(unkey SC.db_statement, toAttribute stmtText)]
      callAttr = case databaseOption opts of
        Stable -> stableAttrs
        StableAndOld -> stableAttrs <> oldAttrs
        Old -> oldAttrs
      attrs = connAttr <> callAttr
      spanName = case mOpName of
        Just op -> op <> " " <> dbName
        Nothing -> dbName
      spanArgs = SpanArguments Client attrs [] Nothing
  tracerProvider <- getGlobalTracerProvider
  let tracer = makeTracer tracerProvider $detectInstrumentationLibrary tracerOptions
  TC.inSpan tracer spanName spanArgs f


-- | Instrumented version of 'Simple.query'
query :: (HasCallStack, MonadIO m, ToRow q, FromRow r) => Connection -> Query -> q -> m [r]
query = queryWith Simple.fromRow


-- | Instrumented version of 'Simple.query_'
query_ :: (HasCallStack, MonadIO m, FromRow r) => Connection -> Query -> m [r]
query_ = queryWith_ Simple.fromRow


-- | Instrumented version of 'Simple.queryWith'
queryWith :: (HasCallStack, MonadIO m, ToRow q) => Simple.RowParser r -> Connection -> Query -> q -> m [r]
queryWith parser conn template qs = liftIO $ do
  statement <- formatQuery conn template qs
  pgsSpan conn statement $ Simple.queryWith parser conn template qs


-- | Instrumented version of 'Simple.queryWith_'
queryWith_ :: MonadIO m => Simple.RowParser r -> Connection -> Query -> m [r]
queryWith_ parser conn query = liftIO $ do
  statement <- formatQuery conn query ()
  pgsSpan conn statement $ Simple.queryWith_ parser conn query


-- | Instrumented version of 'Simple.fold'
fold :: (HasCallStack, MonadUnliftIO m, FromRow row, ToRow params) => Connection -> Query -> params -> a -> (a -> row -> m a) -> m a
fold = foldWithOptionsAndParser Simple.defaultFoldOptions Simple.fromRow


-- | Instrumented version of 'Simple.foldWith'
foldWith :: (HasCallStack, MonadUnliftIO m, ToRow params) => Simple.RowParser row -> Connection -> Query -> params -> a -> (a -> row -> m a) -> m a
foldWith = foldWithOptionsAndParser Simple.defaultFoldOptions


-- | Instrumented version of 'Simple.foldWithOptions'
foldWithOptions :: (HasCallStack, MonadUnliftIO m, FromRow row, ToRow params) => FoldOptions -> Connection -> Query -> params -> a -> (a -> row -> m a) -> m a
foldWithOptions opts = foldWithOptionsAndParser opts Simple.fromRow


-- | Instrumented version of 'Simple.foldWithOptionsAndParser'
foldWithOptionsAndParser :: (HasCallStack, MonadUnliftIO m, ToRow params) => FoldOptions -> Simple.RowParser row -> Connection -> Query -> params -> a -> (a -> row -> m a) -> m a
foldWithOptionsAndParser opts parser conn template qs a f = withRunInIO $ \runInIO -> do
  statement <- formatQuery conn template qs
  pgsSpan conn statement $ Simple.foldWithOptionsAndParser opts parser conn template qs a (\a' r -> runInIO (f a' r))


-- | Instrumented version of 'Simple.fold_'
fold_ :: (HasCallStack, MonadUnliftIO m, FromRow r) => Connection -> Query -> a -> (a -> r -> m a) -> m a
fold_ = foldWithOptionsAndParser_ Simple.defaultFoldOptions Simple.fromRow


-- | Instrumented version of 'Simple.foldWith_'
foldWith_ :: MonadUnliftIO m => Simple.RowParser r -> Connection -> Query -> a -> (a -> r -> m a) -> m a
foldWith_ = foldWithOptionsAndParser_ Simple.defaultFoldOptions


-- | Instrumented version of 'Simple.foldWithOptions_'
foldWithOptions_ :: (HasCallStack, MonadUnliftIO m, FromRow r) => FoldOptions -> Connection -> Query -> a -> (a -> r -> m a) -> m a
foldWithOptions_ opts = foldWithOptionsAndParser_ opts Simple.fromRow


-- | Instrumented version of 'Simple.foldWithOptionsAndParser_'
foldWithOptionsAndParser_ :: MonadUnliftIO m => FoldOptions -> Simple.RowParser r -> Connection -> Query -> a -> (a -> r -> m a) -> m a
foldWithOptionsAndParser_ opts parser conn q a f = withRunInIO $ \runInIO -> do
  statement <- formatQuery conn q ()
  pgsSpan conn statement $ Simple.foldWithOptionsAndParser_ opts parser conn q a (\a' r -> runInIO (f a' r))


{- | Instrumented version of 'Simple.forEach'
 forEach :: (HasCallStack, MonadUnliftIO m, ToRow q, FromRow r) => Connection -> Query -> q -> (r -> m ()) -> m ()
-}
forEach conn template qs f = forEachWith Simple.fromRow
{-# INLINE forEach #-}


-- | Instrumented version of 'Simple.forEachWith'
forEachWith :: (HasCallStack, MonadUnliftIO m, ToRow q) => Simple.RowParser r -> Connection -> Query -> q -> (r -> m ()) -> m ()
forEachWith parser conn template qs = foldWith parser conn template qs () . const
{-# INLINE forEachWith #-}


-- | Instrumented version of 'Simple.forEach_'
forEach_ :: (HasCallStack, MonadUnliftIO m, FromRow r) => Connection -> Query -> (r -> m ()) -> m ()
forEach_ = forEachWith_ Simple.fromRow
{-# INLINE forEach_ #-}


-- | Instrumented version of 'Simple.forEachWith_'
forEachWith_ :: MonadUnliftIO m => Simple.RowParser r -> Connection -> Query -> (r -> m ()) -> m ()
forEachWith_ parser conn template = foldWith_ parser conn template () . const
{-# INLINE forEachWith_ #-}


-- | Instrumented version of 'Simple.returning'
returning :: (HasCallStack, MonadIO m, ToRow q, FromRow r) => Connection -> Query -> [q] -> m [r]
returning = returningWith Simple.fromRow


-- | A version of 'returning' taking parser as argument
returningWith :: (HasCallStack, MonadIO m, ToRow q) => Simple.RowParser r -> Connection -> Query -> [q] -> m [r]
returningWith _parser _conn _q [] = pure []
returningWith parser conn q qs = liftIO $ do
  statement <- formatMany conn q qs
  pgsSpan conn statement $ Simple.returningWith parser conn q qs


-- | Instrumented version of 'Simple.execute'
execute :: (HasCallStack, MonadIO m, ToRow q) => Connection -> Query -> q -> m Int64
execute conn template qs = liftIO $ do
  statement <- formatQuery conn template qs
  pgsSpan conn statement $ Simple.execute conn template qs


-- | Instrumented version of 'Simple.execute_'
execute_ :: MonadIO m => Connection -> Query -> m Int64
execute_ conn q = liftIO $ do
  statement <- formatQuery conn q ()
  pgsSpan conn statement $ Simple.execute_ conn q


-- | Instrumented version of 'Simple.executeMany'
executeMany :: (HasCallStack, MonadIO m, ToRow q) => Connection -> Query -> [q] -> m Int64
executeMany _conn _q [] = pure 0
executeMany conn q qs = liftIO $ do
  statement <- formatMany conn q qs
  pgsSpan conn statement $ Simple.executeMany conn q qs
