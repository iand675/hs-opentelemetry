module OpenTelemetry.Context 
  ( Context
  , HasContext(..)
  , empty
  , lookupSpan
  , insertSpan
  , lookupBaggage
  , insertBaggage
  ) where

import "hs-opentelemetry-api" OpenTelemetry.Context
