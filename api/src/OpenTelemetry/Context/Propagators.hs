{-# LANGUAGE RankNTypes #-}
module OpenTelemetry.Context.Propagators where

import Control.Monad
import Control.Monad.IO.Class
import Data.Semigroup
import Data.Text

data Propagator context inboundPropagator outboundPropagator = Propagator
  { propagatorNames :: [Text]
  , extractor :: inboundPropagator -> context -> IO context
  , injector :: context -> outboundPropagator -> IO outboundPropagator
  }

instance Semigroup (Propagator c i o) where
  (Propagator lNames lExtract lInject) <> (Propagator rNames rExtract rInject) = Propagator
    { propagatorNames = lNames <> rNames
    , extractor = \i -> lExtract i >=> rExtract i
    , injector = \c -> lInject c >=> rInject c
    }

instance Monoid (Propagator c i o) where
  mempty = Propagator mempty (\_ c -> pure c) (\_ p -> pure p)

extract :: (MonadIO m) => Propagator context i o -> i -> context -> m context
extract (Propagator _ extractor _) i = liftIO . extractor i

inject :: (MonadIO m) => Propagator context i o -> context -> o -> m o
inject (Propagator _ _ injector) c = liftIO . injector c
