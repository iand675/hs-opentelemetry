{-# LANGUAGE DataKinds #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
-- an option for Template Haskell
{-# OPTIONS_GHC -Wno-unused-top-binds #-}

import qualified Data.Map as M
import Data.Text (Text, pack)
import Network.Wai.Handler.Warp (run)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware')
import OpenTelemetry.Instrumentation.Yesod (
  RouteRenderer (RouteRenderer),
  YesodOpenTelemetryTrace (getTracerProvider),
  mkRouteToPattern,
  mkRouteToRenderer,
  openTelemetryYesodMiddleware,
 )
import OpenTelemetry.Trace (
  TracerProvider,
  initializeTracerProvider,
  shutdownTracerProvider,
 )
import Subsite (Subsite (Subsite))
import qualified Subsite
import UnliftIO (bracket)
import Yesod.Core (
  RenderRoute (renderRoute),
  Yesod (errorHandler, yesodMiddleware),
  defaultYesodMiddleware,
  mkYesod,
  parseRoutes,
  toWaiApp,
 )
import Yesod.Core.Handler (provideRep, selectRep)
import Yesod.Routes.TH.Types (ResourceTree)


-- | This is my data type. There are many like it, but this one is mine.
data Site = Site
  { tracerProvider :: TracerProvider
  , subsite :: Subsite
  }


$( do
    let routes :: [ResourceTree String]
        routes =
          [parseRoutes|
          / RootR GET
          /subsite SubsiteR Subsite subsite
        |]
    concat
      <$> sequence
        [ mkRouteToRenderer ''Site (M.fromList [("Subsite", [|Subsite.routeToRenderer|])]) routes
        , mkRouteToPattern ''Site (M.fromList [("Subsite", [|Subsite.routeToPattern|])]) routes
        , mkYesod "Site" routes
        ]
 )


instance Yesod Site where
  yesodMiddleware m = openTelemetryYesodMiddleware (RouteRenderer routeToRenderer routeToPattern) $ defaultYesodMiddleware m
  errorHandler err = selectRep $ provideRep $ pure $ pack $ show err


instance YesodOpenTelemetryTrace Site where
  getTracerProvider = tracerProvider


getRootR :: Handler Text
getRootR = pure "GET /"


main :: IO ()
main = do
  bracket
    initializeTracerProvider
    shutdownTracerProvider
    $ \tp -> do
      waiApp <- toWaiApp $ Site tp Subsite
      let openTelemetryWaiMiddleware = newOpenTelemetryWaiMiddleware' tp
      run 3000 $ openTelemetryWaiMiddleware waiApp
