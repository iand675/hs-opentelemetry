{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}

{- |
Module      :  OpenTelemetry.Attributes.Key
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Description :  Key-value pair metadata used in 'OpenTelemetry.Trace.Span's, 'OpenTelemetry.Trace.Link's, and 'OpenTelemetry.Trace.Event's
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Attributes.Key (
  AttributeKey (..),
  forget,
) where

import Data.String (IsString (..))
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)
import OpenTelemetry.Attributes.Attribute (Attribute)


{- | A 'AttributeKey' is a name for an attribute. The type parameter sets the type of the
attribute the key should be associated with. This is useful for standardising
attribute keys, since we can define both the key and the type of value it is
intended to record.

For example, we might define:

@
-- See https://opentelemetry.io/docs/specs/semconv/attributes-registry/server/
serverPortKey :: AttributeKey Int
serverPortKey = "server.port"
@
-}
newtype AttributeKey a = AttributeKey {unkey :: Text} deriving stock (Show, Eq, Ord, Generic)


-- | Raise an error if the string is empty.
instance IsString (AttributeKey a) where
  fromString "" = error "AttributeKey cannot be empty"
  fromString s = AttributeKey $ T.pack s


forget :: AttributeKey a -> AttributeKey Attribute
forget = AttributeKey . unkey
