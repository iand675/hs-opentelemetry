{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Minimal where

import qualified Data.ByteString.Lazy as L
import Control.Monad.IO.Class
import Data.Text (Text, pack)
import Data.Text.Encoding (decodeUtf8)
import Network.HTTP.Client
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Exporters.Handle
import OpenTelemetry.Exporters.Honeycomb
import OpenTelemetry.Context (Context, HasContext(..))
import qualified OpenTelemetry.Context as Context
import Lens.Micro (lens)
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Monad
import OpenTelemetry.Trace.SpanProcessors.Simple
import OpenTelemetry.Instrumentation.HttpClient
import OpenTelemetry.Instrumentation.Yesod
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

-- | This is my data type. There are many like it, but this one is mine.
data Minimal = Minimal
  { minimalTracerProvider :: TracerProvider
  , minimalContext :: Context
  , minimalPropagator :: Propagator Context RequestHeaders ResponseHeaders
  }

mkYesod "Minimal" [parseRoutes|
    / RootR GET
    /api ApiR GET
|]

instance Yesod Minimal where
  yesodMiddleware m = do
    openTelemetryYesodMiddleware $ defaultYesodMiddleware m
  errorHandler err = do
    selectRep $ do
      provideRep (pure $ pack $ show err)

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
  resp <- inSpan "http.request" emptySpanArguments $ \span -> do
    req <- parseUrl "http://localhost:3000/api"
    ctxt <- getContext
    req' <- instrumentRequest propagator ctxt req
    realResponse <- liftIO $ httpLbs req' m
    _ <- instrumentResponse propagator ctxt realResponse
    pure realResponse
  pure $ decodeUtf8 $ L.toStrict $ responseBody resp

getApiR :: Handler Text
getApiR = do
  pure "Hello, world!"

main :: IO ()
main = do
  client <- initializeHoneycomb $ config "0a3aa320cb317551021ec8abc221fbc7" "testing-client"
  processor <- simpleProcessor $ SimpleProcessorConfig
    { exporter = makeHoneycombExporter client "minimal"
    }

  tp <- createTracerProvider
    [ processor
    ]
    (TracerProviderOptions Nothing)

  let httpPropagators = mconcat
        [ w3cBaggagePropagator
        , w3cTraceContextPropagator
        ]

  waiApp <- toWaiApp $ Minimal tp Context.empty httpPropagators
  openTelemetryWaiMiddleware <- newOpenTelemetryWaiMiddleware tp httpPropagators

  run 3000 $ openTelemetryWaiMiddleware waiApp
