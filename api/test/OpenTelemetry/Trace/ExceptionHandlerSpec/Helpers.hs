{- | Shared helpers used by both 'OpenTelemetry.Trace.ExceptionHandlerSpec'
and 'OpenTelemetry.Trace.ExceptionContextSpec'. Extracted to its own
module so the base-version-gated spec can import them without depending
on the main spec module.
-}
module OpenTelemetry.Trace.ExceptionHandlerSpec.Helpers (
  getOnlyExceptionEvent,
  dummySpanProcessor,
  DisplayDiffersFromShow (..),
) where

import Control.Exception (Exception (..))
import Data.IORef (readIORef)
import Data.Typeable (Typeable)
import qualified Data.Vector as V
import GHC.Stack (HasCallStack)
import OpenTelemetry.Processor.Span (FlushResult (..), ShutdownResult (..), SpanProcessor (..))
import OpenTelemetry.Trace.Core (
  Event (..),
  ImmutableSpan (..),
  Span,
  SpanHot (..),
  unsafeReadSpan,
 )
import OpenTelemetry.Util (appendOnlyBoundedCollectionValues)
import Test.Hspec (shouldBe)


{- | Read the single \"exception\" event from a span. Fails the test if the
event count is not exactly one.
-}
getOnlyExceptionEvent :: (HasCallStack) => Span -> IO Event
getOnlyExceptionEvent s = do
  imm <- unsafeReadSpan s
  hot <- readIORef (spanHot imm)
  let evts = appendOnlyBoundedCollectionValues (hotEvents hot)
  V.length evts `shouldBe` 1
  let evt = V.head evts
  eventName evt `shouldBe` "exception"
  pure evt


dummySpanProcessor :: SpanProcessor
dummySpanProcessor =
  SpanProcessor
    { spanProcessorOnStart = \_ _ -> pure ()
    , spanProcessorOnEnd = \_ -> pure ()
    , spanProcessorShutdown = pure ShutdownSuccess
    , spanProcessorForceFlush = pure FlushSuccess
    }


data DisplayDiffersFromShow = DisplayDiffersFromShow
  deriving (Typeable)


instance Show DisplayDiffersFromShow where
  show _ = "ShowForm"


instance Exception DisplayDiffersFromShow where
  displayException _ = "DisplayForm"
