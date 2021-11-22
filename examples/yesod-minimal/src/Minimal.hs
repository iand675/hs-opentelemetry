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
import OpenTelemetry.Exporters.Handle
import OpenTelemetry.Context (Context, HasContext(..))
import qualified OpenTelemetry.Context as Context
import Lens.Micro (lens)
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Monad
import OpenTelemetry.Instrumentation.HttpClient
import OpenTelemetry.Instrumentation.Yesod
import OpenTelemetry.Instrumentation.Persistent
import OpenTelemetry.Instrumentation.Wai
import OpenTelemetry.Propagators
import OpenTelemetry.Propagators.W3CBaggage
import OpenTelemetry.Propagators.W3CTraceContext
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
import OpenTelemetry.Exporters.OTLP
import OpenTelemetry.Trace.SpanProcessors.Batch

-- | This is my data type. There are many like it, but this one is mine.
data Minimal = Minimal
  { minimalTracerProvider :: TracerProvider
  , minimalContext :: Context
  , minimalPropagator :: Propagator Context RequestHeaders ResponseHeaders
  , minimalConnectionPool :: Pool SqlBackend
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
    inSpan "yesod.runDB" emptySpanArguments $ \_ -> do
      app <- getYesod
      runSqlPoolWithExtensibleHooks m (minimalConnectionPool app) Nothing $ defaultSqlPoolHooks
        { alterBackend = \conn -> do
            ctxt <- getContext
            connWithHooks <- wrapSqlBackend (minimalTracerProvider app) ctxt conn
            pure $ insertConnectionContext (minimalContext app) connWithHooks
        }

instance HasTracerProvider Minimal where
  tracerProviderL = lens
    minimalTracerProvider
    (\m tp -> m { minimalTracerProvider = tp })

instance HasContext Minimal where
  contextL = lens
    minimalContext
    (\m c -> m { minimalContext = c })

getRootR :: Handler Text
getRootR = do
  -- Wouldn't put this here in a real app
  m <- liftIO $ newManager defaultManagerSettings
  propagator <- minimalPropagator <$> getYesod
  let httpConfig = httpClientInstrumentationConfig
        { httpClientPropagator = propagator
        }
  req <- parseUrlThrow "http://localhost:3000/api"
  resp <- httpLbs httpConfig req m
  pure $ decodeUtf8 $ L.toStrict $ responseBody resp

getApiR :: Handler Text
getApiR = do
  inSpan "annotatedFunction" emptySpanArguments $ \_ -> do
    res <- runDB $ [sqlQQ|select 1|]
    case res of
      [Single (1 :: Int)] -> pure ()
      _ -> error "sad"
  pure "Hello, world!"

main :: IO ()
main = do
  otlpExporterConf <- loadExporterEnvironmentVariables
  rs <- builtInResources
  otlpExporter_ <- otlpExporter rs otlpExporterConf
  processor <- batchProcessor $ batchTimeoutConfig otlpExporter_

  tp <- createTracerProvider
    [ processor
    ]
    ((emptyTracerProviderOptions :: TracerProviderOptions Nothing)
      { tracerProviderOptionsResources = rs
      })

  let httpPropagators = mconcat
        [ w3cBaggagePropagator
        , w3cTraceContextPropagator
        ]

  runNoLoggingT $ withPostgresqlPool "host=localhost dbname=otel" 5 $ \pool -> liftIO $ do
    waiApp <- toWaiApp $ Minimal tp Context.empty httpPropagators pool
    openTelemetryWaiMiddleware <- newOpenTelemetryWaiMiddleware tp httpPropagators

    run 3000 $ openTelemetryWaiMiddleware waiApp
