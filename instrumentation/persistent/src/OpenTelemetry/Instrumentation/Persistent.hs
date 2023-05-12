{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module OpenTelemetry.Instrumentation.Persistent (
  wrapSqlBackend,
) where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Acquire.Internal
import Data.IORef
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


{-
Design notes:

In some OTel export destinations like Honeycomb, the cost is per-span. Consquently, we want to minimize the number of spans we create. In particular, we want to avoid creating a span for every query, since they add up cost-wise.

However, we also want to capture transactions as spans. Therefore, for pool acquisitions we track the time between trying to acquire the connection and the time the connection is obtained as an attribute on the initial span.
-}

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


{- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
 so that queries are tracked appropriately in the tracing hierarchy.
-}
wrapSqlBackend
  :: (MonadIO m)
  => [(Text, Attribute)]
  -- ^ Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  -> SqlBackend
  -> m SqlBackend
wrapSqlBackend attrs conn_ = do
  tp <- getGlobalTracerProvider
  let conn = Data.Maybe.fromMaybe conn_ (lookupOriginalConnection conn_)
  {- A connection is acquired when the connection pool is asked for a connection. The runSqlPool function in Persistent then
    immediately begins a transaction and ensures the transaction is committed or rolled back. Since we want to capture the
    transaction as a span, we have to use track the current Span in flight. We do this because we can't hand off
    the Span between connBegin/connCommit/connRollback as return values.
  -}
  connParentSpan <- liftIO $ newIORef Nothing
  connSpanInFlight <- liftIO $ newIORef Nothing
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
                                (defaultSpanArguments {kind = Client, attributes = ("db.statement", toAttribute sql) : attrs})
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
                                recordException child [("exception.escaped", toAttribute True)] Nothing err
                                endSpan child Nothing
                                throwIO err
                            )
                            (stmtQueryAcquireF f)
                  , stmtExecute = \ps -> do
                      inSpan' t sql (defaultSpanArguments {kind = Client, attributes = ("db.statement", toAttribute sql) : attrs}) $ \s -> do
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
              ctxt <- getContext
              s <- createSpan t ctxt "transaction" (defaultSpanArguments {kind = Client, attributes = attrs})
              annotateBasics s conn
              writeIORef connSpanInFlight (Just s)
              writeIORef connParentSpan (lookupSpan ctxt)
              adjustContext (insertSpan s)
              case mIso of
                Nothing -> pure ()
                Just iso -> addAttribute s "db.transaction.isolation" $ case iso of
                  ReadUncommitted -> "read uncommitted" :: Text
                  ReadCommitted -> "read committed"
                  RepeatableRead -> "repeatable read"
                  Serializable -> "serializable"
              connBegin conn f mIso
          , connCommit = \f -> do
              spanInFlight <- readIORef connSpanInFlight
              parentSpan <- readIORef connParentSpan
              let act = do
                    result <- tryAny $ connCommit conn f
                    forM_ spanInFlight $ \s -> do
                      addAttribute s "db.transaction.outcome" ("committed" :: Text) >> endSpan s Nothing
                      case result of
                        Left (SomeException err) -> do
                          recordException s [("exception.escaped", toAttribute True)] Nothing err
                          throwIO err
                        Right _ -> pure ()
              act `finally` do
                adjustContext $ \ctx ->
                  maybe (removeSpan ctx) (`insertSpan` ctx) parentSpan
                forM_ spanInFlight $ \s -> endSpan s Nothing
          , connRollback = \f -> do
              spanInFlight <- readIORef connSpanInFlight
              parentSpan <- readIORef connParentSpan
              let act = do
                    result <- tryAny $ connRollback conn f
                    forM_ spanInFlight $ \s -> do
                      addAttribute s "db.transaction.outcome" ("rolled back" :: Text) >> endSpan s Nothing
                      case result of
                        Left (SomeException err) -> do
                          recordException s [("exception.escaped", toAttribute True)] Nothing err
                          throwIO err
                        Right _ -> pure ()
              act `finally` do
                adjustContext $ \ctx ->
                  maybe (removeSpan ctx) (`insertSpan` ctx) parentSpan
                forM_ spanInFlight $ \s -> endSpan s Nothing
          , -- TODO: This doesn't work when we wrap the connections for the pool.
            connClose = do
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
