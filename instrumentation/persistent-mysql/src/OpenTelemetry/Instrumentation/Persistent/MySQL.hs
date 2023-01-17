-- option for module re-export
{-# OPTIONS_GHC -Wno-missing-import-lists #-}

-- | Wrapper module for @Database.Persist.MySQL@ with @OpenTelemetry.Instrumentation.Persistent@.
module OpenTelemetry.Instrumentation.Persistent.MySQL (
  withMySQLPool,
  withMySQLConn,
  createMySQLPool,
  module Database.Persist.Sql,
  MySQL.ConnectInfo (..),
  MySQLBase.SSLInfo (..),
  MySQL.defaultConnectInfo,
  MySQLBase.defaultSSLInfo,
  Orig.MySQLConf (..),

  -- * @ON DUPLICATE KEY UPDATE@ Functionality
  Orig.insertOnDuplicateKeyUpdate,
  Orig.insertManyOnDuplicateKeyUpdate,
  Orig.HandleUpdateCollision,
  Orig.copyField,
  Orig.copyUnlessNull,
  Orig.copyUnlessEmpty,
  Orig.copyUnlessEq,
  openMySQLConn,
) where

import Control.Monad.IO.Unlift (MonadUnliftIO)
import Control.Monad.Logger (MonadLoggerIO)
import Data.Pool (Pool)
import Data.Text (Text)
import qualified Database.MySQL.Base as MySQLBase
import qualified Database.MySQL.Simple as MySQL
import qualified Database.Persist.MySQL as Orig
import Database.Persist.Sql
import qualified OpenTelemetry.Instrumentation.Persistent as Otel
import qualified OpenTelemetry.Trace.Core as Otel


{- | Create a MySQL connection pool.  Note that it's your
responsibility to properly close the connection pool when
unneeded.  Use 'withMySQLPool' for automatic resource control.
-}
createMySQLPool ::
  (MonadUnliftIO m, MonadLoggerIO m) =>
  Otel.TracerProvider ->
  -- | Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  [(Text, Otel.Attribute)] ->
  -- | Connection information.
  MySQL.ConnectInfo ->
  -- | Number of connections to be kept open in the pool.
  Int ->
  m (Pool SqlBackend)
createMySQLPool tp attrs ci = createSqlPool $ open' tp attrs ci


{- | Create a MySQL connection pool and run the given action.
The pool is properly released after the action finishes using
it.  Note that you should not use the given 'ConnectionPool'
outside the action since it may be already been released.
-}
withMySQLPool ::
  (MonadLoggerIO m, MonadUnliftIO m) =>
  Otel.TracerProvider ->
  -- | Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  [(Text, Otel.Attribute)] ->
  -- | Connection information.
  MySQL.ConnectInfo ->
  -- | Number of connections to be kept open in the pool.
  Int ->
  -- | Action to be executed that uses the connection pool.
  (Pool SqlBackend -> m a) ->
  m a
withMySQLPool tp attrs ci = withSqlPool $ open' tp attrs ci


{- | Open a connection to MySQL server, initialize the 'SqlBackend' and return
their tuple
-}
openMySQLConn ::
  Otel.TracerProvider ->
  -- | Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  [(Text, Otel.Attribute)] ->
  MySQL.ConnectInfo ->
  LogFunc ->
  IO (MySQL.Connection, SqlBackend)
openMySQLConn tp attrs ci logFunc = do
  (conn, backend) <- Orig.openMySQLConn ci logFunc
  backend' <- Otel.wrapSqlBackend' tp attrs backend
  pure (conn, backend')


{- | Same as 'withMySQLPool', but instead of opening a pool
of connections, only one connection is opened.
-}
withMySQLConn ::
  (MonadUnliftIO m, MonadLoggerIO m) =>
  Otel.TracerProvider ->
  -- | Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  [(Text, Otel.Attribute)] ->
  -- | Connection information.
  MySQL.ConnectInfo ->
  -- | Action to be executed that uses the connection.
  (SqlBackend -> m a) ->
  m a
withMySQLConn tp attrs ci = withSqlConn $ open' tp attrs ci


-- | Internal function that opens a connection to the MySQL server.
open' :: Otel.TracerProvider -> [(Text, Otel.Attribute)] -> MySQL.ConnectInfo -> LogFunc -> IO SqlBackend
open' tp attrs ci logFunc = snd <$> openMySQLConn tp attrs ci logFunc
