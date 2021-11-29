{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module OpenTelemetry.Instrumentation.Persistent
  ( insertConnectionContext
  , lookupConnectionContext
  , wrapSqlBackend
  ) where
import OpenTelemetry.Trace
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
import OpenTelemetry.Trace.Monad (bracketErrorUnliftIO, MonadGetContext(..), MonadLocalContext(..), MonadTracer(..))
import Control.Monad.Reader
import qualified Data.Text as T

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

-- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
-- so that queries are tracked appropriately in the tracing hierarchy.
wrapSqlBackend
  :: MonadIO m 
  => Context 
  -> [(Text, Attribute)]
  -- ^ Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  -> SqlBackend 
  -> m SqlBackend
wrapSqlBackend ctxt attrs conn = do
  tp <- getGlobalTracerProvider
  let conn' = Data.Maybe.fromMaybe conn (lookupOriginalConnection conn)

  -- TODO add schema to tracerOptions?
  t <- OpenTelemetry.Trace.getTracer tp "otel-persistent" tracerOptions
  let hooks = emptySqlBackendHooks
        { hookGetStatement = \conn sql stmt -> do
            pure $ Statement
              { stmtQuery = \ps -> do
                  child <- mkAcquire (createSpan
                    t
                    (fromMaybe OpenTelemetry.Context.empty $ lookupConnectionContext conn)
                    sql
                    (defaultSpanArguments { kind = Client, attributes = attrs })
                    ) (`endSpan` Nothing)

                  annotateBasics child conn
                  addAttribute child "db.statement" sql
                  case stmtQuery stmt ps of
                    Acquire stmtQueryAcquireF -> Acquire $ \f ->
                      handleAny
                        (\err -> do
                          recordException child [] Nothing err
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
                        (fromMaybe OpenTelemetry.Context.empty $ lookupConnectionContext conn)
                        sql
                        (defaultSpanArguments { kind = Client, attributes = attrs })
                    )
                    (
                      \mErr child -> do
                        case mErr of
                          Nothing -> endSpan child Nothing
                          Just err -> do
                            recordException child [] Nothing err
                            endSpan child Nothing
                            throwIO err
                    )
                    (\s -> do
                      annotateBasics s conn
                      addAttribute s "db.statement" sql
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
            { newEventName = "transaction begin"
            , newEventAttributes = case mIso of
                Nothing -> []
                Just iso -> [("db.sql.transaction.isolation_level", toAttribute $ T.pack $ show iso)]
            , newEventTimestamp = Nothing
            }
        connBegin conn f mIso
    , connCommit = \f -> do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "transaction commit"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connCommit conn f
    , connRollback = \f -> do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "transaction rollback"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connRollback conn f
    , connClose = do
        let mSpan = lookupSpan ctxt
        forM_ mSpan $ \span -> do
          addEvent span $ NewEvent
            { newEventName = "connection close"
            , newEventAttributes = []
            , newEventTimestamp = Nothing
            }
        connClose conn
    }

annotateBasics :: MonadIO m => Span -> SqlBackend -> m ()
annotateBasics span conn = do
  addAttributes span
    [ ("db.system", toAttribute $ getRDBMS conn)
    ]