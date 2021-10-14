{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleInstances #-}
module OpenTelemetry.Instrumentation.Persistent
  ( insertConnectionContext
  , lookupConnectionContext
  , wrapSqlBackend
  ) where
import OpenTelemetry.Trace
import OpenTelemetry.Context
import Data.Acquire.Internal
import Data.Text (Text)
import Database.Persist.Sql
import Database.Persist.SqlBackend (setConnHooks, SqlBackendHooks (hookGetStatement), emptySqlBackendHooks, MkSqlBackendArgs (connRDBMS), getRDBMS, getConnVault, modifyConnVault)
import Database.Persist.SqlBackend.Internal
import Control.Monad.IO.Class
import System.IO.Unsafe (unsafePerformIO)
import qualified Data.Vault.Strict as Vault
import OpenTelemetry.Resource
import UnliftIO.Exception
import OpenTelemetry.Trace.Monad (bracketErrorUnliftIO, MonadGetContext(..), MonadLocalContext(..), MonadTracerProvider(..), MonadTracer(..))
import Control.Monad.Reader
import qualified Data.Maybe

instance {-# OVERLAPS #-} MonadTracerProvider m => MonadTracerProvider (ReaderT SqlBackend m) where
  getTracerProvider = lift getTracerProvider
instance {-# OVERLAPS #-} MonadTracerProvider m => MonadTracerProvider (ReaderT SqlReadBackend m) where
  getTracerProvider = lift getTracerProvider
instance {-# OVERLAPS #-} MonadTracerProvider m => MonadTracerProvider (ReaderT SqlWriteBackend m) where
  getTracerProvider = lift getTracerProvider

instance {-# OVERLAPS #-} MonadTracer m => MonadTracer (ReaderT SqlBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer
instance {-# OVERLAPS #-} MonadTracer m => MonadTracer (ReaderT SqlReadBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer
instance {-# OVERLAPS #-} MonadTracer m => MonadTracer (ReaderT SqlWriteBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer

instance {-# OVERLAPS #-} MonadGetContext m => MonadGetContext (ReaderT SqlBackend m) where
  getContext = lift getContext
instance {-# OVERLAPS #-} MonadGetContext m => MonadGetContext (ReaderT SqlReadBackend m) where
  getContext = lift getContext
instance {-# OVERLAPS #-} MonadGetContext m => MonadGetContext (ReaderT SqlWriteBackend m) where
  getContext = lift getContext

instance {-# OVERLAPS #-} MonadLocalContext m => MonadLocalContext (ReaderT SqlBackend m) where
  localContext f m = mapReaderT (localContext f) $ do
    ctx <- getContext
    local (insertConnectionContext ctx) m
instance {-# OVERLAPS #-} MonadLocalContext m => MonadLocalContext (ReaderT SqlReadBackend m) where
  localContext f m = mapReaderT (localContext f) $ do
    ctx <- getContext
    local (SqlReadBackend . insertConnectionContext ctx . unSqlReadBackend) m
instance {-# OVERLAPS #-} MonadLocalContext m => MonadLocalContext (ReaderT SqlWriteBackend m) where
  localContext f m = mapReaderT (localContext f) $ do
    ctx <- getContext
    local (SqlWriteBackend . insertConnectionContext ctx . unSqlWriteBackend) m

contextKey :: Vault.Key Context
contextKey = unsafePerformIO Vault.newKey
{-# NOINLINE contextKey #-}

insertConnectionContext :: Context -> SqlBackend -> SqlBackend
insertConnectionContext ctx = modifyConnVault (Vault.insert contextKey ctx)

lookupConnectionContext :: SqlBackend -> Maybe Context
lookupConnectionContext = Vault.lookup contextKey . getConnVault

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

wrapSqlBackend :: MonadIO m => TracerProvider -> Context -> SqlBackend -> m SqlBackend
wrapSqlBackend tp ctxt conn = do
  let conn' = Data.Maybe.fromMaybe conn (lookupOriginalConnection conn)

  -- TODO add schema to tracerOptions?
  t <- OpenTelemetry.Trace.getTracer tp "otel-persistent" tracerOptions
  let hooks = emptySqlBackendHooks
        { hookGetStatement = \conn sql stmt -> do
            pure $ Statement
              { stmtQuery = \ps -> do
                  child <- mkAcquire (createSpan
                    t
                    (lookupConnectionContext conn)
                    "db.query"
                    (emptySpanArguments { startingKind = Client })
                    ) (`endSpan` Nothing)

                  case stmtQuery stmt ps of
                    Acquire stmtQueryAcquireF -> Acquire $ \f ->
                      handleAny
                        (\err -> do
                          recordException child err
                          endSpan child Nothing
                          throwIO err
                        )
                        (do
                          stmtQueryAcquireF f
                        )

              , stmtExecute = \ps -> do
                  bracketErrorUnliftIO
                    (
                      createSpan
                        t
                        (lookupConnectionContext conn)
                        "db.execute"
                        (emptySpanArguments { startingKind = Client })
                    )
                    (
                      \mErr child -> do
                        case mErr of
                          Nothing -> endSpan child Nothing
                          Just err -> do
                            recordException child err
                            endSpan child Nothing
                            throwIO err
                    )
                    (\_ -> do
                      stmtExecute stmt ps
                    )

              , stmtReset = stmtReset stmt
              , stmtFinalize = stmtFinalize stmt
              }
        }
  -- TODO, associating the connBegin, connCommit, connClose, connRollback with the right parent span
  -- is tricky. Currently going to be attached to spans like `runDB`?
  pure $ (insertConnectionContext ctxt $ insertOriginalConnection conn' conn)
    { connHooks = hooks
    , connBegin = \f mIso -> do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "db.sql.transaction.begin"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connBegin conn f mIso
    , connCommit = \f -> do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "db.sql.transaction.commit"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connCommit conn f
    , connRollback = \f -> do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "db.sql.transaction.rollback"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connRollback conn f
    , connClose = do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "db.connection.close"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connClose conn
    }

annotateBasics :: MonadIO m => Span -> SqlBackend -> m ()
annotateBasics span conn = do
  insertAttributes span
    [ ("db.system", toAttribute $ getRDBMS conn)
    -- , ("db.connection_string", _)
    -- , ("db.user", _)
    -- , ("net.peer.ip", _)
    -- , ("net.peer.name", _)
    -- , ("net.peer.port", _)
    -- , ("net.transport", _)
    -- -- per action attributes
    -- , ("db.name", _)
    -- , ("db.statement", _)
    -- , ("db.operation", _)
    -- -- if possible
    -- , ("db.sql.table", _)
    ]