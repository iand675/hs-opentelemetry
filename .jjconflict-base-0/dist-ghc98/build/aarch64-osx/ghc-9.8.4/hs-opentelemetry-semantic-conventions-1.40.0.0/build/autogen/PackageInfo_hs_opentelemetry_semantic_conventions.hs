{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}

module PackageInfo_hs_opentelemetry_semantic_conventions (
  name,
  version,
  synopsis,
  copyright,
  homepage,
) where

import Data.Version (Version (..))
import Prelude


name :: String
name = "hs_opentelemetry_semantic_conventions"


version :: Version
version = Version [1, 40, 0, 0] []


synopsis :: String
synopsis = "OpenTelemetry Semantic Conventions for Haskell"


copyright :: String
copyright = ""


homepage :: String
homepage = ""
