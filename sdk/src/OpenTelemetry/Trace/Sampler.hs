module OpenTelemetry.Trace.Sampler 
  ( Sampler(..)
  , SamplingResult(..)
  , alwaysOn
  , alwaysOff 
  , parentBased
  , ParentBasedOptions(..)
  , parentBasedOptions
  , traceIdRatioBased
  ) where

import "hs-opentelemetry-api" OpenTelemetry.Trace.Sampler