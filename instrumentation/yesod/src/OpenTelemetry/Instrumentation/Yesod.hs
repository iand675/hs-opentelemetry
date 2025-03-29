{-# LANGUAGE CPP #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{- |
[New HTTP semantic conventions have been declared stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "http" - to use the stable conventions
- "http/dup" - to emit both the old and the stable conventions
Otherwise, the old conventions will be used. The stable conventions will replace the old conventions in the next major release of this library.

Let @Site@ be following to use in examples:

@
newtype Site = Site { siteTracerProvider :: TracerProvider }
@
-}
module OpenTelemetry.Instrumentation.Yesod (
  openTelemetryYesodMiddleware,
  RouteRenderer (..),
  mkRouteToRenderer,
  mkRouteToPattern,
  YesodOpenTelemetryTrace (..),
  getHandlerSpan,

  -- * Utilities
  getTracerWithGlobalTracerProvider,
  rheSiteL,
  handlerEnvL,
) where

import Control.Exception (SomeException, displayException, fromException)
import Control.Monad (when)
import Control.Monad.IO.Class (MonadIO (liftIO))
import qualified Data.HashMap.Strict as H
import Data.List (intercalate)
import Data.Map (Map)
import qualified Data.Map as M
import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Vault.Lazy as V
import GHC.Stack (HasCallStack)
import Language.Haskell.TH (
  Clause,
  Dec,
  ExpQ,
  Name,
  Pat,
  Q,
  appE,
  clause,
  conP,
  conT,
  funD,
  mkName,
  normalB,
  recP,
  sigD,
  varE,
  varP,
  wildP,
 )
import Lens.Micro (Lens', lens)
import Network.Wai (Request (vault), requestHeaders)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Instrumentation.Wai (requestContext)
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core (
  Span,
  SpanArguments (attributes, kind),
  SpanKind (Internal, Server),
  SpanStatus (Error),
  ToAttribute (toAttribute),
  Tracer,
  TracerProvider,
  addAttributes,
  defaultSpanArguments,
  detectInstrumentationLibrary,
  getGlobalTracerProvider,
  makeTracer,
  recordException,
  setStatus,
  tracerOptions,
 )
import qualified OpenTelemetry.Trace.Monad as TM
import System.IO.Unsafe (unsafePerformIO)
import UnliftIO.Exception (catch, throwIO, withException)
import Yesod.Core (
  ErrorResponse (InternalError),
  HandlerFor,
  MonadHandler (HandlerSite, liftHandler),
  RenderRoute (Route),
  ToTypedContent,
  YesodRequest (YesodRequest, reqWaiRequest),
  getCurrentRoute,
  waiRequest,
 )
import Yesod.Core.Types (
  HandlerContents (HCError),
  HandlerData (HandlerData, handlerEnv, handlerRequest),
  HandlerFor (HandlerFor),
  RunHandlerEnv (rheSite),
 )
import Yesod.Routes.TH.Types (
  Dispatch (
    Methods,
    Subsite,
    methodsMethods,
    methodsMulti,
    subsiteFunc,
    subsiteType
  ),
  FlatResource (FlatResource, frCheck, frDispatch, frName, frParentPieces, frPieces),
  Piece (Dynamic, Static),
  Resource (Resource, resourceDispatch, resourceName),
  ResourceTree (ResourceLeaf, ResourceParent),
  flatten,
 )


#if MIN_VERSION_template_haskell(2, 17, 0)
import Language.Haskell.TH (Quote (newName))
#else
import Language.Haskell.TH (newName)
#endif


handlerEnvL :: Lens' (HandlerData child site) (RunHandlerEnv child site)
handlerEnvL = lens handlerEnv (\h e -> h {handlerEnv = e})
{-# INLINE handlerEnvL #-}


rheSiteL :: Lens' (RunHandlerEnv child site) site
rheSiteL = lens rheSite (\rhe new -> rhe {rheSite = new})
{-# INLINE rheSiteL #-}


{- | This class gives methods to get 'TracerProvider' or 'Tracer' from @site@.

A typical implementation is:

@
instance YesodOpenTelemetryTrace Site where
  getTracerProvider = siteTracerProvider
@
-}
class YesodOpenTelemetryTrace site where
  getTracerProvider :: site -> TracerProvider
  getTracer :: (MonadHandler m, HandlerSite m ~ site) => m Tracer
  default getTracer :: (MonadHandler m, HandlerSite m ~ site) => m Tracer
  getTracer =
    liftHandler $
      HandlerFor $ \hdata -> do
        let
          site = rheSite $ handlerEnv hdata
          tracerProvider = getTracerProvider site
        pure $ makeTracer tracerProvider "hs-opentelemetry-instrumentation-yesod" tracerOptions


instance {-# OVERLAPPABLE #-} YesodOpenTelemetryTrace site => TM.MonadTracer (HandlerFor site) where
  getTracer = getTracer


{- | Utility function to be used as implementation of 'TM.MonadTracer'\'s 'TM.getTracer' that uses the global tracer provider.

@
instance MonadTracer (HandlerFor Site) where
  getTracer = getTracerWithGlobalTracerProvider
@
-}
getTracerWithGlobalTracerProvider :: MonadIO m => m Tracer
getTracerWithGlobalTracerProvider = do
  tp <- getGlobalTracerProvider
  pure $ makeTracer tp $detectInstrumentationLibrary tracerOptions


{- | Template Haskell to generate a function named @routeToRenderer@.

 For a route like HomeR, this function returns "HomeR".

 For routes with parents, this function returns e.g. "FooR.BarR.BazR".

 See examples/yesod-minimal of hs-opentelemetry repository for usage.
-}
mkRouteToRenderer
  :: Name
  -- ^ Yesod site type
  -> Map String ExpQ
  -- ^ map from subsites type names to their @routeToRenderer@ Template Haskell expressions
  -> [ResourceTree String]
  -- ^ route
  -> Q [Dec]
mkRouteToRenderer appName subrendererExps ress = do
  let fnName = mkName "routeToRenderer"
  clauses <- mconcat <$> traverse (goTree id []) ress
  sequence
    [ sigD fnName [t|Route $(conT appName) -> Text|]
    , funD fnName clauses
    ]
  where
    goTree :: (Q Pat -> Q Pat) -> [String] -> ResourceTree String -> Q [Q Clause]
    goTree front names (ResourceLeaf res) = pure [goRes front names res]
    goTree front names (ResourceParent name _check pieces trees) =
      mconcat <$> traverse (goTree front' newNames) trees
      where
        ignored = (replicate toIgnore wildP ++) . pure
        toIgnore = length $ filter isDynamic pieces
        isDynamic Dynamic {} = True
        isDynamic Static {} = False
        front' = front . conP (mkName name) . ignored
        newNames = names <> [name]

    goRes :: (Q Pat -> Q Pat) -> [String] -> Resource String -> Q Clause
    goRes front names Resource {..} =
      case resourceDispatch of
        Methods {} ->
          clause
            [front $ recP (mkName resourceName) []]
            (normalB [|T.pack $ intercalate "." $ names <> [resourceName]|])
            []
        Subsite {..} -> do
          case M.lookup subsiteType subrendererExps of
            Just subrendererExp -> do
              subsiteVar <- newName "subsite"
              clause
                [conP (mkName resourceName) [varP subsiteVar]]
                (normalB [|resourceName <> "." <> $(subrendererExp) $(varE subsiteVar)|])
                []
            Nothing -> fail $ "mkRouteToRenderer: not found: " ++ subsiteType


{- | Template Haskell to generate a function named @routeToPattern@.

 See examples/yesod-minimal of hs-opentelemetry repository for usage.
-}
mkRouteToPattern
  :: Name
  -- ^ Yesod site type
  -> Map String ExpQ
  -- ^ map from subsites type names to their @routeToRenderer@ Template Haskell expressions
  -> [ResourceTree String]
  -- ^ route
  -> Q [Dec]
mkRouteToPattern appName subpatternExps ress = do
  let fnName = mkName "routeToPattern"
  sequence
    [ sigD fnName [t|Route $(conT appName) -> Text|]
    , funD fnName $ mkClause <$> flatten ress
    ]
  where
    isDynamic Dynamic {} = True
    isDynamic Static {} = False
    parentPieceWrapper (parentName, pieces) nestedPat =
      conP (mkName parentName) $
        mconcat
          [ replicate (length $ filter isDynamic pieces) wildP
          , [nestedPat]
          ]
    mkClause fr@FlatResource {..} = do
      let basePattern = renderPattern fr
      case frDispatch of
        Methods {} ->
          clause
            [foldr parentPieceWrapper (recP (mkName frName) []) frParentPieces]
            (normalB $ appE [|T.pack|] [|basePattern|])
            []
        Subsite {..} ->
          case M.lookup subsiteType subpatternExps of
            Just subpatternExp -> do
              subsiteVar <- newName "subsite"
              clause
                [foldr parentPieceWrapper (conP (mkName frName) [varP subsiteVar]) frParentPieces]
                (normalB [|basePattern <> $(subpatternExp) $(varE subsiteVar)|])
                []
            Nothing -> fail $ "mkRouteToPattern: not found: " ++ subsiteType


renderPattern :: FlatResource String -> String
renderPattern FlatResource {..} =
  concat $
    concat
      [ ["!" | not frCheck]
      , case formattedParentPieces <> concatMap routePortionSection frPieces of
          [] -> ["/"]
          pieces -> pieces
      , case frDispatch of
          Methods {..} ->
            case methodsMulti of
              Nothing -> []
              Just t -> ["/+", t]
          Subsite {} -> []
      ]
  where
    routePortionSection :: Piece String -> [String]
    routePortionSection (Static t) = ["/", t]
    routePortionSection (Dynamic t) = ["/#{", t, "}"]

    formattedParentPieces :: [String]
    formattedParentPieces = do
      (_parentName, pieces) <- frParentPieces
      piece <- pieces
      routePortionSection piece


data RouteRenderer site = RouteRenderer
  { nameRender :: Route site -> T.Text
  -- ^ You should bind this field to @routeToRenderer@.
  , pathRender :: Route site -> T.Text
  -- ^ You should bind this field to @routeToPattern@.
  }


-- TODO figure out a way to get better code locations for these spans.

{- | This middleware works best when used with `OpenTelemetry.Instrumentation.Wai` middleware.

You should use this for 'Yesod.Core.yesodMiddleware' like:

@
import Yesod.Core

routeToRenderer, routeToPattern :: Route Site -> Text
routeToRenderer = undefined -- made by mkRouteToRenderer
routeToPattern = undefined -- made by mkRouteToPattern

instance Yesod Site where
  yesodMiddleware =
    openTelemetryYesodMiddleware (RouteRenderer routeToRenderer routeToPattern)
      . defaultYesodMiddleware
@
-}
openTelemetryYesodMiddleware
  :: (TM.MonadTracer (HandlerFor site), ToTypedContent res, HasCallStack)
  => RouteRenderer site
  -> HandlerFor site res
  -> HandlerFor site res
openTelemetryYesodMiddleware rr (HandlerFor doResponse) = do
  req <- waiRequest
  mr <- getCurrentRoute
  semanticsOptions <- liftIO getSemanticsOptions
  let mspan = requestContext req >>= Context.lookupSpan
      sharedAttributes =
        H.fromList $
          ("http.framework", toAttribute ("yesod" :: Text))
            : catMaybes
              [ do
                  r <- mr
                  Just ("http.route", toAttribute $ pathRender rr r)
              , do
                  r <- mr
                  Just ("http.handler", toAttribute $ nameRender rr r)
              , do
                  ff <- lookup "X-Forwarded-For" $ requestHeaders req
                  case httpOption semanticsOptions of
                    Stable -> Just ("client.address", toAttribute $ T.decodeUtf8 ff)
                    StableAndOld -> Just ("client.address", toAttribute $ T.decodeUtf8 ff)
                    Old -> Nothing
              , do
                  ff <- lookup "X-Forwarded-For" $ requestHeaders req
                  case httpOption semanticsOptions of
                    Stable -> Nothing
                    StableAndOld -> Just ("http.client_ip", toAttribute $ T.decodeUtf8 ff)
                    Old -> Just ("http.client_ip", toAttribute $ T.decodeUtf8 ff)
              ]
      args =
        defaultSpanArguments
          { kind = maybe Server (const Internal) mspan
          , attributes = sharedAttributes
          }
      newHandler s =
        HandlerFor $ \hdata@HandlerData {handlerRequest = hReq@YesodRequest {reqWaiRequest = waiReq}} -> do
          doResponse (hdata {handlerRequest = hReq {reqWaiRequest = waiReq {vault = V.insert spanKey s $ vault waiReq}}})
  case mspan of
    Nothing -> do
      eResult <- TM.inSpan' (maybe "notFound" (nameRender rr) mr) args $ \s -> do
        catch (Right <$> newHandler s) $ \e -> do
          when (isInternalError e) $ throwIO e
          pure (Left (e :: HandlerContents))
      case eResult of
        Left hc -> throwIO hc
        Right normal -> pure normal
    Just waiSpan -> do
      addAttributes waiSpan sharedAttributes

      -- Explicitly record any exceptions here. When Yesod is in use, exceptions
      -- are handled as error-pages before reaching the WAI middleware's inSpan,
      -- meaning the exception details would not be otherwise attached.
      withException (newHandler waiSpan) $ \ex -> do
        when (shouldMarkException ex) $ do
          recordException waiSpan mempty Nothing ex
          setStatus waiSpan $ Error $ T.pack $ displayException ex


shouldMarkException :: SomeException -> Bool
shouldMarkException = maybe True isInternalError . fromException


-- We want to mark the span as an error if it's an InternalError, the other
-- HCError values are 4xx status codes which don't really count as a server
-- error in OpenTelemetry spec parlance.
isInternalError :: HandlerContents -> Bool
isInternalError (HCError (InternalError _)) = True
isInternalError _ = False


spanKey :: V.Key Span
spanKey = unsafePerformIO V.newKey
{-# NOINLINE spanKey #-}


getHandlerSpan :: (MonadHandler m, HasCallStack) => m Span
getHandlerSpan = liftHandler $ HandlerFor $ maybe (fail "getHandlerSpan") pure . V.lookup spanKey . vault . reqWaiRequest . handlerRequest
