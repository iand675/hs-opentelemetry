{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      :  OpenTelemetry.Propagator
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Context propagation across process boundaries
Stability   :  experimental

= Overview

Propagators serialize and deserialize 'Context' (trace state and baggage)
into carrier formats like HTTP headers. This is how distributed tracing
works across service boundaries.

= Built-in propagators

The SDK registers these propagators automatically:

* __W3C TraceContext__ (@traceparent@ header) -- default
* __W3C Baggage__ (@baggage@ header) -- default
* __B3__ (Zipkin single and multi-header)
* __Jaeger__ (@uber-trace-id@ header)
* __Datadog__ (@x-datadog-trace-id@ headers)
* __AWS X-Ray__ (@X-Amzn-Trace-Id@ header)

Configure via @OTEL_PROPAGATORS@:

> export OTEL_PROPAGATORS=tracecontext,baggage,b3

= Usage in instrumentation

If you are writing instrumentation for a transport (HTTP, gRPC, messaging),
use the global propagator to inject\/extract context:

@
import OpenTelemetry.Propagator
import OpenTelemetry.Context.ThreadLocal

-- Injecting (outbound request):
propagator <- getGlobalTextMapPropagator
ctx <- getContext
headers <- inject propagator ctx request

-- Extracting (inbound request):
propagator <- getGlobalTextMapPropagator
ctx <- extract propagator request =<< getContext
tok <- attachContext ctx
-- ... later, restore previous context:
detachContext tok
@

= Custom propagators

Implement the 'Propagator' record with 'propagatorFields', 'extractor',
and 'injector' fields. Propagators are composable via their 'Monoid'
instance (extracts and injects run in sequence).

= Spec reference

<https://opentelemetry.io/docs/specs/otel/context/api-propagators/>
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

import Control.Exception (SomeException, catch)
import Control.Monad
import Control.Monad.IO.Class
import qualified Data.HashMap.Strict as H
import Data.IORef
import qualified Data.List as List
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Context.Types (Context)
import OpenTelemetry.Internal.Logging (otelLogWarning)
import System.IO.Unsafe (unsafePerformIO)


{- |
A carrier is the medium used by Propagators to read values from and write values to.
Each specific Propagator type defines its expected carrier type, such as a string map or a byte array.

@since 0.0.1.0
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
      , extractor = \i ctx -> do
          ctx' <-
            lExtract i ctx `catch` \(e :: SomeException) -> do
              otelLogWarning $ "Propagator extract failed: " <> show e
              pure ctx
          rExtract i ctx' `catch` \(e :: SomeException) -> do
            otelLogWarning $ "Propagator extract failed: " <> show e
            pure ctx'
      , injector = \c carrier -> do
          carrier' <-
            lInject c carrier `catch` \(e :: SomeException) -> do
              otelLogWarning $ "Propagator inject failed: " <> show e
              pure carrier
          rInject c carrier' `catch` \(e :: SomeException) -> do
            otelLogWarning $ "Propagator inject failed: " <> show e
            pure carrier'
      }


instance Monoid (Propagator c i o) where
  mempty = Propagator mempty (\_ c -> pure c) (\_ p -> pure p)


{- | A case-insensitive text map used as the carrier for context propagation.
Keys are compared case-insensitively but their original casing is preserved,
matching the behavior required by HTTP header semantics.

Instrumentation code converts between transport-specific representations
(e.g. HTTP headers) and 'TextMap' at the boundary.

@since 0.4.0.0
-}
data TextMap = TextMap
  { tmLookup :: !(H.HashMap Text Text)
  -- ^ Lowercase key -> value (for O(1) case-insensitive lookup)
  , tmOriginal :: !(H.HashMap Text Text)
  -- ^ Lowercase key -> original-cased key (to preserve casing on output)
  }
  deriving (Show, Eq)


-- | @since 0.4.0.0
emptyTextMap :: TextMap
emptyTextMap = TextMap H.empty H.empty
{-# INLINE emptyTextMap #-}


-- | @since 0.4.0.0
textMapInsert :: Text -> Text -> TextMap -> TextMap
textMapInsert k v (TextMap lk orig) =
  let lk' = T.toLower k
  in TextMap (H.insert lk' v lk) (H.insert lk' k orig)
{-# INLINE textMapInsert #-}


-- | @since 0.4.0.0
textMapLookup :: Text -> TextMap -> Maybe Text
textMapLookup k (TextMap lk _) = H.lookup (T.toLower k) lk
{-# INLINE textMapLookup #-}


-- | @since 0.4.0.0
textMapDelete :: Text -> TextMap -> TextMap
textMapDelete k (TextMap lk orig) =
  let lk' = T.toLower k
  in TextMap (H.delete lk' lk) (H.delete lk' orig)
{-# INLINE textMapDelete #-}


-- | @since 0.4.0.0
textMapKeys :: TextMap -> [Text]
textMapKeys (TextMap _ orig) = H.elems orig
{-# INLINE textMapKeys #-}


-- | @since 0.4.0.0
textMapToList :: TextMap -> [(Text, Text)]
textMapToList (TextMap lk orig) =
  H.foldlWithKey'
    ( \acc lk' v -> case H.lookup lk' orig of
        Just origKey -> (origKey, v) : acc
        Nothing -> (lk', v) : acc
    )
    []
    lk
{-# INLINE textMapToList #-}


-- | @since 0.4.0.0
textMapFromList :: [(Text, Text)] -> TextMap
textMapFromList = List.foldl' (\tm (k, v) -> textMapInsert k v tm) emptyTextMap


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

@since 0.0.1.0
-}
extract
  :: (MonadIO m)
  => Propagator context i o
  -> i
  -- ^ The carrier that holds the propagation fields. For example, an incoming message or HTTP request.
  -> context
  -> m context
  -- ^ a new Context derived from the Context passed as argument, containing the extracted value, which can be a SpanContext, Baggage or another cross-cutting concern context.
extract (Propagator _ extractor_ _) i ctx =
  liftIO $
    extractor_ i ctx `catch` \(e :: SomeException) -> do
      otelLogWarning $ "Propagator extract failed: " <> show e
      pure ctx


{- | Deprecated alias for 'propagatorFields'.

@since 0.0.1.0
-}
propagatorNames :: Propagator context i o -> [Text]
propagatorNames = propagatorFields
{-# DEPRECATED propagatorNames "Use propagatorFields instead. propagatorNames will be removed in a future release." #-}


{- | Injects the value into a carrier. For example, into the headers of an HTTP request.

@since 0.0.1.0
-}
inject
  :: (MonadIO m)
  => Propagator context i o
  -> context
  -> o
  -- ^ The carrier that holds the propagation fields. For example, an outgoing message or HTTP request.
  -> m o
inject (Propagator _ _ injector_) c carrier =
  liftIO $
    injector_ c carrier `catch` \(e :: SomeException) -> do
      otelLogWarning $ "Propagator inject failed: " <> show e
      pure carrier
