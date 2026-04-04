{-# LANGUAGE RankNTypes #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Trace.Propagator
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Sending and receiving state between system boundaries
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Cross-cutting concerns send their state to the next process using Propagators, which are defined as objects used to
 read and write context data to and from messages exchanged by the applications.
 Each concern creates a set of Propagators for every supported Propagator type.

 Propagators leverage the Context to inject and extract data for each cross-cutting concern, such as traces and Baggage.

 Propagation is usually implemented via a cooperation of library-specific request interceptors and Propagators,
 where the interceptors detect incoming and outgoing requests and use the Propagator's extract and inject operations
 respectively.

 The Propagators API is expected to be leveraged by users writing instrumentation libraries. However,
 users using the OpenTelemetry SDK may need to select appropriate propagators to work with existing 3rd party systems
 such as AWS.
-}
module OpenTelemetry.Propagator (
  -- * Propagator
  Propagator (..),
  propagatorNames,
  extract,
  inject,

  -- * TextMap carrier
  TextMap,
  emptyTextMap,
  textMapInsert,
  textMapLookup,
  textMapDelete,
  textMapKeys,
  textMapToList,
  textMapFromList,

  -- * TextMapPropagator
  TextMapPropagator,

  -- * Global TextMapPropagator
  getGlobalTextMapPropagator,
  setGlobalTextMapPropagator,
) where

import Control.Monad
import Control.Monad.IO.Class
import Data.IORef
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Context.Types (Context)
import System.IO.Unsafe (unsafePerformIO)


{- |
A carrier is the medium used by Propagators to read values from and write values to.
Each specific Propagator type defines its expected carrier type, such as a string map or a byte array.
-}
data Propagator context inboundCarrier outboundCarrier = Propagator
  { propagatorFields :: [Text]
  -- ^ The predefined propagation fields. For a TextMapPropagator these are
  -- the header names the propagator reads and writes (e.g. @["traceparent", "tracestate"]@).
  -- If your carrier is reused, you should delete these fields before calling 'inject'.
  , extractor :: inboundCarrier -> context -> IO context
  , injector :: context -> outboundCarrier -> IO outboundCarrier
  }


instance Semigroup (Propagator c i o) where
  (Propagator lFields lExtract lInject) <> (Propagator rFields rExtract rInject) =
    Propagator
      { propagatorFields = lFields <> rFields
      , extractor = \i -> lExtract i >=> rExtract i
      , injector = \c -> lInject c >=> rInject c
      }


instance Monoid (Propagator c i o) where
  mempty = Propagator mempty (\_ c -> pure c) (\_ p -> pure p)


{- | A case-insensitive text map used as the carrier for context propagation.
Keys are normalized to lowercase on insertion and lookup, matching the
behavior required by HTTP header semantics.

Instrumentation code converts between transport-specific representations
(e.g. HTTP headers) and 'TextMap' at the boundary.

@since 0.4.0.0
-}
newtype TextMap = TextMap (H.HashMap Text Text)
  deriving (Show, Eq)


emptyTextMap :: TextMap
emptyTextMap = TextMap H.empty
{-# INLINE emptyTextMap #-}


textMapInsert :: Text -> Text -> TextMap -> TextMap
textMapInsert k v (TextMap m) = TextMap (H.insert (T.toLower k) v m)
{-# INLINE textMapInsert #-}


textMapLookup :: Text -> TextMap -> Maybe Text
textMapLookup k (TextMap m) = H.lookup (T.toLower k) m
{-# INLINE textMapLookup #-}


textMapDelete :: Text -> TextMap -> TextMap
textMapDelete k (TextMap m) = TextMap (H.delete (T.toLower k) m)
{-# INLINE textMapDelete #-}


textMapKeys :: TextMap -> [Text]
textMapKeys (TextMap m) = H.keys m
{-# INLINE textMapKeys #-}


textMapToList :: TextMap -> [(Text, Text)]
textMapToList (TextMap m) = H.toList m
{-# INLINE textMapToList #-}


textMapFromList :: [(Text, Text)] -> TextMap
textMapFromList = TextMap . H.fromList . map (\(k, v) -> (T.toLower k, v))


{- | A 'TextMapPropagator' is a 'Propagator' specialized for text-based
carriers. This is the only propagator type defined by the OpenTelemetry
specification.

Instrumentation libraries convert between transport-specific formats
(e.g. HTTP headers, gRPC metadata, environment variables) and 'TextMap'
at the boundary, then pass the 'TextMap' to the propagator.

@since 0.4.0.0
-}
type TextMapPropagator = Propagator Context TextMap TextMap


-- Per spec: "The OpenTelemetry API MUST use no-op propagators unless
-- explicitly configured otherwise." mempty is the no-op propagator.
globalTextMapPropagator :: IORef TextMapPropagator
globalTextMapPropagator = unsafePerformIO $ newIORef mempty
{-# NOINLINE globalTextMapPropagator #-}


{- | Get the globally configured 'TextMapPropagator'.

Returns a no-op propagator until the SDK sets one via
'setGlobalTextMapPropagator' (typically driven by @OTEL_PROPAGATORS@).

@since 0.4.0.0
-}
getGlobalTextMapPropagator :: IO TextMapPropagator
getGlobalTextMapPropagator = readIORef globalTextMapPropagator


{- | Set the global 'TextMapPropagator'.

Called by the SDK during initialization. Instrumentation libraries
should use 'getGlobalTextMapPropagator' rather than accessing the
'TracerProvider' propagator directly.

@since 0.4.0.0
-}
setGlobalTextMapPropagator :: TextMapPropagator -> IO ()
setGlobalTextMapPropagator = atomicWriteIORef globalTextMapPropagator


{- |
Extracts the value from an incoming request. For example, from the headers of an HTTP request.

If a value can not be parsed from the carrier, for a cross-cutting concern, the implementation MUST NOT throw an exception and MUST NOT store a new value in the Context, in order to preserve any previously existing valid value.
-}
extract
  :: (MonadIO m)
  => Propagator context i o
  -> i
  -- ^ The carrier that holds the propagation fields. For example, an incoming message or HTTP request.
  -> context
  -> m context
  -- ^ a new Context derived from the Context passed as argument, containing the extracted value, which can be a SpanContext, Baggage or another cross-cutting concern context.
extract (Propagator _ extractor _) i = liftIO . extractor i
{-# INLINE extract #-}


{- | Deprecated alias for 'propagatorFields'.

@since 0.0.1.0
-}
propagatorNames :: Propagator context i o -> [Text]
propagatorNames = propagatorFields
{-# DEPRECATED propagatorNames "Use propagatorFields instead. propagatorNames will be removed in a future release." #-}


-- | Injects the value into a carrier. For example, into the headers of an HTTP request.
inject
  :: (MonadIO m)
  => Propagator context i o
  -> context
  -> o
  -- ^ The carrier that holds the propagation fields. For example, an outgoing message or HTTP request.
  -> m o
inject (Propagator _ _ injector) c = liftIO . injector c
{-# INLINE inject #-}
