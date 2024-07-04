{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Minimal where

import Conduit
import Control.Monad.IO.Class
import Control.Monad.Logger
import qualified Data.ByteString.Lazy as L
import Data.Conduit.List as CL
import Data.Pool (Pool, withResource)
import Data.Text (Text, pack)
import Data.Text.Encoding (decodeUtf8)
import Database.Persist.Postgresql
import Database.Persist.Sql
import Database.Persist.Sql.Raw.QQ
import Database.Persist.SqlBackend
import Database.Persist.SqlBackend.SqlPoolHooks
import GHC.Stack
import Lens.Micro (lens)
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Context (Context, HasContext (..))
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Instrumentation.HttpClient
import OpenTelemetry.Instrumentation.Persistent
import OpenTelemetry.Instrumentation.PostgresqlSimple (staticConnectionAttributes)
import OpenTelemetry.Instrumentation.Wai
import OpenTelemetry.Instrumentation.Yesod
import OpenTelemetry.Propagator.W3CBaggage
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.SpanExporter.OTLP
import OpenTelemetry.SpanProcessor.Batch
import OpenTelemetry.Trace hiding (inSpan, inSpan', inSpan'')
import OpenTelemetry.Trace.Monad
import UnliftIO hiding (Handler)
import Yesod.Core (
  RenderRoute (..),
  Yesod (..),
  defaultYesodMiddleware,
  getYesod,
  mkYesod,
  parseRoutes,
  toWaiApp,
 )
import Yesod.Core.Handler
import Yesod.Persist


-- | This is my data type. There are many like it, but this one is mine.
data Minimal = Minimal
  { minimalConnectionPool :: Pool SqlBackend
  }


$( do
    let routes =
          [parseRoutes|
          / RootR GET
          /api ApiR GET
        |]
    Prelude.concat
      <$> Prelude.sequence
        [ mkRouteToRenderer ''Minimal routes
        , mkRouteToPattern ''Minimal routes
        , mkYesod "Minimal" routes
        ]
 )


instance Yesod Minimal where
  yesodMiddleware m = do
    openTelemetryYesodMiddleware (RouteRenderer routeToRenderer routeToPattern) $ defaultYesodMiddleware m
  errorHandler err = do
    selectRep $ do
      provideRep (pure $ pack $ show err)


instance YesodPersist Minimal where
  type YesodPersistBackend Minimal = SqlBackend
  runDB m = do
    app <- getYesod
    runSqlPoolWithExtensibleHooks m (minimalConnectionPool app) Nothing $
      setAlterBackend defaultSqlPoolHooks $ \conn -> do
        -- TODO, could probably not do this on each runDB call.
        staticAttrs <- case getSimpleConn conn of
          Nothing -> pure mempty
          Just pgConn -> staticConnectionAttributes pgConn
        wrapSqlBackend staticAttrs conn


getRootR :: (HasCallStack) => Handler Text
getRootR = do
  -- Wouldn't put this here in a real app
  m <- inSpan "initialize http manager" defaultSpanArguments $ do
    liftIO $ newManager defaultManagerSettings
  let httpConfig = httpClientInstrumentationConfig
  req <- parseUrlThrow "http://localhost:3000/api"
  resp <- httpLbs httpConfig req m
  pure $ decodeUtf8 $ L.toStrict $ responseBody resp


getApiR :: (HasCallStack) => Handler Text
getApiR = do
  inSpan "annotatedFunction" defaultSpanArguments $ do
    res <- runDB $ do
      res <-
        inSpan "hierarchy works inside runDB" defaultSpanArguments $
          [sqlQQ|select 1|]
      eResult <- try $ do
        inSpan "failed span" defaultSpanArguments $
          [executeQQ|raise 'I failed'|]
      liftIO $ case eResult of
        Left e -> print (e :: SomeException)
        Right _ -> pure ()
      pure res
    case res of
      [Single (1 :: Int)] -> pure ()
      _ -> error "sad"
  pure "Hello, world!"


main :: IO ()
main = do
  bracket
    initializeGlobalTracerProvider
    shutdownTracerProvider
    $ \_ -> do
      runNoLoggingT $ withPostgresqlPool "host=localhost dbname=otel" 5 $ \pool -> liftIO $ do
        waiApp <- toWaiApp $ Minimal pool
        openTelemetryWaiMiddleware <- newOpenTelemetryWaiMiddleware

        run 3000 $ openTelemetryWaiMiddleware waiApp
