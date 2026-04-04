{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Internal.Common.Types (
  InstrumentationLibrary (..),
  instrumentationLibrary,
  withSchemaUrl,
  withLibraryAttributes,
  AnyValue (..),
  ToValue (..),
  ShutdownResult (..),
  FlushResult (..),
  ExportResult (..),
  parseInstrumentationLibrary,
  detectInstrumentationLibrary,
) where

import Control.Exception (SomeException)
import Data.ByteString (ByteString)
import Data.Char (isAlphaNum, isDigit)
import Data.Data (Data)
import qualified Data.HashMap.Strict as H
import Data.Hashable (Hashable)
import Data.Int (Int64)
import Data.String (IsString (fromString))
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)
import qualified Language.Haskell.TH as TH
import qualified Language.Haskell.TH.Syntax as TH
import OpenTelemetry.Attributes (Attributes, emptyAttributes)


{- | An identifier for the library that provides the instrumentation for a given Instrumented Library.
 Instrumented Library and Instrumentation Library may be the same library if it has built-in OpenTelemetry instrumentation.

 The inspiration of the OpenTelemetry project is to make every library and application observable out of the box by having them call OpenTelemetry API directly.
 However, many libraries will not have such integration, and as such there is a need for a separate library which would inject such calls, using mechanisms such as wrapping interfaces,
 subscribing to library-specific callbacks, or translating existing telemetry into the OpenTelemetry model.

 A library that enables OpenTelemetry observability for another library is called an Instrumentation Library.

 An instrumentation library should be named to follow any naming conventions of the instrumented library (e.g. 'middleware' for a web framework).

 If there is no established name, the recommendation is to prefix packages with "hs-opentelemetry-instrumentation", followed by the instrumented library name itself.

 In general, the simplest way to get the instrumentation library is to use 'detectInstrumentationLibrary', which uses the Haskell package name and version.
-}
data InstrumentationLibrary = InstrumentationLibrary
  { libraryName :: {-# UNPACK #-} !Text
  -- ^ The name of the instrumentation library
  , libraryVersion :: {-# UNPACK #-} !Text
  -- ^ The version of the instrumented library
  , librarySchemaUrl :: {-# UNPACK #-} !Text
  , libraryAttributes :: Attributes
  }
  deriving (Ord, Eq, Generic, Show, TH.Lift)


instance Hashable InstrumentationLibrary


instance IsString InstrumentationLibrary where
  fromString :: String -> InstrumentationLibrary
  fromString str = InstrumentationLibrary (fromString str) "" "" emptyAttributes


{- | Create an 'InstrumentationLibrary' with a name and version.
Schema URL and attributes default to empty.

@
let scope = instrumentationLibrary "my-service" "1.2.0"
@

For more fields, chain with 'withSchemaUrl' or 'withLibraryAttributes':

@
let scope = instrumentationLibrary "my-service" "1.2.0"
          & withSchemaUrl "https:\/\/opentelemetry.io\/schemas\/1.25.0"
@

@since 0.4.0.0
-}
instrumentationLibrary :: Text -> Text -> InstrumentationLibrary
instrumentationLibrary name version =
  InstrumentationLibrary
    { libraryName = name
    , libraryVersion = version
    , librarySchemaUrl = ""
    , libraryAttributes = emptyAttributes
    }


{- | Set the schema URL on an 'InstrumentationLibrary'.

@since 0.4.0.0
-}
withSchemaUrl :: Text -> InstrumentationLibrary -> InstrumentationLibrary
withSchemaUrl url lib = lib {librarySchemaUrl = url}


{- | Set attributes on an 'InstrumentationLibrary'.

@since 0.4.0.0
-}
withLibraryAttributes :: Attributes -> InstrumentationLibrary -> InstrumentationLibrary
withLibraryAttributes attrs lib = lib {libraryAttributes = attrs}


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
  | NullValue
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


data ShutdownResult = ShutdownSuccess | ShutdownFailure | ShutdownTimeout
  deriving stock (Eq, Show)


-- | The outcome of a call to @OpenTelemetry.Trace.forceFlush@ or @OpenTelemetry.Logs.forceFlush@
data FlushResult
  = -- | One or more spans or @LogRecord@s did not export from all associated exporters
    -- within the alotted timeframe.
    FlushTimeout
  | -- | Flushing spans or @LogRecord@s to all associated exporters succeeded.
    FlushSuccess
  | -- | One or more exporters failed to successfully export one or more
    -- unexported spans or @LogRecord@s.
    FlushError
  deriving stock (Eq, Show)


data ExportResult
  = Success
  | Failure (Maybe SomeException)


{- | Parses a package-version string like @\"my-lib-1.2.3\"@ into an
 'InstrumentationLibrary'. Tries to split off a trailing version (digits and
 dots after the rightmost @-@). Falls back to treating the whole string as a
 package name with no version.
-}
parseInstrumentationLibrary :: (MonadFail m) => String -> m InstrumentationLibrary
parseInstrumentationLibrary packageString =
  case splitPackageVersion packageString of
    Just (name, version) ->
      pure $
        InstrumentationLibrary
          { libraryName = T.pack name
          , libraryVersion = T.pack version
          , librarySchemaUrl = ""
          , libraryAttributes = emptyAttributes
          }
    Nothing
      | isValidPackageName packageString ->
          pure $
            InstrumentationLibrary
              { libraryName = T.pack packageString
              , libraryVersion = ""
              , librarySchemaUrl = ""
              , libraryAttributes = emptyAttributes
              }
      | otherwise ->
          fail $ "could not parse package string: " <> packageString


{- | Try splitting @\"name-1.2.3\"@ or @\"name-1.2.3-hash\"@ at the rightmost
@-@ that precedes a version. The version is the maximal leading sequence of
digits and dots; any trailing content (e.g. @-inplace@, @-hash@) is
discarded, matching GHC's package-id format.
-}
splitPackageVersion :: String -> Maybe (String, String)
splitPackageVersion s =
  foldr
    (\i acc -> tryAt i acc)
    Nothing
    (reverse dashPositions)
  where
    dashPositions = fmap fst $ filter (\(_, c) -> c == '-') $ zip [0 :: Int ..] s
    tryAt i fallback =
      let name = take i s
          rest = drop (i + 1) s
          version = takeWhile isVersionChar rest
      in if not (null version)
          && isDigit (head version)
          && isValidPackageName name
          then Just (name, version)
          else fallback
    isVersionChar c = isDigit c || c == '.'


isValidPackageName :: String -> Bool
isValidPackageName [] = False
isValidPackageName [_] = False
isValidPackageName s = all isNameChar s && isAlphaNum (last s)
  where
    isNameChar c = isAlphaNum c || c == '-'


-- | Works out the instrumentation library for your package.
detectInstrumentationLibrary :: forall m. (TH.Quasi m, TH.Quote m) => m TH.Exp
detectInstrumentationLibrary = do
  TH.Loc {loc_package} <- TH.qLocation
  lib <- parseInstrumentationLibrary loc_package
  TH.lift lib
