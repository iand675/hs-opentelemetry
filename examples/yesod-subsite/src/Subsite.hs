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
  Route (FooR, SubHomeR),
  Subsite (Subsite),
  getFooR,
  getSubHomeR,
  resourcesSubsite,
  routeToPattern,
  routeToRenderer,
 )
import Yesod.Core (
  YesodSubDispatch (yesodSubDispatch),
  mkYesodSubDispatch,
 )


instance YesodSubDispatch Subsite master where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesSubsite)
