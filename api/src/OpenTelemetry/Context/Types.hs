module OpenTelemetry.Context.Types where

import Data.Text (Text)
import qualified Data.Vault.Strict as V


{- | A `Context` is a propagation mechanism which carries execution-scoped values
 across API boundaries and between logically associated execution units.
 Cross-cutting concerns access their data in-process using the same shared
 `Context` object
-}
newtype Context = Context V.Vault


instance Semigroup Context where
  (<>) (Context l) (Context r) = Context (V.union l r)


instance Monoid Context where
  mempty = Context V.empty


{- | Keys are used to allow cross-cutting concerns to control access to their local state.
 They are unique such that other libraries which may use the same context
 cannot accidentally use the same key. It is recommended that concerns mediate
 data access via an API, rather than provide direct public access to their keys.
-}
data Key a = Key {keyName :: Text, key :: V.Key a}
