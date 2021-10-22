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
  , tracerName
  , HasTracer(..)
  , InstrumentationLibrary(..)
  -- * 'Span' operations
  , Span
  , createSpan
  , emptySpanArguments
  , CreateSpanArguments(..)
  , SpanKind(..)
  , Link
  , Event
  -- TODO, don't remember if this is okay with the spec or not
  , ImmutableSpan(..)
  ) where

import "otel-api" OpenTelemetry.Trace