{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
module OpenTelemetry.Instrumentation.Persistent where
import OpenTelemetry.Trace
import OpenTelemetry.Context
import Data.Acquire.Internal
import Data.Text (Text)
import Database.Persist.Sql
import Database.Persist.SqlBackend (setConnHooks, SqlBackendHooks (hookGetStatement), emptySqlBackendHooks, MkSqlBackendArgs (connRDBMS), getRDBMS, getConnVault)
import Control.Monad.IO.Class
import System.IO.Unsafe (unsafePerformIO)
import qualified Data.Vault.Strict as Vault
import OpenTelemetry.Resource
import UnliftIO.Exception
import OpenTelemetry.Trace.Monad (bracketErrorUnliftIO)

contextKey :: Vault.Key Context
contextKey = unsafePerformIO Vault.newKey
{-# NOINLINE contextKey #-}

connectionLevelAttributesKey :: Vault.Key [(Text, Attribute)]
connectionLevelAttributesKey = unsafePerformIO Vault.newKey
{-# NOINLINE connectionLevelAttributesKey #-}

wrapSqlBackend :: MonadIO m => TracerProvider -> SqlBackend -> m SqlBackend
wrapSqlBackend tp conn = do
  -- TODO add schema to tracerOptions
  t <- getTracer tp "otel-persistent" tracerOptions
  let hooks = emptySqlBackendHooks
        { hookGetStatement = \conn sql stmt -> do
            pure $ Statement
              { stmtQuery = \ps -> do
                  child <- mkAcquire (createSpan
                    t
                    (Vault.lookup contextKey $ getConnVault conn)
                    "db.query"
                    (emptySpanArguments { startingKind = Client })
                    ) (`endSpan` Nothing)
                  -- annotateBasics child conn
                  -- insertAttributes child 
                  --   [ (databaseQueryField, toAttribute t)
                  --   , (databaseQueryParametersField, toAttribute t)
                  --   ]

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
                  -- Raw.spanning
                  --   tcTracer
                  --   (trace tcSpan)
                  --   tcSvc
                  --   (pure $ spanId tcSpan)
                  --   "db.query"
                  --   (\child -> do

                  --     Raw.addSpanField child databaseQueryField t
                  --     Raw.addSpanField child databaseQueryParametersField $ show ps
                  bracketErrorUnliftIO 
                    (
                      createSpan
                        t
                        (Vault.lookup contextKey $ getConnVault conn)
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
  pure $ setConnHooks hooks conn

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