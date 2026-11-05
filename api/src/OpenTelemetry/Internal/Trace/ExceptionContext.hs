{-# LANGUAGE CPP #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

{- |
Module      :  OpenTelemetry.Internal.Trace.ExceptionContext
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Internal helpers for rendering exception context

This module isolates all of the base-version-dependent code for working with
the 'Control.Exception.Context' API introduced in @base-4.20@ (GHC 9.10) and
the 'WhileHandling' annotation introduced in @base-4.21@ (GHC 9.12). Keeping
the @#if MIN_VERSION_base@ blocks in one place makes the public modules easier
to read and maintain: in particular it means they need no CPP of their own to
mention 'ExceptionWithContext' (see the compat stub below).
-}
module OpenTelemetry.Internal.Trace.ExceptionContext (
  exceptionStackText,
  ExceptionWithContext,
  exceptionWithContextToSomeException,
) where

import Control.Exception (SomeException (..))
import Data.Text (Text)
import qualified Data.Text as T


#if MIN_VERSION_base(4,20,0)
import Control.Exception (Exception, ExceptionWithContext, someExceptionContext, toException)
import Control.Exception.Annotation (displayExceptionAnnotation)
import Control.Exception.Backtrace (Backtraces)
import Control.Exception.Context (ExceptionContext, getExceptionAnnotations)
#else
import Control.Exception (Exception (..))
import GHC.Stack (whoCreated)
import GHC.TypeLits (ErrorMessage (..), TypeError)
#endif
#if MIN_VERSION_base(4,21,0)
import Control.Exception (WhileHandling)
#endif

#if !MIN_VERSION_base(4,20,0)
{- | Compat stub for @ExceptionWithContext@ from @base-4.20@ (GHC 9.10).

On older base versions there is no exception context machinery, so this type
is uninhabited: it exists only so that
'OpenTelemetry.Trace.Core.recordExceptionWithContext' can be exported with
the same type signature on every supported GHC without any CPP at its
definition or export sites. Code that obtains an @ExceptionWithContext@
will only compile on @base-4.20+@, where this name is a re-export of the
real type.

We deliberately give this stub only /unsatisfiable/ instances (via
'TypeError'), for two reasons:

* A working 'Exception' instance would be a footgun: its @fromException@
  could only ever return @Nothing@, so a handler like
  @\\(e :: ExceptionWithContext IOException) -> ...@ would compile on old
  bases but silently never match, whereas on @base-4.20+@ the same handler
  catches the exception.

* /No/ instance would reject such code, but only with an unhelpful
  \"No instance for Exception (ExceptionWithContext ...)\" error. The
  unsatisfiable instances reject it with an explanation instead.
-}
data ExceptionWithContext e


type ExceptionWithContextUnavailableMessage =
  'Text "ExceptionWithContext requires base >= 4.20 (GHC 9.10+)."
    ':$$: 'Text "This version of base has no exception context machinery, so an ExceptionWithContext cannot be obtained here."
    ':$$: 'Text "Use recordSomeException / recordSomeError with a SomeException instead; they preserve exception context on GHCs that support it."


instance (TypeError ExceptionWithContextUnavailableMessage) => Show (ExceptionWithContext e) where
  show x = case x of {}


instance (Exception e, TypeError ExceptionWithContextUnavailableMessage) => Exception (ExceptionWithContext e) where
  toException x = case x of {}
  fromException _ = Nothing
  displayException x = case x of {}
#endif


{- | Convert an 'ExceptionWithContext' to a 'SomeException', preserving the
attached exception context.

On @base-4.20+@ this is just 'toException'; on older bases the argument type
is uninhabited, so this can never actually be reached.
-}
exceptionWithContextToSomeException :: (Exception e) => ExceptionWithContext e -> SomeException
#if MIN_VERSION_base(4,20,0)
exceptionWithContextToSomeException = toException
#else
exceptionWithContextToSomeException x = case x of {}
#endif


{- | Render the stacktrace text for an exception.

On @base-4.20+@ (GHC 9.10+), this walks the exception's 'ExceptionContext'
and renders any 'Backtraces' annotation. On @base-4.21+@ (GHC 9.12+), it
also renders the 'WhileHandling' annotation, so an exception thrown while
handling another exception carries the originating exception's display in
its rendered output too.

On older bases without the Backtraces API, this falls back to 'whoCreated'
to preserve the historical behaviour of the SDK.
-}
exceptionStackText :: SomeException -> IO Text
#if MIN_VERSION_base(4,20,0)
exceptionStackText se = pure $ T.pack $ unlines $ filter (not . null) sections
  where
    annotations :: ExceptionContext
    annotations = someExceptionContext se

    -- We use 'displayExceptionAnnotation' so we get the same rendering as GHC
    -- would use.
    sections :: [String]
    sections =
      map displayExceptionAnnotation (getExceptionAnnotations @Backtraces annotations)
#if MIN_VERSION_base(4,21,0)
        ++ map displayExceptionAnnotation (getExceptionAnnotations @WhileHandling annotations)
#endif
#else
exceptionStackText (SomeException inner) = do
  cs <- whoCreated inner
  pure $ T.unlines $ map T.pack cs
#endif
