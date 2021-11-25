{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnliftedFFITypes #-}
{-# LANGUAGE UnboxedTuples #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Util
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Convenience functions to simplify common instrumentation needs.
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Util
  ( constructorName
  , HasConstructor
  , getThreadId
  ) where

import Data.Kind
import GHC.Generics
import GHC.Conc (ThreadId(ThreadId))
import GHC.Base (ThreadId#)
import Foreign.C (CInt(..))

-- | Useful for annotating which constructor in an ADT was chosen
--
-- @since 0.1.0.0
constructorName :: (HasConstructor (Rep a), Generic a) => a -> String
constructorName = genericConstrName . from

-- | Detect a constructor from any datatype which derives 'Generic'
class HasConstructor (f :: Type -> Type) where
  genericConstrName :: f x -> String

instance HasConstructor f => HasConstructor (D1 c f) where
  genericConstrName (M1 x) = genericConstrName x

instance (HasConstructor x, HasConstructor y) => HasConstructor (x :+: y) where
  genericConstrName (L1 l) = genericConstrName l
  genericConstrName (R1 r) = genericConstrName r

instance Constructor c => HasConstructor (C1 c f) where
  genericConstrName x = conName x

foreign import ccall unsafe "rts_getThreadId" c_getThreadId :: ThreadId# -> CInt

-- | Get an int representation of a thread id
getThreadId :: ThreadId -> Int
getThreadId (ThreadId tid#) = fromIntegral (c_getThreadId tid#)
{-# INLINE getThreadId #-}
