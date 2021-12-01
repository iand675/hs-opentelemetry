{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Minimal where

import qualified Data.ByteString.Lazy as L
import Conduit
import Control.Exception (bracket)
import Data.Conduit.List as CL
import Control.Monad.IO.Class
import Control.Monad.Logger
import Data.Pool (Pool, withResource)
import Database.Persist.Postgresql
import Database.Persist.SqlBackend
import Database.Persist.Sql
import Database.Persist.Sql.Raw.QQ
import Data.Text (Text, pack)
import Data.Text.Encoding (decodeUtf8)
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Context (Context, HasContext(..))
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import Lens.Micro (lens)
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Monad
import OpenTelemetry.Instrumentation.HttpClient
import OpenTelemetry.Instrumentation.Yesod
import OpenTelemetry.Instrumentation.Persistent
import OpenTelemetry.Instrumentation.Wai
import OpenTelemetry.Propagator.W3CBaggage
import OpenTelemetry.Propagator.W3CTraceContext
import Yesod.Core
  ( RenderRoute (..)
  , Yesod(..)
  , mkYesod
  , defaultYesodMiddleware
  , parseRoutes
  , toWaiApp
  , getYesod
  )
import Yesod.Core.Handler
import Yesod.Persist
import OpenTelemetry.Exporter.OTLP
import OpenTelemetry.Processor.Batch
import OpenTelemetry.Instrumentation.PostgresqlSimple (staticConnectionAttributes)

-- | This is my data type. There are many like it, but this one is mine.
data Minimal = Minimal
  { minimalConnectionPool :: Pool SqlBackend
  }

$( do
    let routes = [parseRoutes|
          / RootR GET
          /api ApiR GET
        |]
    Prelude.concat <$> Prelude.sequence 
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
    inSpan "yesod.runDB" defaultSpanArguments $ do
      ctxt <- getContext
      app <- getYesod
      runSqlPoolWithExtensibleHooks m (minimalConnectionPool app) Nothing $ defaultSqlPoolHooks
        { alterBackend = \conn -> do
            -- TODO, could probably not do this on each runDB call.
            staticAttrs <- case getSimpleConn conn of
              Nothing -> pure []
              Just pgConn -> staticConnectionAttributes pgConn
            connWithHooks <- wrapSqlBackend ctxt staticAttrs conn
            pure $ insertConnectionContext ctxt connWithHooks
        }

getRootR :: Handler Text
getRootR = do
  -- Wouldn't put this here in a real app
  m <- liftIO $ newManager defaultManagerSettings
  let httpConfig = httpClientInstrumentationConfig
  req <- parseUrlThrow "http://localhost:3000/api"
  resp <- httpLbs httpConfig req m
  pure $ decodeUtf8 $ L.toStrict $ responseBody resp

getApiR :: Handler Text
getApiR = do
  inSpan "annotatedFunction" defaultSpanArguments $ do
    res <- runDB $ [sqlQQ|select 1|]
    case res of
      [Single (1 :: Int)] -> pure ()
      _ -> error "sad"
  pure "Hello, world!"

main :: IO ()
main = do
  bracket 
    initializeGlobalTracerProvider 
    shutdownTracerProvider $ \_ -> do
      runNoLoggingT $ withPostgresqlPool "host=localhost dbname=otel" 5 $ \pool -> liftIO $ do
        waiApp <- toWaiApp $ Minimal pool
        openTelemetryWaiMiddleware <- newOpenTelemetryWaiMiddleware

        run 3000 $ openTelemetryWaiMiddleware waiApp
