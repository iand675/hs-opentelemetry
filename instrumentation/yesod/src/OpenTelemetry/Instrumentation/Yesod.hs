{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{- |
[New HTTP semantic conventions have been declared stable.](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan) Opt-in by setting the environment variable OTEL_SEMCONV_STABILITY_OPT_IN to
- "http" - to use the stable conventions
- "http/dup" - to emit both the old and the stable conventions
Otherwise, the old conventions will be used. The stable conventions will replace the old conventions in the next major release of this library.
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
) where

import Control.Monad (when)
import qualified Data.HashMap.Strict as H
import Data.List (intercalate)
import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Language.Haskell.TH.Syntax
import Lens.Micro
import Network.Wai (requestHeaders)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Instrumentation.Wai (requestContext)
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
    pure $ makeTracer tp "hs-opentelemetry-instrumentation-yesod" tracerOptions


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
  , pathRender :: Route site -> T.Text
  }


-- TODO figure out a way to get better code locations for these spans.

-- | This middleware works best when used with `OpenTelemetry.Instrumentation.Wai` middleware.
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
  case mspan of
    Nothing -> do
      eResult <- inSpan' (maybe "notFound" (nameRender rr) mr) args $ \_s -> do
        catch (Right <$> m) $ \e -> do
          when (isInternalError e) $ throwIO e
          pure (Left (e :: HandlerContents))
      case eResult of
        Left hc -> throwIO hc
        Right normal -> pure normal
    Just waiSpan -> do
      addAttributes waiSpan sharedAttributes


-- We want to mark the span as an error if it's an InternalError, the other
-- HCError values are 4xx status codes which don't really count as a server
-- error in OpenTelemetry spec parlance.
isInternalError :: HandlerContents -> Bool
isInternalError = \case
  HCError (InternalError _) -> True
  _ -> False
