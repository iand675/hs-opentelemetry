{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{- |
Module      : OpenTelemetry.Instrumentation.Persistent
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Automatic tracing for Persistent database operations
Stability   : experimental

= Overview

Instruments database queries made through the @persistent@ library by
hooking into Persistent's internal statement hooks. Every SQL query
generates a span with the query text and connection metadata.

= Quick example

Wrap each 'SqlBackend' as it is handed out from the pool (here using
extensible pool hooks; attribute maps often carry static connection info
such as server address):

@
import Database.Persist.Postgresql (createPostgresqlPool)
import Database.Persist.Sql
  ( defaultSqlPoolHooks
  , runSqlPoolWithExtensibleHooks
  , setAlterBackend
  )
import OpenTelemetry.Instrumentation.Persistent (wrapSqlBackend)

main :: IO ()
main = do
  pool <- createPostgresqlPool connStr poolSize
  runSqlPoolWithExtensibleHooks myAction pool Nothing $
    setAlterBackend defaultSqlPoolHooks $ \conn ->
      wrapSqlBackend mempty conn
@

'wrapSqlBackend' uses the process-global tracer provider; initialize it from
your application (for example 'OpenTelemetry.Trace.withTracerProvider' from
@hs-opentelemetry-sdk@). Use 'wrapSqlBackend'' when you hold a specific
'TracerProvider'.

= What gets traced

Each database operation creates a span with:

* Span name: the SQL statement (truncated)
* @db.system@, @db.statement@
* @db.operation.name@ when detectable
* Span kind: @Client@

Note: source-location (@code.*@) attributes are intentionally not captured
because the spans originate from Persistent's internal hooks, not from your
application code.
-}
module OpenTelemetry.Instrumentation.Persistent (
  wrapSqlBackend,
  wrapSqlBackend',

  -- * Span naming helpers (exported for testing)
  extractSqlOperation,
  dbSpanName,
  lookupDbNamespace,
) where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Acquire.Internal
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vault.Strict as Vault
import Data.Word (Word64)
import Database.Persist.Sql (SqlReadBackend, SqlWriteBackend, Statement (..))
import Database.Persist.SqlBackend.Internal.IsolationLevel (IsolationLevel (..))
import Database.Persist.SqlBackend (MkSqlBackendArgs (connRDBMS), emptySqlBackendHooks, getConnVault, getRDBMS, modifyConnVault, setConnHooks)
import Database.Persist.SqlBackend.Internal
import OpenTelemetry.Attributes (Attribute (..), Attributes)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Attributes.Map (AttributeMap)
import OpenTelemetry.Common
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal (adjustContext, getContext)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Monad (MonadTracer (..))
import System.IO.Unsafe (unsafePerformIO)
import UnliftIO.Exception


{-
Design notes:

In some OTel export destinations like Honeycomb, the cost is per-span. Consquently, we want to minimize the number of spans we create. In particular, we want to avoid creating a span for every query, since they add up cost-wise.

However, we also want to capture transactions as spans. Therefore, for pool acquisitions we track the time between trying to acquire the connection and the time the connection is obtained as an attribute on the initial span.
-}

instance {-# OVERLAPS #-} (MonadTracer m) => MonadTracer (ReaderT SqlBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer


instance {-# OVERLAPS #-} (MonadTracer m) => MonadTracer (ReaderT SqlReadBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer


instance {-# OVERLAPS #-} (MonadTracer m) => MonadTracer (ReaderT SqlWriteBackend m) where
  getTracer = lift OpenTelemetry.Trace.Monad.getTracer


originalConnectionKey :: Vault.Key SqlBackend
originalConnectionKey = unsafePerformIO Vault.newKey
{-# NOINLINE originalConnectionKey #-}


insertOriginalConnection :: SqlBackend -> SqlBackend -> SqlBackend
insertOriginalConnection conn original = modifyConnVault (Vault.insert originalConnectionKey original) conn


lookupOriginalConnection :: SqlBackend -> Maybe SqlBackend
lookupOriginalConnection = Vault.lookup originalConnectionKey . getConnVault


{- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
 so that queries are tracked appropriately in the tracing hierarchy.
-}
wrapSqlBackend
  :: MonadIO m
  => AttributeMap
  -- ^ Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  -> SqlBackend
  -> m SqlBackend
wrapSqlBackend attrs conn_ = do
  tp <- getGlobalTracerProvider
  wrapSqlBackend' tp attrs conn_


{- | Wrap a 'SqlBackend' with appropriate tracing context and attributes
so that queries are tracked appropriately in the tracing hierarchy.
-}
wrapSqlBackend'
  :: MonadIO m
  => TracerProvider
  -> AttributeMap
  -- ^ Attributes that are specific to providers like MySQL, PostgreSQL, etc.
  -> SqlBackend
  -> m SqlBackend
wrapSqlBackend' tp attrs conn_ = do
  let conn = Data.Maybe.fromMaybe conn_ (lookupOriginalConnection conn_)
  {- A connection is acquired when the connection pool is asked for a connection. The runSqlPool function in Persistent then
    immediately begins a transaction and ensures the transaction is committed or rolled back. Since we want to capture the
    transaction as a span, we have to use track the current Span in flight. We do this because we can't hand off
    the Span between connBegin/connCommit/connRollback as return values.
  -}
  connParentSpan <- liftIO $ newIORef Nothing
  connSpanInFlight <- liftIO $ newIORef Nothing
  dbSemOpt <- liftIO $ databaseOption <$> getSemanticsOptions
  let t = makeTracer tp $detectInstrumentationLibrary tracerOptions
      dbNamespace = lookupDbNamespace dbSemOpt attrs
      rdbms = getRDBMS conn
      dbSystemAttrs = case dbSemOpt of
        Stable -> H.fromList [(unkey SC.db_system_name, toAttribute rdbms)]
        StableAndOld ->
          H.fromList
            [ (unkey SC.db_system_name, toAttribute rdbms)
            , (unkey SC.db_system, toAttribute rdbms)
            ]
        Old -> H.fromList [(unkey SC.db_system, toAttribute rdbms)]
      queryAttrs sql =
        let v = toAttribute sql
            opAttrs = case extractSqlOperation sql of
              Just op -> case dbSemOpt of
                Stable -> [(unkey SC.db_operation_name, toAttribute op)]
                StableAndOld -> [(unkey SC.db_operation_name, toAttribute op)]
                Old -> []
              Nothing -> []
        in H.union (H.fromList opAttrs) $ case dbSemOpt of
            Stable -> H.insert (unkey SC.db_query_text) v attrs
            StableAndOld -> H.insert (unkey SC.db_query_text) v $ H.insert (unkey SC.db_statement) v attrs
            Old -> H.insert (unkey SC.db_statement) v attrs
      spanName sql = dbSpanName (extractSqlOperation sql) dbNamespace
      -- We use createSpanWithoutCallStack/inSpan'' because these spans are created
      -- from persistent's internal hooks, not from user code. Using the callstack
      -- variants would capture this instrumentation library's source location,
      -- not the user's application code callsite.
  let hooks =
        emptySqlBackendHooks
          { hookGetStatement = \conn sql stmt -> do
              pure $
                Statement
                  { stmtQuery = \ps -> do
                      ctxt <- getContext
                      let spanCreator = do
                            s <-
                              createSpanWithoutCallStack
                                t
                                ctxt
                                (spanName sql)
                                (defaultSpanArguments {kind = Client, attributes = queryAttrs sql})
                            adjustContext (insertSpan s)
                            pure (lookupSpan ctxt, s)
                          spanCleanup (parent, s) = do
                            s `endSpan` Nothing
                            adjustContext $ \ctx ->
                              maybe (removeSpan ctx) (`insertSpan` ctx) parent

                      (p, child) <- mkAcquire spanCreator spanCleanup

                      addAttributes child dbSystemAttrs
                      case stmtQuery stmt ps of
                        Acquire stmtQueryAcquireF -> Acquire $ \f ->
                          handleAny
                            ( \(SomeException err) -> do
                                recordException child [(unkey SC.exception_escaped, toAttribute True)] Nothing err
                                endSpan child Nothing
                                throwIO err
                            )
                            (stmtQueryAcquireF f)
                  , stmtExecute = \ps -> do
                      inSpan'' t (spanName sql) (defaultSpanArguments {kind = Client, attributes = queryAttrs sql}) $ \s -> do
                        addAttributes s dbSystemAttrs
                        stmtExecute stmt ps
                  , stmtReset = stmtReset stmt
                  , stmtFinalize = stmtFinalize stmt
                  }
          }

      conn' =
        conn
          { connHooks = hooks
          , connBegin = \f mIso -> do
              ctxt <- getContext
              s <- createSpanWithoutCallStack t ctxt (dbSpanName (Just "TRANSACTION") dbNamespace) (defaultSpanArguments {kind = Client, attributes = attrs})
              let isoAttrs = case mIso of
                    Nothing -> H.empty
                    Just iso ->
                      H.singleton "db.transaction.isolation" $ toAttribute $ case iso of
                        ReadUncommitted -> "read uncommitted" :: Text
                        ReadCommitted -> "read committed"
                        RepeatableRead -> "repeatable read"
                        Serializable -> "serializable"
              addAttributes s (dbSystemAttrs `H.union` isoAttrs)
              writeIORef connSpanInFlight (Just s)
              writeIORef connParentSpan (lookupSpan ctxt)
              adjustContext (insertSpan s)
              connBegin conn f mIso
          , connCommit = \f -> do
              spanInFlight <- readIORef connSpanInFlight
              parentSpan <- readIORef connParentSpan
              let act = do
                    Timestamp nsStart <- getTimestamp
                    result <- tryAny $ connCommit conn f
                    Timestamp nsEnd <- getTimestamp
                    forM_ spanInFlight $ \s -> do
                      let !durationMicros = fromIntegral @Word64 @Int ((nsEnd - nsStart) `div` 1000)
                      addAttributes
                        s
                        [ ("db.transaction.outcome", toAttribute ("committed" :: Text))
                        , ("db.transaction.commit_duration_ns", toAttribute durationMicros)
                        ]
                      endSpan s Nothing
                      case result of
                        Left (SomeException err) -> do
                          recordException s [(unkey SC.exception_escaped, toAttribute True)] Nothing err
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
                    Timestamp nsStart <- getTimestamp
                    result <- tryAny $ connRollback conn f
                    e@(Timestamp _) <- getTimestamp
                    forM_ spanInFlight $ \s -> do
                      let !durationMicros = fromIntegral @Word64 @Int ((timestampToNanoseconds e - nsStart) `div` 1000)
                      addAttributes
                        s
                        [ ("db.transaction.outcome", toAttribute ("rolled back" :: Text))
                        , ("db.transaction.commit_duration_microseconds", toAttribute durationMicros)
                        ]
                      endSpan s (Just e)
                      case result of
                        Left (SomeException err) -> do
                          recordException s [(unkey SC.exception_escaped, toAttribute True)] Nothing err
                          throwIO err
                        Right _ -> pure ()
              act `finally` do
                adjustContext $ \ctx ->
                  maybe (removeSpan ctx) (`insertSpan` ctx) parentSpan
                forM_ spanInFlight $ \s -> endSpan s Nothing
          , -- Known limitation: connClose spans are not emitted when
            -- persistent's connection pool wraps the underlying connection,
            -- since the pool manages connection lifecycle independently.
            connClose = do
              inSpan'' t (dbSpanName (Just "CLOSE") dbNamespace) (defaultSpanArguments {kind = Client, attributes = attrs}) $ \s -> do
                addAttributes s dbSystemAttrs
                connClose conn
          }
  pure $ insertOriginalConnection conn' conn


extractSqlOperation :: Text -> Maybe Text
extractSqlOperation sql =
  let trimmed = T.dropWhile (\c -> c == ' ' || c == '\n' || c == '\r' || c == '\t') sql
      keyword = T.takeWhile (\c -> c /= ' ' && c /= '\n' && c /= '\r' && c /= '\t' && c /= '(') trimmed
  in if T.null keyword
      then Nothing
      else Just $ T.toUpper keyword


lookupDbNamespace :: StabilityOpt -> AttributeMap -> Maybe Text
lookupDbNamespace opt attrMap =
  let tryKey k = case H.lookup k attrMap of
        Just (AttributeValue (TextAttribute v)) -> Just v
        _ -> Nothing
  in case opt of
      Stable -> tryKey (unkey SC.db_namespace)
      StableAndOld -> tryKey (unkey SC.db_namespace) <|> tryKey (unkey SC.db_name)
      Old -> tryKey (unkey SC.db_name)
  where
    Nothing <|> b = b
    a <|> _ = a


dbSpanName :: Maybe Text -> Maybe Text -> Text
dbSpanName (Just op) (Just ns) = op <> " " <> ns
dbSpanName (Just op) Nothing = op
dbSpanName Nothing (Just ns) = ns
dbSpanName Nothing Nothing = "DB"
