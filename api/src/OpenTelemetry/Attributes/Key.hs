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
  Key (..),
  forget,
) where

import Data.String (IsString (..))
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)
import OpenTelemetry.Attributes.Attribute (Attribute)


{- | A 'Key' is a name for an attribute. The type parameter sets the type of the
attribute the key should be associated with. This is useful for standardising
attribute keys, since we can define both the key and the type of value it is
intended to record.

For example, we might define:

@
-- See https://opentelemetry.io/docs/specs/semconv/attributes-registry/server/
serverPortKey :: Key Int
serverPortKey = "server.port"
@
-}
newtype Key a = Key {unkey :: Text} deriving stock (Show, Eq, Ord, Generic)


-- | Raise an error if the string is empty.
instance IsString (Key a) where
  fromString "" = error "Key cannot be empty"
  fromString s = Key $ T.pack s


forget :: Key a -> Key Attribute
forget = Key . unkey
