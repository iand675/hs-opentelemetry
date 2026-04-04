{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ViewPatterns #-}

module TestApp.ApiSub (
  module TestApp.ApiSub.Routes,
) where

import TestApp.ApiSub.Routes
import Yesod.Core


getApiSubHomeR :: SubHandlerFor ApiSub master Html
getApiSubHomeR = liftHandler $ return ""


getApiSubItemR :: Int -> SubHandlerFor ApiSub master Html
getApiSubItemR _ = liftHandler $ return ""


instance Yesod master => YesodSubDispatch ApiSub master where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesApiSub)
