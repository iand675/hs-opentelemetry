{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}

module PackageInfo_thread_utils_context (
  name,
  version,
  synopsis,
  copyright,
  homepage,
) where

import Data.Version (Version (..))
import Prelude


name :: String
name = "thread_utils_context"


version :: Version
version = Version [0, 3, 0, 4] []


synopsis :: String
synopsis = "Garbage-collected thread local storage"


copyright :: String
copyright = "2023 Ian Duncan"


homepage :: String
homepage = "https://github.com/iand675/thread-utils#readme"
