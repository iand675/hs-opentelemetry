{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module OpenTelemetry.Instrumentation.Persistent
  ( wrapSqlBackend
  ) where
import OpenTelemetry.Trace.Core
import OpenTelemetry.Context
import Data.Acquire.Internal
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Database.Persist.Sql
import Database.Persist.SqlBackend (setConnHooks, SqlBackendHooks (hookGetStatement), emptySqlBackendHooks, MkSqlBackendArgs (connRDBMS), getRDBMS, getConnVault, modifyConnVault)
import Database.Persist.SqlBackend.Internal
import Control.Monad.IO.Class
import System.IO.Unsafe (unsafePerformIO)
import qualified Data.Vault.Strict as Vault
import OpenTelemetry.Attributes (Attributes)
import OpenTelemetry.Resource
import UnliftIO.Exception
import OpenTelemetry.Trace.Monad (MonadTracer(..))
import Control.Monad.Reader
import qualified Data.Text as T
import OpenTelemetry.Context.ThreadLocal (getContext, adjustContext)

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

connectionLevelAttributesKey :: Vault.Key [(Text, Attribute)]
connectionLevelAttributesKey = unsafePerformIO Vault.newKey
{-# NOINLINE connectionLevelAttributesKey #-}

-- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
-- so that queries are tracked appropriately in the tracing hierarchy.
wrapSqlBackend
  :: MonadIO m
  => [(Text, Attribute)]
  -- ^ Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  -> SqlBackend
  -> m SqlBackend
wrapSqlBackend attrs conn_ = do
  tp <- getGlobalTracerProvider
  let conn = Data.Maybe.fromMaybe conn_ (lookupOriginalConnection conn_)
  -- TODO add schema to tracerOptions?
  t <- OpenTelemetry.Trace.Core.getTracer tp "hs-opentelemetry-persistent" tracerOptions
  let hooks = emptySqlBackendHooks
        { hookGetStatement = \conn sql stmt -> do
            pure $ Statement
              { stmtQuery = \ps -> do
                  ctxt <- getContext
                  let spanCreator = do
                        s <- createSpan
                          t
                          ctxt
                          sql
                          (defaultSpanArguments { kind = Client, attributes = ("db.statement", toAttribute sql) : attrs })
                        adjustContext (insertSpan s)
                        pure (lookupSpan ctxt, s)
                      spanCleanup (parent, s) = do
                        s `endSpan` Nothing
                        adjustContext $ \ctx ->
                          maybe ctx (`insertSpan` ctx) parent

                  (p, child) <- mkAcquire spanCreator spanCleanup

                  annotateBasics child conn
                  case stmtQuery stmt ps of
                    Acquire stmtQueryAcquireF -> Acquire $ \f ->
                      handleAny
                        (\(SomeException err) -> do
                          recordException child [] Nothing err
                          endSpan child Nothing
                          throwIO err
                        )
                        (stmtQueryAcquireF f)

              , stmtExecute = \ps -> do
                inSpan' t sql (defaultSpanArguments { kind = Client, attributes = ("db.statement", toAttribute sql) : attrs }) $ \s -> do
                  annotateBasics s conn
                  stmtExecute stmt ps
              , stmtReset = stmtReset stmt
              , stmtFinalize = stmtFinalize stmt
              }
        }

  let conn' = conn
        { connHooks = hooks
        , connBegin = \f mIso -> do
            let statement = "begin transaction" <> case mIso of
                  Nothing -> mempty
                  Just ReadUncommitted -> " isolation level read uncommitted"
                  Just ReadCommitted -> " isolation level read committed"
                  Just RepeatableRead -> " isolation level repeatable read"
                  Just Serializable -> " isolation level serializable"
            let attrs' = ("db.statement", toAttribute statement) : attrs
            inSpan' t statement (defaultSpanArguments { kind = Client, attributes = attrs' }) $ \s -> do
              annotateBasics s conn
              connBegin conn f mIso
        , connCommit = \f -> do
            inSpan' t "commit" (defaultSpanArguments { kind = Client, attributes = ("db.statement", toAttribute ("commit" :: Text)): attrs }) $ \s -> do
              annotateBasics s conn
              connCommit conn f
        , connRollback = \f -> do
            inSpan' t "rollback" (defaultSpanArguments { kind = Client, attributes = ("db.statement", toAttribute ("rollback" :: Text)): attrs }) $ \s -> do
              annotateBasics s conn
              connRollback conn f
        , connClose = do
            inSpan' t "close connection" (defaultSpanArguments { kind = Client, attributes = attrs }) $ \s -> do
              annotateBasics s conn
              connClose conn
        }
  pure $ insertOriginalConnection conn' conn

annotateBasics :: MonadIO m => Span -> SqlBackend -> m ()
annotateBasics span conn = do
  addAttributes span
    [ ("db.system", toAttribute $ getRDBMS conn)
    ]