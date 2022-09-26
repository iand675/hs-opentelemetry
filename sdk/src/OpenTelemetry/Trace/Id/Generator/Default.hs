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
import System.IO.Unsafe (unsafePerformIO)
import System.Random.MWC


#if MIN_VERSION_random(1,2,0)
import System.Random.Stateful
#else
import Data.ByteString.Random
#endif


{- | The default generator for trace and span ids.

 @since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
#if MIN_VERSION_random(1,2,0)
defaultIdGenerator = unsafePerformIO $ do
  g <- createSystemRandom
  pure $ IdGenerator
    { generateSpanIdBytes = uniformByteStringM 8 g
    , generateTraceIdBytes = uniformByteStringM 16 g
    }
{-# NOINLINE defaultIdGenerator #-}
#else
defaultIdGenerator = unsafePerformIO $ do
  g <- createSystemRandom
  pure $ IdGenerator
    { generateSpanIdBytes = randomGen g 8
    , generateTraceIdBytes = randomGen g 16
    }
{-# NOINLINE defaultIdGenerator #-}
#endif
