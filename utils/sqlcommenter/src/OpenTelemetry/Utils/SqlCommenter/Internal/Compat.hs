{-# LANGUAGE CPP #-}

{- |
Module      : OpenTelemetry.Utils.SqlCommenter.Internal.Compat
Description : Version-compatibility shims for the sqlcommenter implementation
Stability   : internal

This module isolates the handful of dependency-version differences the package
has to paper over, so that the rest of the package can stay free of CPP.

Currently this covers @text@'s strict builder type: @text@ 2.1.2 renamed it from
@StrictBuilder@ to 'StrictTextBuilder' and deprecated the old name. We re-export
the type under its modern name regardless of the @text@ version in use, so call
sites can refer to 'StrictTextBuilder' without tripping @-Wdeprecations@.
-}
module OpenTelemetry.Utils.SqlCommenter.Internal.Compat (
  StrictTextBuilder,
) where


#if MIN_VERSION_text(2,1,2)
import Data.Text.Encoding (StrictTextBuilder)
#else
import Data.Text.Encoding (StrictBuilder)


-- | Alias for the @text < 2.1.2@ spelling of the strict builder type.
type StrictTextBuilder = StrictBuilder
#endif
