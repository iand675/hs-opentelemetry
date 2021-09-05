module OpenTelemetry.Trace 
  ( 
  -- * 'TracerProvider' operations
    TracerProvider
  -- ** 'TracerProvider' initialization
  , createTracerProvider
  , TracerProviderOptions(..)
  -- ** Getting / setting the global 'TracerProvider'
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  -- * 'Tracer' operations
  , Tracer
  -- * 'Span' operations
  , Span
  , Link
  , Event
  ) where

import "otel-api" OpenTelemetry.Trace