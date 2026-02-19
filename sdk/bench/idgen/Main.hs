{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnliftedFFITypes #-}

module Main where

import Control.Concurrent (getNumCapabilities, myThreadId)
import Control.Concurrent.Async (forConcurrently_)
import Control.Concurrent.MVar
import Control.Concurrent.Thread.Storage (ThreadStorageMap, lookup, newThreadStorageMap, attach)
import Control.Monad (replicateM_, void, when)
import Criterion.Main
import Data.ByteString (ByteString)
import qualified Data.ByteString.Internal as BSI
import Data.IORef
import qualified Data.Vector as V
import Data.Word (Word8)
import Foreign.C.Types (CInt (..))
import Foreign.ForeignPtr (withForeignPtr)
import Foreign.Ptr (Ptr)
import GHC.Conc (ThreadId (ThreadId))
import GHC.Exts (unsafeCoerce#)
import GHC.Base (Addr#)
import Prelude hiding (lookup)
import System.Random.Stateful


-- ── Haskell Strategy 1: Global AtomicGenM (current implementation) ──

mkAtomicGen :: IO (IO ByteString, IO ByteString)
mkAtomicGen = do
  genBase <- initStdGen
  let (sg, tg) = split genBase
  atomicSpan <- newAtomicGenM sg
  atomicTrace <- newAtomicGenM tg
  pure (uniformByteStringM 8 atomicSpan, uniformByteStringM 16 atomicTrace)


-- ── Haskell Strategy 2: Thread-local IOGenM via thread-utils-context ──

mkThreadLocalGen :: IO (IO ByteString, IO ByteString)
mkThreadLocalGen = do
  spanMap <- newThreadStorageMap :: IO (ThreadStorageMap (IOGenM StdGen))
  traceMap <- newThreadStorageMap :: IO (ThreadStorageMap (IOGenM StdGen))
  genBase <- initStdGen
  seedRef <- newIORef genBase
  let getOrCreate tmap = do
        mg <- lookup tmap
        case mg of
          Just g -> pure g
          Nothing -> do
            seed <- atomicModifyIORef' seedRef (\s -> let (a, b) = split s in (b, a))
            g <- newIOGenM seed
            _ <- attach tmap g
            pure g
  pure
    ( do g <- getOrCreate spanMap; uniformByteStringM 8 g
    , do g <- getOrCreate traceMap; uniformByteStringM 16 g
    )


-- ── Haskell Strategy 3: Per-capability IOGenM (array indexed by thread id) ──

foreign import ccall unsafe "rts_getThreadId" c_getThreadId :: Addr# -> CInt

getThreadId :: ThreadId -> Int
getThreadId (ThreadId tid#) = fromIntegral $ c_getThreadId (unsafeCoerce# tid#)

mkPerCapGen :: IO (IO ByteString, IO ByteString)
mkPerCapGen = do
  caps <- getNumCapabilities
  let n = max caps 16
  genBase <- initStdGen
  seedRef <- newIORef genBase
  spanGens <- V.generateM n $ \_ -> do
    seed <- atomicModifyIORef' seedRef (\s -> let (a, b) = split s in (b, a))
    newIOGenM seed
  traceGens <- V.generateM n $ \_ -> do
    seed <- atomicModifyIORef' seedRef (\s -> let (a, b) = split s in (b, a))
    newIOGenM seed
  pure
    ( do tid <- myThreadId
         let !idx = getThreadId tid `mod` n
         uniformByteStringM 8 (spanGens V.! idx)
    , do tid <- myThreadId
         let !idx = getThreadId tid `mod` n
         uniformByteStringM 16 (traceGens V.! idx)
    )


-- ── C FFI declarations ──

foreign import ccall unsafe "hs_rng_rdrand_span"
  c_rdrand_span :: Ptr Word8 -> IO CInt
foreign import ccall unsafe "hs_rng_rdrand_trace"
  c_rdrand_trace :: Ptr Word8 -> IO CInt

foreign import ccall unsafe "hs_rng_getrandom_span"
  c_getrandom_span :: Ptr Word8 -> IO CInt
foreign import ccall unsafe "hs_rng_getrandom_trace"
  c_getrandom_trace :: Ptr Word8 -> IO CInt

foreign import ccall unsafe "hs_rng_splitmix_span"
  c_splitmix_span :: Ptr Word8 -> IO ()
foreign import ccall unsafe "hs_rng_splitmix_trace"
  c_splitmix_trace :: Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_rng_xoshiro_span"
  c_xoshiro_span :: Ptr Word8 -> IO ()
foreign import ccall unsafe "hs_rng_xoshiro_trace"
  c_xoshiro_trace :: Ptr Word8 -> IO ()


-- ── C-backed generators ──

mkCGen
  :: (Ptr Word8 -> IO ()) -> Int
  -> IO ByteString
mkCGen gen len = BSI.create len gen
{-# INLINE mkCGen #-}

cSplitmixSpan :: IO ByteString
cSplitmixSpan = mkCGen c_splitmix_span 8

cSplitmixTrace :: IO ByteString
cSplitmixTrace = mkCGen c_splitmix_trace 16

cXoshiroSpan :: IO ByteString
cXoshiroSpan = mkCGen c_xoshiro_span 8

cXoshiroTrace :: IO ByteString
cXoshiroTrace = mkCGen c_xoshiro_trace 16

cRdrandSpan :: IO ByteString
cRdrandSpan = BSI.create 8 $ \p -> do
  rc <- c_rdrand_span p
  when (rc /= 0) $ fail "RDRAND not available"

cRdrandTrace :: IO ByteString
cRdrandTrace = BSI.create 16 $ \p -> do
  rc <- c_rdrand_trace p
  when (rc /= 0) $ fail "RDRAND not available"

cGetrandomSpan :: IO ByteString
cGetrandomSpan = BSI.create 8 $ \p -> do
  rc <- c_getrandom_span p
  when (rc /= 0) $ fail "getrandom failed"

cGetrandomTrace :: IO ByteString
cGetrandomTrace = BSI.create 16 $ \p -> do
  rc <- c_getrandom_trace p
  when (rc /= 0) $ fail "getrandom failed"


main :: IO ()
main = do
  caps <- getNumCapabilities
  putStrLn $ "Running with " ++ show caps ++ " capabilities"

  (atomicSpan, atomicTrace) <- mkAtomicGen
  (tlSpan, tlTrace) <- mkThreadLocalGen
  (pcSpan, pcTrace) <- mkPerCapGen

  -- Sanity check all generators
  void atomicSpan >> void atomicTrace
  void tlSpan >> void tlTrace
  void pcSpan >> void pcTrace
  void cSplitmixSpan >> void cSplitmixTrace
  void cXoshiroSpan >> void cXoshiroTrace
  void cRdrandSpan >> void cRdrandTrace
  void cGetrandomSpan >> void cGetrandomTrace
  putStrLn "All generators OK"

  let nThreads = max caps 4
      nIters = 10000

  defaultMain
    [ bgroup "single-thread"
      [ bgroup "spanId-8B"
        [ bench "hs-atomic-cas" $ whnfIO atomicSpan
        , bench "hs-thread-local" $ whnfIO tlSpan
        , bench "hs-per-cap" $ whnfIO pcSpan
        , bench "c-splitmix-tls" $ whnfIO cSplitmixSpan
        , bench "c-xoshiro-tls" $ whnfIO cXoshiroSpan
        , bench "c-rdrand" $ whnfIO cRdrandSpan
        , bench "c-getrandom" $ whnfIO cGetrandomSpan
        ]
      , bgroup "traceId-16B"
        [ bench "hs-atomic-cas" $ whnfIO atomicTrace
        , bench "hs-thread-local" $ whnfIO tlTrace
        , bench "hs-per-cap" $ whnfIO pcTrace
        , bench "c-splitmix-tls" $ whnfIO cSplitmixTrace
        , bench "c-xoshiro-tls" $ whnfIO cXoshiroTrace
        , bench "c-rdrand" $ whnfIO cRdrandTrace
        , bench "c-getrandom" $ whnfIO cGetrandomTrace
        ]
      ]
    , bgroup ("contended-" ++ show nThreads ++ "T-" ++ show nIters ++ "each")
      [ bgroup "spanId-8B"
        [ bench "hs-atomic-cas" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters atomicSpan
        , bench "hs-thread-local" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters tlSpan
        , bench "hs-per-cap" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters pcSpan
        , bench "c-splitmix-tls" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cSplitmixSpan
        , bench "c-xoshiro-tls" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cXoshiroSpan
        , bench "c-rdrand" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cRdrandSpan
        , bench "c-getrandom" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cGetrandomSpan
        ]
      , bgroup "traceId-16B"
        [ bench "hs-atomic-cas" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters atomicTrace
        , bench "hs-thread-local" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters tlTrace
        , bench "hs-per-cap" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters pcTrace
        , bench "c-splitmix-tls" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cSplitmixTrace
        , bench "c-xoshiro-tls" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cXoshiroTrace
        , bench "c-rdrand" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cRdrandTrace
        , bench "c-getrandom" $ whnfIO $
            forConcurrently_ [1..nThreads] $ \_ -> replicateM_ nIters cGetrandomTrace
        ]
      ]
    ]
