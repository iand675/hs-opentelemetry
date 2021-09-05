{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Context 
  ( Key(keyName)
  , newKey
  , Context
  , empty
  , lookup
  , insert
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
import Data.Unique.Really
import qualified Data.Vault.Strict as V
import OpenTelemetry.Baggage (Baggage)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context.Types
import OpenTelemetry.Internal.Trace.Types
import Prelude hiding (lookup)
import System.Mem.Weak
import System.IO.Unsafe

newKey :: MonadIO m => Text -> m (Key a)
newKey n = liftIO (Key n <$> V.newKey)

empty :: Context
empty = Context V.empty

lookup :: Key a -> Context -> Maybe a
lookup (Key _ k) (Context v) = V.lookup k v

insert :: Key a -> a -> Context -> Context
insert (Key _ k) x (Context v) = Context $ V.insert k x v

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
lookupBaggage c = lookup baggageKey c

insertBaggage :: Baggage -> Context -> Context
insertBaggage b c = case lookup baggageKey c of
  Nothing -> insert baggageKey b c
  Just b' -> insert baggageKey (b <> b') c
