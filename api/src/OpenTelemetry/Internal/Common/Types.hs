{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}

module OpenTelemetry.Internal.Common.Types (
  InstrumentationLibrary (..),
  AnyValue (..),
  ToValue (..),
) where

import Data.ByteString (ByteString)
import Data.Data (Data)
import qualified Data.HashMap.Strict as H
import Data.Hashable (Hashable)
import Data.Int (Int64)
import Data.String (IsString (fromString))
import Data.Text (Text)
import GHC.Generics (Generic)
import OpenTelemetry.Attributes (Attributes, emptyAttributes)


{- | An identifier for the library that provides the instrumentation for a given Instrumented Library.
 Instrumented Library and Instrumentation Library may be the same library if it has built-in OpenTelemetry instrumentation.

 The inspiration of the OpenTelemetry project is to make every library and application observable out of the box by having them call OpenTelemetry API directly.
 However, many libraries will not have such integration, and as such there is a need for a separate library which would inject such calls, using mechanisms such as wrapping interfaces,
 subscribing to library-specific callbacks, or translating existing telemetry into the OpenTelemetry model.

 A library that enables OpenTelemetry observability for another library is called an Instrumentation Library.

 An instrumentation library should be named to follow any naming conventions of the instrumented library (e.g. 'middleware' for a web framework).

 If there is no established name, the recommendation is to prefix packages with "hs-opentelemetry-instrumentation", followed by the instrumented library name itself.

 In general, you can initialize the instrumentation library like so:

 @

 import qualified Data.Text as T
 import Data.Version (showVersion)
 import OpenTelemetry.Attributes (emptyAttributes)
 import Paths_your_package_name (version)

 instrumentationLibrary :: InstrumentationLibrary
 instrumentationLibrary = InstrumentationLibrary
   { libraryName = "your_package_name"
   , libraryVersion = T.pack $ showVersion version
   , librarySchemaUrl = T.pack "" -- to specify a URL, refer to this documentation: https://opentelemetry.io/docs/specs/otel/schemas/#schema-url
   , libraryAttributes = emptyAttributes
   }

 @
-}
data InstrumentationLibrary = InstrumentationLibrary
  { libraryName :: {-# UNPACK #-} !Text
  -- ^ The name of the instrumentation library
  , libraryVersion :: {-# UNPACK #-} !Text
  -- ^ The version of the instrumented library
  , librarySchemaUrl :: {-# UNPACK #-} !Text
  , libraryAttributes :: Attributes
  }
  deriving (Ord, Eq, Generic, Show)


instance Hashable InstrumentationLibrary


instance IsString InstrumentationLibrary where
  fromString :: String -> InstrumentationLibrary
  fromString str = InstrumentationLibrary (fromString str) "" "" emptyAttributes


{- | An attribute represents user-provided metadata about a span, link, or event.

 'Any' values are used in place of 'Standard Attributes' in logs because third-party
 logs may not conform to the 'Standard Attribute' format.

 Telemetry tools may use this data to support high-cardinality querying, visualization
 in waterfall diagrams, trace sampling decisions, and more.
-}
data AnyValue
  = TextValue Text
  | BoolValue Bool
  | DoubleValue Double
  | IntValue Int64
  | ByteStringValue ByteString
  | ArrayValue [AnyValue]
  | HashMapValue (H.HashMap Text AnyValue)
  deriving stock (Read, Show, Eq, Ord, Data, Generic)
  deriving anyclass (Hashable)


-- | Create a `TextAttribute` from the string value.
instance IsString AnyValue where
  fromString :: String -> AnyValue
  fromString = TextValue . fromString


{- | Convert a Haskell value to an 'Any' value.

 @

 data Foo = Foo

 instance ToValue Foo where
   toValue Foo = TextValue "Foo"

 @
-}
class ToValue a where
  toValue :: a -> AnyValue


instance ToValue Text where
  toValue :: Text -> AnyValue
  toValue = TextValue


instance ToValue Bool where
  toValue :: Bool -> AnyValue
  toValue = BoolValue


instance ToValue Double where
  toValue :: Double -> AnyValue
  toValue = DoubleValue


instance ToValue Int64 where
  toValue :: Int64 -> AnyValue
  toValue = IntValue


instance ToValue ByteString where
  toValue :: ByteString -> AnyValue
  toValue = ByteStringValue


instance (ToValue a) => ToValue [a] where
  toValue :: (ToValue a) => [a] -> AnyValue
  toValue = ArrayValue . fmap toValue


instance (ToValue a) => ToValue (H.HashMap Text a) where
  toValue :: (ToValue a) => H.HashMap Text a -> AnyValue
  toValue = HashMapValue . fmap toValue


instance ToValue AnyValue where
  toValue :: AnyValue -> AnyValue
  toValue = id
