{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
-- option for module re-export
{-# OPTIONS_GHC -Wno-missing-import-lists #-}

{- | Wrapper module for @Database.Persist.MySQL@ with @OpenTelemetry.Instrumentation.Persistent@.

[New HTTP semantic conventions have been declared stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "http" - to use the stable conventions
- "http/dup" - to emit both the old and the stable conventions
Otherwise, the old conventions will be used. The stable conventions will replace the old conventions in the next major release of this library.
-}
module OpenTelemetry.Instrumentation.Persistent.MySQL (
  withMySQLPool,
  withMySQLConn,
  createMySQLPool,
  module Database.Persist.Sql,
  MySQL.ConnectInfo (..),
  MySQL.SSLInfo (..),
  MySQL.defaultConnectInfo,
  MySQL.defaultSSLInfo,
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
import Data.Foldable (Foldable (fold))
import Data.Functor ((<&>))
import qualified Data.HashMap.Strict as H
import Data.IP (IP)
import Data.Maybe (fromMaybe)
import Data.Monoid (Last (Last, getLast))
import Data.Pool (Pool)
import Data.String (IsString (fromString))
import Data.Text (Text)
import Database.MySQL.Base (ConnectInfo (..))
import qualified Database.MySQL.Base as MySQL
import qualified Database.Persist.MySQL as Orig
import Database.Persist.Sql
import qualified OpenTelemetry.Instrumentation.Persistent as Otel
import OpenTelemetry.SemConvStabilityOptIn
import qualified OpenTelemetry.Trace.Core as Otel
import Text.Read (readMaybe)


{- | Create a MySQL connection pool.  Note that it's your
responsibility to properly close the connection pool when
unneeded.  Use 'withMySQLPool' for automatic resource control.
-}
createMySQLPool
  :: (MonadUnliftIO m, MonadLoggerIO m)
  => Otel.TracerProvider
  -> H.HashMap Text Otel.Attribute
  -- ^ Additional attributes.
  -> MySQL.ConnectInfo
  -- ^ Connection information.
  -> Int
  -- ^ Number of connections to be kept open in the pool.
  -> m (Pool SqlBackend)
createMySQLPool tp attrs ci = createSqlPool $ fmap snd . openMySQLConn tp attrs ci


{- | Create a MySQL connection pool and run the given action.
The pool is properly released after the action finishes using
it.  Note that you should not use the given 'ConnectionPool'
outside the action since it may be already been released.
-}
withMySQLPool
  :: (MonadLoggerIO m, MonadUnliftIO m)
  => Otel.TracerProvider
  -> H.HashMap Text Otel.Attribute
  -- ^ Additional attributes.
  -> MySQL.ConnectInfo
  -- ^ Connection information.
  -> Int
  -- ^ Number of connections to be kept open in the pool.
  -> (Pool SqlBackend -> m a)
  -- ^ Action to be executed that uses the connection pool.
  -> m a
withMySQLPool tp attrs ci = withSqlPool $ fmap snd . openMySQLConn tp attrs ci


{- | Open a connection to MySQL server, initialize the 'SqlBackend' and return
their tuple

About attributes, see https://opentelemetry.io/docs/reference/specification/trace/semantic_conventions/database/.
-}
openMySQLConn
  :: Otel.TracerProvider
  -> H.HashMap Text Otel.Attribute
  -- ^ Additional attributes.
  -> MySQL.ConnectInfo
  -- ^ Connection information.
  -> LogFunc
  -> IO (MySQL.Connection, SqlBackend)
openMySQLConn tp attrs ci@MySQL.ConnectInfo {connectUser, connectPort, connectOptions, connectHost} logFunc = do
  let
    portAttr, transportAttr :: Otel.Attribute
    portAttr = fromString $ show connectPort
    transportAttr =
      fromMaybe "ip_tcp" $
        getLast $
          fold $
            connectOptions <&> \case
              MySQL.Protocol p ->
                Last $ Just $ case p of
                  MySQL.TCP -> "ip_tcp"
                  MySQL.Socket -> "other"
                  MySQL.Pipe -> "pipe"
                  MySQL.Memory -> "inproc"
              _ -> Last Nothing
    addStableAttributes =
      H.union
        [ ("db.connection_string" :: Text, fromString $ showsPrecConnectInfoMasked 0 ci "")
        , ("db.user", fromString connectUser)
        , ("server.port", portAttr)
        , ("network.peer.port", portAttr)
        , ("net.transport", transportAttr)
        , (maybe "server.address" (const "network.peer.address") (readMaybe connectHost :: Maybe IP), fromString connectHost)
        ]
    addOldAttributes =
      -- "net.sock.family" is unnecessary because it must be "inet" when "net.sock.peer.addr" or "net.sock.host.addr" is set.
      H.union
        [ ("db.connection_string" :: Text, fromString $ showsPrecConnectInfoMasked 0 ci "")
        , ("db.user", fromString connectUser)
        , ("net.peer.port", portAttr)
        , ("net.sock.peer.port", portAttr)
        , ("net.transport", transportAttr)
        , (maybe "net.peer.name" (const "net.sock.peer.addr") (readMaybe connectHost :: Maybe IP), fromString connectHost)
        ]

  semConvStabilityOptIn <- getSemConvStabilityOptIn
  let attrs' =
        case semConvStabilityOptIn of
          Stable -> addStableAttributes attrs
          Both -> addStableAttributes . addOldAttributes $ attrs
          Old -> addOldAttributes attrs
  (conn, backend) <- Orig.openMySQLConn ci logFunc
  backend' <- Otel.wrapSqlBackend' tp attrs' backend
  pure (conn, backend')


{- | Same as 'withMySQLPool', but instead of opening a pool
of connections, only one connection is opened.
-}
withMySQLConn
  :: (MonadUnliftIO m, MonadLoggerIO m)
  => Otel.TracerProvider
  -> H.HashMap Text Otel.Attribute
  -- ^ Additional attributes.
  -> MySQL.ConnectInfo
  -- ^ Connection information.
  -> (SqlBackend -> m a)
  -- ^ Action to be executed that uses the connection.
  -> m a
withMySQLConn tp attrs ci = withSqlConn $ fmap snd . openMySQLConn tp attrs ci


showsPrecConnectInfoMasked :: Int -> MySQL.ConnectInfo -> ShowS
showsPrecConnectInfoMasked d MySQL.ConnectInfo {connectHost, connectPort, connectUser, connectDatabase, connectOptions, connectPath, connectSSL} =
  showParen (d > 10) $
    showString "ConnectInfo {"
      . showString "connectHost = "
      . shows connectHost
      . showString ", "
      . showString "connectPort = "
      . shows connectPort
      . showString ", "
      . showString "connectUser = "
      . shows connectUser
      . showString ", "
      . showString "connectPassword = \"****\", "
      . showString "connectDatabase = "
      . shows connectDatabase
      . showString ", "
      . showString "connectOptions = "
      . shows connectOptions
      . showString ", "
      . showString "connectPath = "
      . shows connectPath
      . showString ", "
      . showString "connectSSL = "
      . shows connectSSL
      . showString "}"
