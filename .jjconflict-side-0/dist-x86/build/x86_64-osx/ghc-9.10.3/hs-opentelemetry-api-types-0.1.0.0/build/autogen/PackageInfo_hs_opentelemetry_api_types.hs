{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}

module PackageInfo_hs_opentelemetry_api_types (
  name,
  version,
  synopsis,
  copyright,
  homepage,
) where

import Data.Version (Version (..))
import Prelude


name :: String
name = "hs_opentelemetry_api_types"


version :: Version
version = Version [0, 1, 0, 0] []


synopsis :: String
synopsis = "Core attribute types for hs-opentelemetry"


copyright :: String
copyright = "2024 Ian Duncan, Mercury Technologies"


homepage :: String
homepage = "https://github.com/iand675/hs-opentelemetry#readme"
