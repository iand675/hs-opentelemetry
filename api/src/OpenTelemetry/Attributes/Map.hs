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
Module      :  OpenTelemetry.Attributes.Attribute
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Description :  Key-value pair metadata used in 'OpenTelemetry.Trace.Span's, 'OpenTelemetry.Trace.Link's, and 'OpenTelemetry.Trace.Event's
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
  Key (Key),
 )
import Prelude hiding (lookup, map)


type AttributeMap = H.HashMap Text Attribute


insertByKey :: ToAttribute a => Key a -> a -> AttributeMap -> AttributeMap
insertByKey (Key !k) !v = H.insert k $ toAttribute v


insertAttributeByKey :: Key a -> Attribute -> AttributeMap -> AttributeMap
insertAttributeByKey (Key !k) !v = H.insert k v


lookupByKey :: FromAttribute a => Key a -> AttributeMap -> Maybe a
lookupByKey (Key k) attributes = H.lookup k attributes >>= fromAttribute


lookupAttributeByKey :: Key a -> AttributeMap -> Maybe Attribute
lookupAttributeByKey (Key k) = H.lookup k
