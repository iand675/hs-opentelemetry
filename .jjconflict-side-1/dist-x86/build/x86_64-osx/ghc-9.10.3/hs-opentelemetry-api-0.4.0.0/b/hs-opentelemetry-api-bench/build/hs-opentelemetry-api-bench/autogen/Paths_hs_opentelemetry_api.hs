{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
#if __GLASGOW_HASKELL__ >= 810
{-# OPTIONS_GHC -Wno-prepositive-qualified-module #-}
#endif
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_hs_opentelemetry_api (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,4,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath




bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/Users/ian/.cabal/bin"
libdir     = "/Users/ian/.cabal/lib/x86_64-osx-ghc-9.10.3-d4a6/hs-opentelemetry-api-0.4.0.0-inplace-hs-opentelemetry-api-bench"
dynlibdir  = "/Users/ian/.cabal/lib/x86_64-osx-ghc-9.10.3-d4a6"
datadir    = "/Users/ian/.cabal/share/x86_64-osx-ghc-9.10.3-d4a6/hs-opentelemetry-api-0.4.0.0"
libexecdir = "/Users/ian/.cabal/libexec/x86_64-osx-ghc-9.10.3-d4a6/hs-opentelemetry-api-0.4.0.0"
sysconfdir = "/Users/ian/.cabal/etc"

getBinDir     = catchIO (getEnv "hs_opentelemetry_api_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "hs_opentelemetry_api_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "hs_opentelemetry_api_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "hs_opentelemetry_api_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "hs_opentelemetry_api_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "hs_opentelemetry_api_sysconfdir") (\_ -> return sysconfdir)



joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
