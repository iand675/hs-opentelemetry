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

import "otel-api" OpenTelemetry.Trace.Sampler