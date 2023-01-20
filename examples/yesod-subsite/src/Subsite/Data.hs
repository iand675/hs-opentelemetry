{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Subsite.Data (
  Subsite (Subsite),
  getSubHomeR,
  getFooR,
  routeToPattern,
  routeToRenderer,
  resourcesSubsite,
  Route (FooR, SubHomeR),
) where

import Data.Text (Text)
import OpenTelemetry.Instrumentation.Yesod (
  mkRouteToPattern,
  mkRouteToRenderer,
 )
import Yesod.Core (
  RenderRoute (renderRoute),
  SubHandlerFor,
  mkYesodSubData,
  parseRoutes,
 )
import Yesod.Core.Types (Route)


data Subsite = Subsite


$( do
    let routes =
          [parseRoutes|
          / SubHomeR GET
          /foo FooR GET
        |]
    concat
      <$> sequence
        [ mkRouteToRenderer ''Subsite mempty routes
        , mkRouteToPattern ''Subsite mempty routes
        , mkYesodSubData "Subsite" routes
        ]
 )


getSubHomeR :: SubHandlerFor Subsite master Text
getSubHomeR = pure "GET /subsite"


getFooR :: SubHandlerFor Subsite master Text
getFooR = pure "GET /subsite/foo"
