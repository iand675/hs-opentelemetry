{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE UnboxedSums #-}

module OpenTelemetry.Context.Types where

import Data.Text (Text)
import qualified Data.Vault.Strict as V
import GHC.Exts (Any)
import OpenTelemetry.Baggage (Baggage)
import OpenTelemetry.Internal.UnpackedMaybe


{- | A @Context@ is a propagation mechanism which carries execution-scoped values
 across API boundaries and between logically associated execution units.
 Cross-cutting concerns access their data in-process using the same shared
 @Context@ object.

 The span and baggage slots use UMaybe (unboxed sums) for zero-indirection
 access when UNPACKed into the Context closure. All other keys go through
 the vault.
-}
data Context = Context
  { ctxSpanSlot :: {-# UNPACK #-} !(UMaybe Any)
  , ctxBaggageSlot :: {-# UNPACK #-} !(UMaybe Baggage)
  , ctxVault :: !V.Vault
  }


instance Semigroup Context where
  (<>) (Context s1 b1 v1) (Context s2 b2 v2) =
    Context
      (orElse s2 s1)
      (mergeBaggage b1 b2)
      (V.union v1 v2)
    where
      orElse UNothing x = x
      orElse x _ = x
      {-# INLINE orElse #-}
      mergeBaggage UNothing r = r
      mergeBaggage l UNothing = l
      mergeBaggage (UJust l) (UJust r) = UJust (l <> r)
      {-# INLINE mergeBaggage #-}


instance Monoid Context where
  mempty = Context UNothing UNothing V.empty


{- | Keys are used to allow cross-cutting concerns to control access to their local state.
 They are unique such that other libraries which may use the same context
 cannot accidentally use the same key. It is recommended that concerns mediate
 data access via an API, rather than provide direct public access to their keys.
-}
data Key a = Key {keyName :: Text, key :: V.Key a}
