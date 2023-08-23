{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module OpenTelemetry.Instrumentation.Persistent (
  wrapSqlBackend,
  wrapSqlBackend',
) where

import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Acquire.Internal
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vault.Strict as Vault
import Database.Persist.Sql
import Database.Persist.SqlBackend (MkSqlBackendArgs (connRDBMS), emptySqlBackendHooks, getConnVault, getRDBMS, modifyConnVault, setConnHooks)
import Database.Persist.SqlBackend.Internal
import OpenTelemetry.Attributes (Attributes)
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal (adjustContext, getContext)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Monad (MonadTracer (..))
import System.IO.Unsafe (unsafePerformIO)
import UnliftIO.Exception


instance {-# OVERLAPS #-} MonadTracer m => MonadTracer (ReaderT SqlBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer


instance {-# OVERLAPS #-} MonadTracer m => MonadTracer (ReaderT SqlReadBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer


instance {-# OVERLAPS #-} MonadTracer m => MonadTracer (ReaderT SqlWriteBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer


originalConnectionKey :: Vault.Key SqlBackend
originalConnectionKey = unsafePerformIO Vault.newKey
{-# NOINLINE originalConnectionKey #-}


insertOriginalConnection :: SqlBackend -> SqlBackend -> SqlBackend
insertOriginalConnection conn original = modifyConnVault (Vault.insert originalConnectionKey original) conn


lookupOriginalConnection :: SqlBackend -> Maybe SqlBackend
lookupOriginalConnection = Vault.lookup originalConnectionKey . getConnVault


connectionLevelAttributesKey :: Vault.Key (H.HashMap Text Attribute)
connectionLevelAttributesKey = unsafePerformIO Vault.newKey
{-# NOINLINE connectionLevelAttributesKey #-}


{- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
 so that queries are tracked appropriately in the tracing hierarchy.
-}
wrapSqlBackend ::
  MonadIO m =>
  -- | Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  H.HashMap Text Attribute ->
  SqlBackend ->
  m SqlBackend
wrapSqlBackend attrs conn_ = do
  tp <- getGlobalTracerProvider
  wrapSqlBackend' tp attrs conn_


{- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
so that queries are tracked appropriately in the tracing hierarchy.
-}
wrapSqlBackend' ::
  MonadIO m =>
  TracerProvider ->
  -- | Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  [(Text, Attribute)] ->
  SqlBackend ->
  m SqlBackend
wrapSqlBackend' tp attrs conn_ = do
  let conn = Data.Maybe.fromMaybe conn_ (lookupOriginalConnection conn_)
  -- TODO add schema to tracerOptions?
  let t = makeTracer tp "hs-opentelemetry-persistent" tracerOptions
  let hooks =
        emptySqlBackendHooks
          { hookGetStatement = \conn sql stmt -> do
              pure $
                Statement
                  { stmtQuery = \ps -> do
                      ctxt <- getContext
                      let spanCreator = do
                            s <-
                              createSpan
                                t
                                ctxt
                                sql
                                (defaultSpanArguments {kind = Client, attributes = H.insert "db.statement" (toAttribute sql) attrs})
                            adjustContext (insertSpan s)
                            pure (lookupSpan ctxt, s)
                          spanCleanup (parent, s) = do
                            s `endSpan` Nothing
                            adjustContext $ \ctx ->
                              maybe (removeSpan ctx) (`insertSpan` ctx) parent

                      (p, child) <- mkAcquire spanCreator spanCleanup

                      annotateBasics child conn
                      case stmtQuery stmt ps of
                        Acquire stmtQueryAcquireF -> Acquire $ \f ->
                          handleAny
                            ( \(SomeException err) -> do
                                recordException child [] Nothing err
                                endSpan child Nothing
                                throwIO err
                            )
                            (stmtQueryAcquireF f)
                  , stmtExecute = \ps -> do
                      inSpan' t sql (defaultSpanArguments {kind = Client, attributes = H.insert "db.statement" (toAttribute sql) attrs}) $ \s -> do
                        annotateBasics s conn
                        stmtExecute stmt ps
                  , stmtReset = stmtReset stmt
                  , stmtFinalize = stmtFinalize stmt
                  }
          }

  let conn' =
        conn
          { connHooks = hooks
          , connBegin = \f mIso -> do
              let statement =
                    "begin transaction" <> case mIso of
                      Nothing -> mempty
                      Just ReadUncommitted -> " isolation level read uncommitted"
                      Just ReadCommitted -> " isolation level read committed"
                      Just RepeatableRead -> " isolation level repeatable read"
                      Just Serializable -> " isolation level serializable"
              let attrs' = H.insert "db.statement" (toAttribute statement) attrs
              inSpan' t statement (defaultSpanArguments {kind = Client, attributes = attrs'}) $ \s -> do
                annotateBasics s conn
                connBegin conn f mIso
          , connCommit = \f -> do
              inSpan' t "commit" (defaultSpanArguments {kind = Client, attributes = H.insert "db.statement" (toAttribute ("commit" :: Text)) attrs}) $ \s -> do
                annotateBasics s conn
                connCommit conn f
          , connRollback = \f -> do
              inSpan' t "rollback" (defaultSpanArguments {kind = Client, attributes = H.insert "db.statement" (toAttribute ("rollback" :: Text)) attrs}) $ \s -> do
                annotateBasics s conn
                connRollback conn f
          , connClose = do
              inSpan' t "close connection" (defaultSpanArguments {kind = Client, attributes = attrs}) $ \s -> do
                annotateBasics s conn
                connClose conn
          }
  pure $ insertOriginalConnection conn' conn


annotateBasics :: MonadIO m => Span -> SqlBackend -> m ()
annotateBasics span conn = do
  addAttributes
    span
    [ ("db.system", toAttribute $ getRDBMS conn)
    ]
