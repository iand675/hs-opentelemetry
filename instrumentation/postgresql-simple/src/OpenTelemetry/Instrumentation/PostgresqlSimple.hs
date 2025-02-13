{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
[New HTTP semantic conventions have been declared stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "http" - to use the stable conventions
- "http/dup" - to emit both the old and the stable conventions
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
) where

import Control.Monad.IO.Class
import Control.Monad.IO.Unlift
import qualified Data.ByteString.Char8 as C
import qualified Data.HashMap.Strict as H
import Data.IP
import Data.Int (Int64)
import Data.List
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
  withConnection,
 )
import GHC.Stack
import OpenTelemetry.Resource ((.=), (.=?))
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core as TC
import OpenTelemetry.Trace.Monad
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
        [ "db.system" .= toAttribute ("postgresql" :: T.Text)
        , "db.user" .=? (TE.decodeUtf8 <$> mUser)
        , "db.name" .=? (TE.decodeUtf8 <$> mDb)
        , "server.port"
            .=? ( do
                    port <- TE.decodeUtf8 <$> mPort
                    (readMaybe $ T.unpack port) :: Maybe Int
                )
        , case (readMaybe . C.unpack) =<< mHost of
            Nothing -> "server.address" .=? (TE.decodeUtf8 <$> mHost)
            Just (IPv4 ipv4) -> "server.address" .= T.pack (show ipv4)
            Just (IPv6 ipv6) -> "server.address" .= T.pack (show ipv6)
        ]
      oldMaybeAttributes =
        [ "db.system" .= toAttribute ("postgresql" :: T.Text)
        , "db.user" .=? (TE.decodeUtf8 <$> mUser)
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

  semanticsOptions <- getSemanticsOptions
  pure $
    H.fromList $
      catMaybes $
        case httpOption semanticsOptions of
          Stable -> stableMaybeAttributes
          StableAndOld -> stableMaybeAttributes `union` oldMaybeAttributes
          Old -> oldMaybeAttributes


-- | Function to help with wrapping functions in postgresql-simple
pgsSpan :: HasCallStack => Connection -> C.ByteString -> IO a -> IO a
pgsSpan conn statement f = do
  connAttr <- staticConnectionAttributes conn
  dbName <- maybe "unknown db" TE.decodeUtf8 <$> withConnection conn LibPQ.db
  let callAttr = H.fromList [("db.statement", toAttribute $ TE.decodeUtf8 statement)]
      attrs = connAttr <> callAttr
      spanArgs = SpanArguments Client attrs [] Nothing
  tracerProvider <- getGlobalTracerProvider
  let tracer = makeTracer tracerProvider $detectInstrumentationLibrary tracerOptions
  TC.inSpan tracer dbName spanArgs f


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
executeMany conn q qs = liftIO $ do
  statement <- formatMany conn q qs
  pgsSpan conn statement $ Simple.executeMany conn q qs
