{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module OpenTelemetry.Context.Propagators where

class Propagator propagator operations where
  type Carrier propagator
  inject :: propagator -> operations
  extract :: propagator -> operations