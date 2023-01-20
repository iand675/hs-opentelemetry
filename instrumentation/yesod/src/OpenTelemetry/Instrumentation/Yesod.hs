{-# LANGUAGE CPP #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

-- | This module makes it easier to use hs-opentelemetry-sdk with yesod.
module OpenTelemetry.Instrumentation.Yesod (
{-
Let @Site@ be following to use in examples:

@
newtype Site = Site { siteTracerProvider :: TracerProvider }
@
-}
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

import Control.Monad.IO.Class (MonadIO)
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
#if MIN_VERSION_template_haskell(2, 17, 0)
  Quote (newName),
#else
  newName,
#endif
 )
import Lens.Micro (Lens', lens)
import Network.Wai (Request (vault), requestHeaders)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Trace.Core (
  Span,
  SpanArguments (attributes, kind),
  SpanKind (Internal, Server),
  ToAttribute (toAttribute),
  Tracer,
  TracerProvider,
  addAttributes,
  defaultSpanArguments,
  getGlobalTracerProvider,
  makeTracer,
  tracerOptions,
 )
import qualified OpenTelemetry.Trace.Monad as M
import System.IO.Unsafe (unsafePerformIO)
import UnliftIO.Exception (catch, throwIO)
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


instance {-# OVERLAPPABLE #-} YesodOpenTelemetryTrace site => M.MonadTracer (HandlerFor site) where
  getTracer = getTracer


{- | Utility function to be used as implementation of 'M.MonadTracer'\'s 'M.getTracer' that uses the global tracer provider.

@
instance MonadTracer (HandlerFor Site) where
  getTracer = getTracerWithGlobalTracerProvider
@
-}
getTracerWithGlobalTracerProvider :: MonadIO m => m Tracer
getTracerWithGlobalTracerProvider = do
  tp <- getGlobalTracerProvider
  pure $ makeTracer tp "hs-opentelemetry-instrumentation-yesod" tracerOptions


{- | Template Haskell to generate a function named @routeToRenderer@.

 For a route like HomeR, this function returns "HomeR".

 For routes with parents, this function returns e.g. "FooR.BarR.BazR".

 See examples/yesod-minimal of hs-opentelemetry repository for usage.
-}
mkRouteToRenderer ::
  -- | Yesod site type
  Name ->
  -- | map from subsites type names to their @routeToRenderer@ Template Haskell expressions
  Map String ExpQ ->
  -- | route
  [ResourceTree String] ->
  Q [Dec]
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
mkRouteToPattern ::
  -- | Yesod site type
  Name ->
  -- | map from subsites type names to their @routeToRenderer@ Template Haskell expressions
  Map String ExpQ ->
  -- | route
  [ResourceTree String] ->
  Q [Dec]
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
          Methods {..} -> case methodsMulti of
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


{- | You should use this for 'Yesod.Core.yesodMiddleware' like:

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
openTelemetryYesodMiddleware ::
  (M.MonadTracer (HandlerFor site), ToTypedContent res, HasCallStack) =>
  RouteRenderer site ->
  HandlerFor site res ->
  HandlerFor site res
openTelemetryYesodMiddleware rr (HandlerFor doResponse) = do
  req <- waiRequest
  mspan <- Context.lookupSpan <$> getContext
  mr <- getCurrentRoute
  let sharedAttributes =
        catMaybes
          [ do
              r <- mr
              pure ("http.route", toAttribute $ pathRender rr r)
          , do
              ff <- lookup "X-Forwarded-For" $ requestHeaders req
              pure ("http.client_ip", toAttribute $ T.decodeUtf8 ff)
          ]
      args =
        defaultSpanArguments
          { kind = maybe Server (const Internal) mspan
          , attributes = sharedAttributes
          }
  mapM_ (`addAttributes` sharedAttributes) mspan
  eResult <- M.inSpan' (maybe "yesod.handler.notFound" (\r -> "yesod.handler." <> nameRender rr r) mr) args $ \s -> do
    catch
      ( HandlerFor $ \hdata@HandlerData {handlerRequest = hReq@YesodRequest {reqWaiRequest = waiReq}} -> do
          Right <$> doResponse (hdata {handlerRequest = hReq {reqWaiRequest = waiReq {vault = V.insert spanKey s $ vault waiReq}}})
      )
      $ \e -> do
        -- We want to mark the span as an error if it's an InternalError,
        -- the other HCError values are 4xx status codes which don't
        -- really count as a server error in OpenTelemetry spec parlance.
        case e of
          HCError (InternalError _) -> throwIO e
          _ -> pure (Left (e :: HandlerContents))
  case eResult of
    Left hc -> throwIO hc
    Right normal -> pure normal


spanKey :: V.Key Span
spanKey = unsafePerformIO V.newKey
{-# NOINLINE spanKey #-}


getHandlerSpan :: (MonadHandler m, HasCallStack) => m Span
getHandlerSpan = liftHandler $ HandlerFor $ maybe (fail "getHandlerSpan") pure . V.lookup spanKey . vault . reqWaiRequest . handlerRequest
