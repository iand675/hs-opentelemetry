{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Trace.CallStackSpec (spec) where

import Control.Monad (void)
import qualified Data.HashMap.Strict as HM
import Data.IORef
import Data.Maybe (isJust)
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Stack (HasCallStack, withFrozenCallStack)
import OpenTelemetry.Attributes (Attribute (..), Attributes, PrimitiveAttribute (..), lookupAttribute, toAttribute)
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace.Core
import Test.Hspec


withTestTracer :: (Tracer -> IORef [ImmutableSpan] -> IO ()) -> IO ()
withTestTracer action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  let t = makeTracer tp "callstack-test" tracerOptions
  action t ref
  void $ forceFlushTracerProvider tp Nothing
  void $ shutdownTracerProvider tp Nothing


getLatestExportedSpan :: IORef [ImmutableSpan] -> IO ImmutableSpan
getLatestExportedSpan ref = do
  spans <- readIORef ref
  case spans of
    [] -> fail "expected at least one exported span"
    (sp : _) -> pure sp


readExportedHotAttributes :: IORef [ImmutableSpan] -> IO Attributes
readExportedHotAttributes ref = do
  sp <- getLatestExportedSpan ref
  hot <- readIORef (spanHot sp)
  pure (hotAttributes hot)


textFromAttribute :: Attribute -> Maybe Text
textFromAttribute (AttributeValue (TextAttribute x)) = Just x
textFromAttribute _ = Nothing


thisModule :: Text
thisModule = "OpenTelemetry.Trace.CallStackSpec"


shouldHaveCallerCodeAttrs :: Attributes -> Text -> Expectation
shouldHaveCallerCodeAttrs attrs expectedFn = do
  lookupAttribute attrs (unkey SC.code_function) `shouldBe` Just (toAttribute expectedFn)
  lookupAttribute attrs (unkey SC.code_namespace) `shouldBe` Just (toAttribute thisModule)
  lookupAttribute attrs (unkey SC.code_lineno) `shouldSatisfy` isJust
  case lookupAttribute attrs (unkey SC.code_filepath) >>= textFromAttribute of
    Nothing -> expectationFailure "expected code.filepath as text attribute"
    Just fp -> do
      fp `shouldSatisfy` ("CallStackSpec" `T.isInfixOf`)
      fp `shouldNotSatisfy` ("OpenTelemetry/Trace/Core.hs" `T.isInfixOf`)
      fp `shouldNotSatisfy` ("OpenTelemetry\\Trace\\Core.hs" `T.isInfixOf`)


shouldHaveNoCodeLocationAttrs :: Attributes -> Expectation
shouldHaveNoCodeLocationAttrs attrs = do
  lookupAttribute attrs (unkey SC.code_filepath) `shouldBe` Nothing
  lookupAttribute attrs (unkey SC.code_lineno) `shouldBe` Nothing
  lookupAttribute attrs (unkey SC.code_namespace) `shouldBe` Nothing
  lookupAttribute attrs (unkey SC.code_function) `shouldBe` Nothing


spec :: Spec
spec = describe "CallStack / source location capture" $ do
  -- Semantic conventions: source code attributes (code.function, code.namespace, …)
  -- https://opentelemetry.io/docs/specs/semconv/general/attributes/#source-code-attributes
  it "inSpan captures caller source location" $
    withTestTracer $ \t ref -> do
      namedInSpan t
      attrs <- readExportedHotAttributes ref
      shouldHaveCallerCodeAttrs attrs "namedInSpan"

  -- Semantic conventions: source code attributes
  -- https://opentelemetry.io/docs/specs/semconv/general/attributes/#source-code-attributes
  it "inSpan' captures caller source location" $
    withTestTracer $ \t ref -> do
      namedInSpan' t
      attrs <- readExportedHotAttributes ref
      shouldHaveCallerCodeAttrs attrs "namedInSpan'"

  -- Implementation-specific: inSpan'' omits automatic caller code attributes
  it "inSpan'' does NOT add source location attributes" $
    withTestTracer $ \t ref -> do
      namedInSpan'' t
      attrs <- readExportedHotAttributes ref
      shouldHaveNoCodeLocationAttrs attrs

  -- Semantic conventions: source code attributes on span creation
  -- https://opentelemetry.io/docs/specs/semconv/general/attributes/#source-code-attributes
  it "createSpan captures source location" $
    withTestTracer $ \t ref -> do
      namedCreateSpan t
      attrs <- readExportedHotAttributes ref
      lookupAttribute attrs (unkey SC.code_function) `shouldBe` Just (toAttribute @Text "namedCreateSpan")
      lookupAttribute attrs (unkey SC.code_namespace) `shouldBe` Just (toAttribute thisModule)
      lookupAttribute attrs (unkey SC.code_lineno) `shouldSatisfy` isJust
      case lookupAttribute attrs (unkey SC.code_filepath) >>= textFromAttribute of
        Nothing -> expectationFailure "expected code.filepath"
        Just fp -> fp `shouldSatisfy` ("CallStackSpec" `T.isInfixOf`)

  -- Implementation-specific: explicit API without CallStack-based code attributes
  it "createSpanWithoutCallStack does NOT add source location attributes" $
    withTestTracer $ \t ref -> do
      namedCreateSpanWithoutCallStack t
      attrs <- readExportedHotAttributes ref
      shouldHaveNoCodeLocationAttrs attrs

  -- Semantic conventions: user-supplied code.* must not be overwritten
  -- https://opentelemetry.io/docs/specs/semconv/general/attributes/#source-code-attributes
  it "user-provided code.function in SpanArguments is preserved by inSpan" $
    withTestTracer $ \t ref -> do
      inSpanWithUserCodeFunction t
      attrs <- readExportedHotAttributes ref
      lookupAttribute attrs (unkey SC.code_function)
        `shouldBe` Just (toAttribute @Text "user-chosen-function")

  -- Implementation-specific: filepath must reflect user module, not SDK internals
  it "source location points to test module, not OpenTelemetry.Trace.Core" $
    withTestTracer $ \t ref -> do
      namedInSpanForLibraryPathCheck t
      attrs <- readExportedHotAttributes ref
      case lookupAttribute attrs (unkey SC.code_filepath) >>= textFromAttribute of
        Nothing -> expectationFailure "expected code.filepath"
        Just fp -> do
          fp `shouldSatisfy` ("CallStackSpec" `T.isInfixOf`)
          fp `shouldNotSatisfy` ("Trace/Core.hs" `T.isInfixOf`)

  -- Implementation-specific: frozen CallStack disables automatic code.* injection
  it "withFrozenCallStack: createSpan adds no code location attributes" $
    withTestTracer $ \t ref -> do
      -- Same idea as @g@ in "TraceSpec": frozen stack makes 'callerAttributes' return
      -- 'mempty'. ('inSpan' uses 'callerCodeAttrs', which can still attach 'srcLoc' for a
      -- one-frame stack, so we test @createSpan@ here for truly empty @code.*@.)
      createSpanUnderFrozenCallStack t
      attrs <- readExportedHotAttributes ref
      shouldHaveNoCodeLocationAttrs attrs


{- | Each helper needs @HasCallStack@ so the implicit stack passed into
@inSpan@ / @createSpan@ includes this module\'s caller frame; otherwise
@callerCodeAttrs@ / @callerAttributes@ only see one frame and set
@code.function@ to @\"<unknown>\"@.
-}
namedInSpan :: HasCallStack => Tracer -> IO ()
namedInSpan t = inSpan t "named-inspan" defaultSpanArguments (pure ())
{-# NOINLINE namedInSpan #-}


namedInSpan' :: HasCallStack => Tracer -> IO ()
namedInSpan' t = inSpan' t "named-inspan-prime" defaultSpanArguments $ const (pure ())
{-# NOINLINE namedInSpan' #-}


namedInSpan'' :: HasCallStack => Tracer -> IO ()
namedInSpan'' t = inSpan'' t "named-inspan-prime-prime" defaultSpanArguments $ const (pure ())
{-# NOINLINE namedInSpan'' #-}


namedCreateSpan :: HasCallStack => Tracer -> IO ()
namedCreateSpan t = do
  s <- createSpan t Context.empty "named-create" defaultSpanArguments
  endSpan s Nothing
{-# NOINLINE namedCreateSpan #-}


namedCreateSpanWithoutCallStack :: Tracer -> IO ()
namedCreateSpanWithoutCallStack t = do
  s <- createSpanWithoutCallStack t Context.empty "named-create-nocs" defaultSpanArguments
  endSpan s Nothing
{-# NOINLINE namedCreateSpanWithoutCallStack #-}


inSpanWithUserCodeFunction :: HasCallStack => Tracer -> IO ()
inSpanWithUserCodeFunction t =
  inSpan
    t
    "user-code-fn-span"
    defaultSpanArguments {attributes = HM.singleton (unkey SC.code_function) (toAttribute @Text "user-chosen-function")}
    (pure ())
{-# NOINLINE inSpanWithUserCodeFunction #-}


namedInSpanForLibraryPathCheck :: HasCallStack => Tracer -> IO ()
namedInSpanForLibraryPathCheck t = inSpan t "library-path-check" defaultSpanArguments (pure ())
{-# NOINLINE namedInSpanForLibraryPathCheck #-}


createSpanUnderFrozenCallStack :: HasCallStack => Tracer -> IO ()
createSpanUnderFrozenCallStack t =
  withFrozenCallStack $ do
    s <- createSpan t Context.empty "frozen-create" defaultSpanArguments
    endSpan s Nothing
{-# NOINLINE createSpanUnderFrozenCallStack #-}
