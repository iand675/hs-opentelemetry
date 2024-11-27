{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE StrictData #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      :  OpenTelemetry.Attributes.Map
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Description :  Key-value pair metadata without limits
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Attributes.Map (
  AttributeMap,
  insertByKey,
  insertAttributeByKey,
  lookupByKey,
  lookupAttributeByKey,
  module H,
) where

import Data.HashMap.Strict as H
import Data.Text (Text)
import OpenTelemetry.Attributes.Attribute (
  Attribute,
  FromAttribute (fromAttribute),
  ToAttribute (toAttribute),
 )
import OpenTelemetry.Attributes.Key (
  AttributeKey (AttributeKey),
 )
import Prelude hiding (lookup, map)


type AttributeMap = H.HashMap Text Attribute


insertByKey :: ToAttribute a => AttributeKey a -> a -> AttributeMap -> AttributeMap
insertByKey (AttributeKey !k) !v = H.insert k $ toAttribute v


insertAttributeByKey :: AttributeKey a -> Attribute -> AttributeMap -> AttributeMap
insertAttributeByKey (AttributeKey !k) !v = H.insert k v


lookupByKey :: FromAttribute a => AttributeKey a -> AttributeMap -> Maybe a
lookupByKey (AttributeKey k) attributes = H.lookup k attributes >>= fromAttribute


lookupAttributeByKey :: AttributeKey a -> AttributeMap -> Maybe Attribute
lookupAttributeByKey (AttributeKey k) = H.lookup k
