{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Minimal where

import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import Network.HTTP.Simple
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Exporters.Handle
import OpenTelemetry.Trace
import OpenTelemetry.Trace.SpanProcessors.Simple
import OpenTelemetry.Instrumentation.HttpClient
import OpenTelemetry.Instrumentation.Yesod
import OpenTelemetry.Instrumentation.Wai
import OpenTelemetry.Propagators.W3CBaggage
import OpenTelemetry.Propagators.W3CTraceContext
import Yesod.Core
  ( RenderRoute (..)
  , Yesod(..)
  , mkYesod
  , defaultYesodMiddleware
  , parseRoutes
  , toWaiApp
  )

-- | This is my data type. There are many like it, but this one is mine.
data Minimal = Minimal

mkYesod "Minimal" [parseRoutes|
    / RootR GET
    /api ApiR GET
|]

instance Yesod Minimal where
  yesodMiddleware m = do
    openTelemetryYesodMiddleware $ defaultYesodMiddleware m

getRootR :: Handler Text
getRootR = do
  realResponse <- httpBS "http://localhost:3000/api"
  pure $ decodeUtf8 $ getResponseBody realResponse

getApiR :: Handler Text
getApiR = do
  pure "Hello, world!"

main :: IO ()
main = do
  processor <- simpleProcessor $ SimpleProcessorConfig
    { exporter = stdoutExporter defaultFormatter
    }

  setGlobalTracerProvider =<< 
    (
      createTracerProvider 
        [ processor
        ]
        (TracerProviderOptions Nothing)
    )

  waiApp <- toWaiApp Minimal

  let waiPropagators = mconcat 
        [ w3cBaggagePropagator
        , w3cTraceContextPropagator
        ]

  tp <- getGlobalTracerProvider

  openTelemetryWaiMiddleware <- newOpenTelemetryWaiMiddleware tp waiPropagators

  run 3000 $ openTelemetryWaiMiddleware waiApp
