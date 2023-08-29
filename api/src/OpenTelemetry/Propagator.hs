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
module OpenTelemetry.Propagator where

import Control.Monad
import Control.Monad.IO.Class
import Data.Text


{- |
A carrier is the medium used by Propagators to read values from and write values to.
Each specific Propagator type defines its expected carrier type, such as a string map or a byte array.
-}
data Propagator context inboundCarrier outboundCarrier = Propagator
  { propagatorNames :: [Text]
  , extractor :: inboundCarrier -> context -> IO context
  , injector :: context -> outboundCarrier -> IO outboundCarrier
  }


instance Semigroup (Propagator c i o) where
  (Propagator lNames lExtract lInject) <> (Propagator rNames rExtract rInject) =
    Propagator
      { propagatorNames = lNames <> rNames
      , extractor = \i -> lExtract i >=> rExtract i
      , injector = \c -> lInject c >=> rInject c
      }


instance Monoid (Propagator c i o) where
  mempty = Propagator mempty (\_ c -> pure c) (\_ p -> pure p)


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


-- | Injects the value into a carrier. For example, into the headers of an HTTP request.
inject
  :: (MonadIO m)
  => Propagator context i o
  -> context
  -> o
  -- ^ The carrier that holds the propagation fields. For example, an outgoing message or HTTP request.
  -> m o
inject (Propagator _ _ injector) c = liftIO . injector c
