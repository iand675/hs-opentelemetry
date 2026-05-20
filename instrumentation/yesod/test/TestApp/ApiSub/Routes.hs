{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ViewPatterns #-}

module TestApp.ApiSub.Routes where

import Yesod.Core


data ApiSub = ApiSub


mkYesodSubData
  "ApiSub"
  [parseRoutes|
/ ApiSubHomeR GET
/item/#Int ApiSubItemR GET
|]
