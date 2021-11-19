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
  , getTracer
  , tracerOptions
  , HasTracer(..)
  , InstrumentationLibrary(..)
  -- * 'Span' operations
  , Span
  , createSpan
  , emptySpanArguments
  , CreateSpanArguments(..)
  , updateName
  , insertAttribute 
  , insertAttributes
  , ToAttribute(..)
  , ToPrimitiveAttribute(..)
  , Attribute(..)
  , PrimitiveAttribute(..)
  , SpanKind(..)
  , Link(..)
  , Event
  , NewEvent(..)
  , addEvent
  , recordException
  , setStatus
  , SpanStatus(..)
  , SpanContext(..)
  -- TODO, don't remember if this is okay with the spec or not
  , ImmutableSpan(..)
  ) where

import "otel-api" OpenTelemetry.Trace
import OpenTelemetry.Resource