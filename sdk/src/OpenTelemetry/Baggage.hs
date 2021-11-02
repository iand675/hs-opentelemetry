module OpenTelemetry.Baggage 
  (
  -- * Constructing 'Baggage' structures
    Baggage
  , empty
  , fromHashMap
  , values
  , Token
  , token
  , mkToken
  , tokenValue
  , Element(..)
  , element
  , InvalidBaggage(..)
  -- * Modifying 'Baggage'
  , insert
  , delete
  -- * Encoding and decoding 'Baggage'
  , encodeBaggageHeader
  , encodeBaggageHeaderB
  , decodeBaggageHeader 
  , decodeBaggageHeaderP
  ) where

import "otel-api" OpenTelemetry.Baggage