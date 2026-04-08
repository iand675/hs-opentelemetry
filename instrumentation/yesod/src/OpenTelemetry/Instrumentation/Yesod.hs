{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{- |
Module      : OpenTelemetry.Instrumentation.Yesod
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Automatic tracing for Yesod web applications
Stability   : experimental

= Overview

Provides Yesod middleware that automatically creates spans for incoming
HTTP requests. Uses Yesod's type-safe routing to produce meaningful span
names (e.g. \"GET UserR\" instead of \"GET /users/123\").

= Quick example

@
import OpenTelemetry.Instrumentation.Yesod (openTelemetryYesodMiddleware)

instance Yesod App where
  yesodMiddleware = openTelemetryYesodMiddleware . defaultYesodMiddleware
@

= What gets traced

* A @Server@ span per request, named after the Yesod route type
* Standard HTTP attributes: method, status code, path, scheme
* Trace context extracted from incoming request headers

[HTTP semantic conventions migration:](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan)
set @OTEL_SEMCONV_STABILITY_OPT_IN@ to @http@, @http/dup@, or leave unset for legacy-only.
-}
module OpenTelemetry.Instrumentation.Yesod (
  -- * Middleware functionality
  openTelemetryYesodMiddleware,
  RouteRenderer (..),
  mkRouteToRenderer,
  mkRouteToPattern,

  -- * Utilities
  rheSiteL,
  handlerEnvL,

  -- * Testing helpers
  renderPattern,
  exceptionTypeName,
  shouldMarkException,
  isInternalError,
) where

import Control.Monad (when)
import qualified Data.HashMap.Strict as H
import Data.List (intercalate)
import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Data.Typeable (typeOf)
import Language.Haskell.TH.Syntax
import Lens.Micro
import Network.Wai (requestHeaders, requestMethod)
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Instrumentation.Wai (requestContext)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.SemanticsConfig
import OpenTelemetry.Trace.Core hiding (inSpan, inSpan', inSpan'')
import OpenTelemetry.Trace.Monad
import UnliftIO.Exception
import Yesod.Core
import Yesod.Core.Types
import Yesod.Routes.TH.Types


handlerEnvL :: Lens' (HandlerData child site) (RunHandlerEnv child site)
handlerEnvL = lens handlerEnv (\h e -> h {handlerEnv = e})
{-# INLINE handlerEnvL #-}


rheSiteL :: Lens' (RunHandlerEnv child site) site
rheSiteL = lens rheSite (\rhe new -> rhe {rheSite = new})
{-# INLINE rheSiteL #-}


instance MonadTracer (HandlerFor site) where
  getTracer = do
    tp <- getGlobalTracerProvider
    pure $ makeTracer tp $detectInstrumentationLibrary tracerOptions


{- | Template Haskell to generate a function named routeToRendererFunction.

 For a route like HomeR, this function returns "HomeR".

 For routes with parents, this function returns e.g. "FooR.BarR.BazR".
-}
mkRouteToRenderer :: Name -> [ResourceTree a] -> Q [Dec]
mkRouteToRenderer appName ress = do
  let fnName = mkName "routeToRenderer"
      t1 `arrow` t2 = ArrowT `AppT` t1 `AppT` t2

  clauses <- mapM (goTree id []) ress

  pure
    [ SigD fnName ((ConT ''Route `AppT` ConT appName) `arrow` ConT ''Text)
    , FunD fnName $ concat clauses
    ]


goTree :: (Pat -> Pat) -> [String] -> ResourceTree a -> Q [Clause]
goTree front names (ResourceLeaf res) = pure <$> goRes front names res
#if MIN_VERSION_template_haskell(2, 18, 0)
goTree front names (ResourceParent name _check pieces trees) =
  concat <$> mapM (goTree front' newNames) trees
  where
    ignored = (replicate toIgnore WildP ++) . pure
    toIgnore = length $ filter isDynamic pieces
    isDynamic Dynamic {} = True
    isDynamic Static {} = False
    front' = front . ConP (mkName name) [] . ignored
    newNames = names <> [name]
#else
goTree front names (ResourceParent name _check pieces trees) =
  concat <$> mapM (goTree front' newNames) trees
  where
    ignored = (replicate toIgnore WildP ++) . pure
    toIgnore = length $ filter isDynamic pieces
    isDynamic Dynamic {} = True
    isDynamic Static {} = False
    front' = front . ConP (mkName name) . ignored
    newNames = names <> [name]
#endif


goRes :: (Pat -> Pat) -> [String] -> Resource a -> Q Clause
goRes front names Resource {..} =
  pure $
    Clause
      [front $ RecP (mkName resourceName) []]
      (NormalB $ toText $ intercalate "." (names <> [resourceName]))
      []
  where
    toText s = VarE 'T.pack `AppE` LitE (StringL s)


mkRouteToPattern :: Name -> [ResourceTree String] -> Q [Dec]
#if MIN_VERSION_template_haskell(2, 18, 0)
mkRouteToPattern appName ress = do
  let fnName = mkName "routeToPattern"
      t1 `arrow` t2 = ArrowT `AppT` t1 `AppT` t2

  clauses <- mapM mkClause $ flatten ress

  pure
    [ SigD fnName ((ConT ''Route `AppT` ConT appName) `arrow` ConT ''Text)
    , FunD fnName clauses
    ]

  where
    toText s = VarE 'T.pack `AppE` LitE (StringL s)
    isDynamic Dynamic {} = True
    isDynamic Static {} = False
    parentPieceWrapper (parentName, pieces) nestedPat = ConP (mkName parentName) [] $ mconcat
      [ replicate (length $ filter isDynamic pieces) WildP
      , [nestedPat]
      ]
    mkClause fr@FlatResource{..} = do
      let clausePattern = foldr parentPieceWrapper (RecP (mkName frName) []) frParentPieces
      pure $ Clause
        [clausePattern]
        (NormalB $ toText $ renderPattern fr)
        []
#else
mkRouteToPattern appName ress = do
  let fnName = mkName "routeToPattern"
      t1 `arrow` t2 = ArrowT `AppT` t1 `AppT` t2

  clauses <- mapM mkClause $ flatten ress

  pure
    [ SigD fnName ((ConT ''Route `AppT` ConT appName) `arrow` ConT ''Text)
    , FunD fnName clauses
    ]

  where
    toText s = VarE 'T.pack `AppE` LitE (StringL s)
    isDynamic Dynamic {} = True
    isDynamic Static {} = False
    parentPieceWrapper (parentName, pieces) nestedPat = ConP (mkName parentName) $ mconcat
      [ replicate (length $ filter isDynamic pieces) WildP
      , [nestedPat]
      ]
    mkClause fr@FlatResource{..} = do
      let clausePattern = foldr parentPieceWrapper (RecP (mkName frName) []) frParentPieces
      pure $ Clause
        [clausePattern]
        (NormalB $ toText $ renderPattern fr)
        []
#endif


renderPattern :: FlatResource String -> String
renderPattern FlatResource {..} =
  concat $
    concat
      [ if frCheck then [] else ["!"]
      , case formattedParentPieces <> concatMap routePortionSection frPieces of
          [] -> case frDispatch of
            Subsite {} -> []
            _ -> ["/"]
          pieces -> pieces
      , case frDispatch of
          Methods {..} ->
            case methodsMulti of
              Nothing -> []
              Just t -> ["/+", t]
          Subsite {} -> ["/**"]
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
  , pathRender :: Route site -> T.Text
  }


{- | This middleware works best when used with `OpenTelemetry.Instrumentation.Wai` middleware.

Note: span code locations reflect this middleware module rather than the
Yesod handler source location. Propagating 'HasCallStack' through Yesod's
handler monad would require upstream changes to the @yesod-core@ library.
-}
openTelemetryYesodMiddleware
  :: (ToTypedContent res)
  => RouteRenderer site
  -> HandlerFor site res
  -> HandlerFor site res
openTelemetryYesodMiddleware rr m = do
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
                  Just (unkey SC.http_route, toAttribute $ pathRender rr r)
              , do
                  r <- mr
                  Just ("http.handler", toAttribute $ nameRender rr r)
              , do
                  ff <- lookup "X-Forwarded-For" $ requestHeaders req
                  case httpOption semanticsOptions of
                    Stable -> Just (unkey SC.client_address, toAttribute $ T.decodeUtf8 ff)
                    StableAndOld -> Just (unkey SC.client_address, toAttribute $ T.decodeUtf8 ff)
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
  let method_ = T.decodeUtf8 $ requestMethod req
      yesodSpanName = case mr of
        Just r -> method_ <> " " <> pathRender rr r
        Nothing -> method_
  case mspan of
    Nothing -> do
      eResult <- inSpan' yesodSpanName args $ \_s -> do
        catch (Right <$> m) $ \e -> do
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
      withException m $ \ex -> do
        when (shouldMarkException ex) $ do
          addAttributes waiSpan (H.singleton (unkey SC.error_type) (toAttribute (exceptionTypeName ex)))
          recordException waiSpan mempty Nothing ex
          setStatus waiSpan $ Error $ T.pack $ displayException ex


exceptionTypeName :: SomeException -> Text
exceptionTypeName (SomeException e) = T.pack $ show $ typeOf e


shouldMarkException :: SomeException -> Bool
shouldMarkException = maybe True isInternalError . fromException


-- We want to mark the span as an error if it's an InternalError, the other
-- HCError values are 4xx status codes which don't really count as a server
-- error in OpenTelemetry spec parlance.
isInternalError :: HandlerContents -> Bool
isInternalError = \case
  HCError (InternalError _) -> True
  _ -> False
