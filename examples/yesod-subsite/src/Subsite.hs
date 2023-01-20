{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

-- an option for Template Haskell stage restriction
{-# OPTIONS_GHC -Wno-orphans #-}

module Subsite (
  module Subsite.Data,
) where

import Subsite.Data (
  Subsite(Subsite),
  getSubHomeR,
  getFooR,
  routeToPattern,
  routeToRenderer,
  resourcesSubsite,
  Route(FooR,SubHomeR))
import Yesod.Core
    ( mkYesodSubDispatch, YesodSubDispatch(yesodSubDispatch   ),  )


instance YesodSubDispatch Subsite master where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesSubsite)
