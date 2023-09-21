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
import System.Random.Stateful


{- | The default generator for trace and span ids.

 @since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
defaultIdGenerator = unsafePerformIO $ do
#if MIN_VERSION_random(1,2,1)
  genBase <- initStdGen
#else
  genBase <- newStdGen
#endif
  let (spanIdGen, traceIdGen) = split genBase
  sg <- newAtomicGenM spanIdGen
  tg <- newAtomicGenM traceIdGen
  pure $
    IdGenerator
      { generateSpanIdBytes = uniformByteStringM 8 sg
      , generateTraceIdBytes = uniformByteStringM 16 tg
      }
{-# NOINLINE defaultIdGenerator #-}
