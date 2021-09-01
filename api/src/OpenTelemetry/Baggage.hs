{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module OpenTelemetry.Baggage where
import qualified Data.HashMap.Strict as H
import Data.Text (Text)

newtype Baggage = Baggage (H.HashMap Text Text)
  deriving newtype (Semigroup)

empty :: Baggage
empty = Baggage H.empty

insert :: Baggage -> Text -> Text -> Baggage
insert (Baggage c) k v = Baggage (H.insert k v c)

delete :: Baggage -> Text -> Baggage 
delete (Baggage c) k = Baggage (H.delete k c)

values :: Baggage -> H.HashMap Text Text
values (Baggage m) = m

-- TODO Must implement
-- * A `TextMapPropagator` implementing the [W3C Baggage Specification](https://w3c.github.io/baggage).