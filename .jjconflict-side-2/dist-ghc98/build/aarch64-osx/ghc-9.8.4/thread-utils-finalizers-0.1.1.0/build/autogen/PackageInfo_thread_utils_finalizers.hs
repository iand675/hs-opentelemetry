{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}

module PackageInfo_thread_utils_finalizers (
  name,
  version,
  synopsis,
  copyright,
  homepage,
) where

import Data.Version (Version (..))
import Prelude


name :: String
name = "thread_utils_finalizers"


version :: Version
version = Version [0, 1, 1, 0] []


synopsis :: String
synopsis = "Perform finalization for threads."


copyright :: String
copyright = "2021 Ian Duncan"


homepage :: String
homepage = "https://github.com/iand675/thread-utils#readme"
