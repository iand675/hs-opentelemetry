module OpenTelemetry.Trace 
  ( 
  -- * 'TracerProvider' operations
    TracerProvider
  , HasTracerProvider(..)
  -- ** 'TracerProvider' initialization
  , createTracerProvider
  , TracerProviderOptions(..)
  , emptyTracerProviderOptions
  , builtInResources
  -- ** Getting / setting the global 'TracerProvider'
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  -- * 'Tracer' operations
  , Tracer
  , HasTracer(..)
  -- * 'Span' operations
  , Span
  , createSpan
  , emptySpanArguments
  , CreateSpanArguments(..)
  , SpanKind(..)
  , Link
  , Event
  ) where

import "otel-api" OpenTelemetry.Trace