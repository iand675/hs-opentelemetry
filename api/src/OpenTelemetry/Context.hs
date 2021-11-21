{-# LANGUAGE OverloadedStrings #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Context
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
--
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- The ability to correlate events across service boundaries is one of the principle concepts behind distributed tracing. To find these correlations, components in a distributed system need to be able to collect, store, and transfer metadata referred to as context.
--
-- A context will often have information identifying the current span and trace, and can contain arbitrary correlations as key-value pairs.
--
-- Propagation is the means by which context is bundled and transferred in and across services, often via HTTP headers.
--
-- Together, context and propagation represent the engine behind distributed tracing.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Context
  ( Key(keyName)
  , newKey
  , Context
  , HasContext(..)
  , empty
  , lookup
  , insert
  -- , insertWith
  , adjust
  , delete
  , union
  , insertSpan
  , lookupSpan
  , insertBaggage
  , lookupBaggage
  ) where
import Control.Monad.IO.Class
import Data.Maybe
import Data.Text (Text)
import qualified Data.Vault.Strict as V
import Lens.Micro (Lens')
import OpenTelemetry.Baggage (Baggage)
import OpenTelemetry.Context.Types
import OpenTelemetry.Internal.Trace.Types
import Prelude hiding (lookup)
import System.IO.Unsafe

newKey :: MonadIO m => Text -> m (Key a)
newKey n = liftIO (Key n <$> V.newKey)

class HasContext s where
  contextL :: Lens' s Context

empty :: Context
empty = Context V.empty

lookup :: Key a -> Context -> Maybe a
lookup (Key _ k) (Context v) = V.lookup k v

insert :: Key a -> a -> Context -> Context
insert (Key _ k) x (Context v) = Context $ V.insert k x v

-- insertWith 
--   :: (a -> a -> a) 
--   -- ^ new value -> old value -> result
--   -> Key a -> a -> Context -> Context
-- insertWith f (Key _ k) x (Context v) = Context $ case V.lookup k of
--   Nothing -> V.insert k x v
--   Just ox -> V.insert k (f x ox) v

adjust :: (a -> a) -> Key a -> Context -> Context
adjust f (Key _ k) (Context v) = Context $ V.adjust f k v

delete :: Key a -> Context -> Context
delete (Key _ k) (Context v) = Context $ V.delete k v

union :: Context -> Context -> Context
union (Context v1) (Context v2) = Context $ V.union v1 v2

spanKey :: Key Span
spanKey = unsafePerformIO $ newKey "span"
{-# NOINLINE spanKey #-}

lookupSpan :: Context -> Maybe Span
lookupSpan = lookup spanKey

insertSpan :: Span -> Context -> Context
insertSpan = insert spanKey

baggageKey :: Key Baggage
baggageKey = unsafePerformIO $ newKey "baggage"
{-# NOINLINE baggageKey #-}

lookupBaggage :: Context -> Maybe Baggage
lookupBaggage = lookup baggageKey

insertBaggage :: Baggage -> Context -> Context
insertBaggage b c = case lookup baggageKey c of
  Nothing -> insert baggageKey b c
  Just b' -> insert baggageKey (b <> b') c
