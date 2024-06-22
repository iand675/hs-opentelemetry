{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE InstanceSigs #-}

module OpenTelemetry.Internal.Common.Types (
  InstrumentationLibrary (..),
  ShutdownResult (..),
  FlushResult (..),
) where

import Data.Hashable (Hashable)
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
 import Paths_your_package_name

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


data ShutdownResult = ShutdownSuccess | ShutdownFailure | ShutdownTimeout


-- | The outcome of a call to @OpenTelemetry.Trace.forceFlush@ or @OpenTelemetry.Logging.forceFlush@
data FlushResult
  = -- | One or more spans or @LogRecord@s did not export from all associated exporters
    -- within the alotted timeframe.
    FlushTimeout
  | -- | Flushing spans or @LogRecord@s to all associated exporters succeeded.
    FlushSuccess
  | -- | One or more exporters failed to successfully export one or more
    -- unexported spans or @LogRecord@s.
    FlushError
  deriving (Show)
