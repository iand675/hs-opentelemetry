{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveLift #-}
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
module OpenTelemetry.Attributes.Attribute (
  Attribute (..),
  ToAttribute (..),
  FromAttribute (..),
  PrimitiveAttribute (..),
  ToPrimitiveAttribute (..),
  FromPrimitiveAttribute (..),
) where

import Data.Data (Data)
import Data.Hashable (Hashable)
import Data.Int (Int64)
import qualified Data.List as L
import Data.String (IsString (..))
import Data.Text (Text)
import GHC.Generics (Generic)
import qualified Language.Haskell.TH.Syntax as TH
import Prelude hiding (lookup, map)


-- | Convert a Haskell value to a 'PrimitiveAttribute' value.
class ToPrimitiveAttribute a where
  toPrimitiveAttribute :: a -> PrimitiveAttribute


class FromPrimitiveAttribute a where
  fromPrimitiveAttribute :: PrimitiveAttribute -> Maybe a


{- | An attribute represents user-provided metadata about a span, link, or event.

 Telemetry tools may use this data to support high-cardinality querying, visualization
 in waterfall diagrams, trace sampling decisions, and more.
-}
data Attribute
  = -- | An attribute representing a single primitive value
    AttributeValue PrimitiveAttribute
  | -- | An attribute representing an array of primitive values.
    --
    -- All values in the array MUST be of the same primitive attribute type.
    AttributeArray [PrimitiveAttribute]
  deriving stock (Read, Show, Eq, Ord, Data, Generic, TH.Lift)
  deriving anyclass (Hashable)


{- | Create a `TextAttribute` from the string value.

 @since 0.0.2.1
-}
instance IsString PrimitiveAttribute where
  fromString = TextAttribute . fromString


{- | Create a `TextAttribute` from the string value.

 @since 0.0.2.1
-}
instance IsString Attribute where
  fromString = AttributeValue . fromString


data PrimitiveAttribute
  = TextAttribute Text
  | BoolAttribute Bool
  | DoubleAttribute Double
  | IntAttribute Int64
  deriving stock (Read, Show, Eq, Ord, Data, Generic, TH.Lift)
  deriving anyclass (Hashable)


{- | Convert a Haskell value to an 'Attribute' value.

 For most values, you can define an instance of 'ToPrimitiveAttribute' and use the default 'toAttribute' implementation:

 @

 data Foo = Foo

 instance ToPrimitiveAttribute Foo where
   toPrimitiveAttribute Foo = TextAttribute "Foo"
 instance ToAttribute foo

 @
-}
class ToAttribute a where
  toAttribute :: a -> Attribute
  default toAttribute :: (ToPrimitiveAttribute a) => a -> Attribute
  toAttribute = AttributeValue . toPrimitiveAttribute


class FromAttribute a where
  fromAttribute :: Attribute -> Maybe a
  default fromAttribute :: (FromPrimitiveAttribute a) => Attribute -> Maybe a
  fromAttribute (AttributeValue v) = fromPrimitiveAttribute v
  fromAttribute _ = Nothing


instance ToPrimitiveAttribute PrimitiveAttribute where
  toPrimitiveAttribute = id


instance FromPrimitiveAttribute PrimitiveAttribute where
  fromPrimitiveAttribute = Just


instance ToAttribute PrimitiveAttribute where
  toAttribute = AttributeValue


instance FromAttribute PrimitiveAttribute where
  fromAttribute (AttributeValue v) = Just v
  fromAttribute _ = Nothing


instance ToPrimitiveAttribute Text where
  toPrimitiveAttribute = TextAttribute


instance FromPrimitiveAttribute Text where
  fromPrimitiveAttribute (TextAttribute v) = Just v
  fromPrimitiveAttribute _ = Nothing


instance ToAttribute Text


instance FromAttribute Text


instance ToPrimitiveAttribute Bool where
  toPrimitiveAttribute = BoolAttribute


instance FromPrimitiveAttribute Bool where
  fromPrimitiveAttribute (BoolAttribute v) = Just v
  fromPrimitiveAttribute _ = Nothing


instance ToAttribute Bool


instance FromAttribute Bool


instance ToPrimitiveAttribute Double where
  toPrimitiveAttribute = DoubleAttribute


instance FromPrimitiveAttribute Double where
  fromPrimitiveAttribute (DoubleAttribute v) = Just v
  fromPrimitiveAttribute _ = Nothing


instance ToAttribute Double


instance FromAttribute Double


instance ToPrimitiveAttribute Int64 where
  toPrimitiveAttribute = IntAttribute


instance FromPrimitiveAttribute Int64 where
  fromPrimitiveAttribute (IntAttribute v) = Just v
  fromPrimitiveAttribute _ = Nothing


instance ToAttribute Int64


instance FromAttribute Int64


instance ToPrimitiveAttribute Int where
  toPrimitiveAttribute = IntAttribute . fromIntegral


instance FromPrimitiveAttribute Int where
  fromPrimitiveAttribute (IntAttribute v) = Just $ fromIntegral v
  fromPrimitiveAttribute _ = Nothing


instance ToAttribute Int


instance FromAttribute Int


instance ToAttribute Attribute where
  toAttribute = id


instance FromAttribute Attribute where
  fromAttribute = Just


instance (ToPrimitiveAttribute a) => ToAttribute [a] where
  toAttribute = AttributeArray . L.map toPrimitiveAttribute


instance (FromPrimitiveAttribute a) => FromAttribute [a] where
  fromAttribute (AttributeArray arr) = traverse fromPrimitiveAttribute arr
  fromAttribute _ = Nothing
