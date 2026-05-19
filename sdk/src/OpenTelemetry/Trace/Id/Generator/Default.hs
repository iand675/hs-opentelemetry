{-# LANGUAGE CPP #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Trace.Id.Generator.Default
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 A reasonably performant out of the box implementation of random span and trace id generation.
-}
module OpenTelemetry.Trace.Id.Generator.Default (
  defaultIdGenerator,
) where

import OpenTelemetry.Trace.Id.Generator (IdGenerator (..))


{- | The default generator for trace and span ids.

 @since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
defaultIdGenerator = DefaultIdGenerator
