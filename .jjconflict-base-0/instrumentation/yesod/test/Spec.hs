{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ViewPatterns #-}

module Main where

import Control.Exception (ErrorCall (..), SomeException (..), toException)
import Data.IORef
import Data.Text (Text)
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types (movedPermanently301, ok200)
import Network.Socket (SockAddr (..))
import Network.Wai (defaultRequest, responseLBS)
import Network.Wai.Internal (Request (..), ResponseReceived (..))
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware')
import OpenTelemetry.Instrumentation.Yesod
import OpenTelemetry.Trace.Core
import System.Environment (setEnv)
import Test.Hspec
import TestApp.ApiSub
import Yesod.Core
import Yesod.Core.Types (ErrorResponse (..), HandlerContents (..))
import Yesod.Routes.TH.Types (Dispatch (..), FlatResource (..), Piece (..))


-- Main test app
data TestApp = TestApp


getApiSub :: TestApp -> ApiSub
getApiSub _ = ApiSub


mkYesodData
  "TestApp"
  [parseRoutes|
/ HomeR GET
/user/#Int UserR GET
/api ApiR ApiSub getApiSub
|]


mkRouteToRenderer
  ''TestApp
  [parseRoutes|
/ HomeR GET
/user/#Int UserR GET
/api ApiR ApiSub getApiSub
|]


mkRouteToPattern
  ''TestApp
  [parseRoutes|
/ HomeR GET
/user/#Int UserR GET
/api ApiR ApiSub getApiSub
|]


instance Yesod TestApp where
  yesodMiddleware =
    openTelemetryYesodMiddleware
      RouteRenderer
        { nameRender = routeToRenderer
        , pathRender = routeToPattern
        }


getHomeR :: HandlerFor TestApp Html
getHomeR = return ""


getUserR :: Int -> HandlerFor TestApp Html
getUserR _ = return ""


mkYesodDispatch
  "TestApp"
  [parseRoutes|
/ HomeR GET
/user/#Int UserR GET
/api ApiR ApiSub getApiSub
|]


main :: IO ()
main = do
  setEnv "OTEL_SEMCONV_STABILITY_OPT_IN" "http"
  hspec spec


spec :: Spec
spec = do
  describe "renderPattern" $ do
    it "renders a simple root route" $ do
      let fr =
            FlatResource
              { frParentPieces = []
              , frName = "HomeR"
              , frPieces = []
              , frDispatch = Methods Nothing ["GET"]
              , frCheck = True
              }
      renderPattern fr `shouldBe` "/"

    it "renders a route with static and dynamic pieces" $ do
      let fr =
            FlatResource
              { frParentPieces = []
              , frName = "UserR"
              , frPieces = [Static "user", Dynamic "Int"]
              , frDispatch = Methods Nothing ["GET"]
              , frCheck = True
              }
      renderPattern fr `shouldBe` "/user/#{Int}"

    it "renders a route with parent pieces" $ do
      let fr =
            FlatResource
              { frParentPieces = [("ApiR", [Static "api", Static "v1"])]
              , frName = "ItemR"
              , frPieces = [Dynamic "Int"]
              , frDispatch = Methods Nothing ["GET", "PUT"]
              , frCheck = True
              }
      renderPattern fr `shouldBe` "/api/v1/#{Int}"

    it "renders unchecked route with ! prefix" $ do
      let fr =
            FlatResource
              { frParentPieces = []
              , frName = "RawR"
              , frPieces = [Static "raw"]
              , frDispatch = Methods Nothing ["GET"]
              , frCheck = False
              }
      renderPattern fr `shouldBe` "!/raw"

    it "renders multi-piece route with suffix" $ do
      let fr =
            FlatResource
              { frParentPieces = []
              , frName = "FileR"
              , frPieces = [Static "files"]
              , frDispatch = Methods (Just "Texts") ["GET"]
              , frCheck = True
              }
      renderPattern fr `shouldBe` "/files/+Texts"

    it "renders subsite route with /** wildcard" $ do
      let fr =
            FlatResource
              { frParentPieces = []
              , frName = "ApiR"
              , frPieces = [Static "api"]
              , frDispatch = Subsite "ApiSub" "getApiSub"
              , frCheck = True
              }
      renderPattern fr `shouldBe` "/api/**"

    it "renders subsite at root with /** wildcard" $ do
      let fr =
            FlatResource
              { frParentPieces = []
              , frName = "SubR"
              , frPieces = []
              , frDispatch = Subsite "MySub" "getMySub"
              , frCheck = True
              }
      renderPattern fr `shouldBe` "/**"

  describe "exceptionTypeName" $ do
    it "returns the type name of an IOException" $ do
      let e = toException (userError "test")
      exceptionTypeName e `shouldBe` "IOException"

    it "returns the type name of an ErrorCall" $ do
      let e = toException (ErrorCall "boom")
      exceptionTypeName e `shouldBe` "ErrorCall"

  describe "isInternalError" $ do
    it "returns True for HCError (InternalError _)" $
      isInternalError (HCError (InternalError "oops")) `shouldBe` True

    it "returns False for HCError (NotFound)" $
      isInternalError (HCError NotFound) `shouldBe` False

    it "returns False for HCRedirect" $
      isInternalError (HCRedirect movedPermanently301 "/new") `shouldBe` False

  describe "shouldMarkException" $ do
    it "returns True for non-HandlerContents exceptions" $ do
      let e = toException (userError "io-error")
      shouldMarkException e `shouldBe` True

    it "returns True for InternalError wrapped as exception" $ do
      let e = toException (HCError (InternalError "500"))
      shouldMarkException e `shouldBe` True

    it "returns False for NotFound wrapped as exception" $ do
      let e = toException (HCError NotFound)
      shouldMarkException e `shouldBe` False

  describe "TH route renderers" $ do
    it "routeToRenderer maps HomeR" $
      routeToRenderer HomeR `shouldBe` "HomeR"

    it "routeToRenderer maps UserR" $
      routeToRenderer (UserR 42) `shouldBe` "UserR"

    it "routeToRenderer maps subsite route ApiR" $
      routeToRenderer (ApiR ApiSubHomeR) `shouldBe` "ApiR"

    it "routeToPattern maps HomeR to /" $
      routeToPattern HomeR `shouldBe` "/"

    it "routeToPattern maps UserR to /user/#{Int}" $
      routeToPattern (UserR 42) `shouldBe` "/user/#{Int}"

    it "routeToPattern maps subsite ApiR to /api/**" $
      routeToPattern (ApiR ApiSubHomeR) `shouldBe` "/api/**"

  describe "WAI + Yesod middleware integration" $ do
    it "adds http.route attribute to WAI span" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let waiMw = newOpenTelemetryWaiMiddleware' tp
      app <- toWaiAppPlain TestApp
      let fullApp = waiMw app
          req =
            defaultRequest
              { requestMethod = "GET"
              , rawPathInfo = "/"
              , requestHeaders = [("Host", "localhost")]
              , remoteHost = SockAddrInet 12345 0x0100007f
              , vault = Vault.empty
              }
      _ <- fullApp req $ \_ -> pure ResponseReceived
      _ <- shutdownTracerProvider tp Nothing
      spans <- readIORef ref
      case spans of
        [] -> expectationFailure "no spans recorded"
        (s : _) -> do
          hot <- readIORef (spanHot s)
          lookupAttribute (hotAttributes hot) (unkey SC.http_route)
            `shouldBe` Just (AttributeValue (TextAttribute "/"))
          lookupAttribute (hotAttributes hot) "http.handler"
            `shouldBe` Just (AttributeValue (TextAttribute "HomeR"))
          lookupAttribute (hotAttributes hot) "http.framework"
            `shouldBe` Just (AttributeValue (TextAttribute "yesod"))

    it "uses route pattern for UserR" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let waiMw = newOpenTelemetryWaiMiddleware' tp
      app <- toWaiAppPlain TestApp
      let fullApp = waiMw app
          req =
            defaultRequest
              { requestMethod = "GET"
              , rawPathInfo = "/user/42"
              , pathInfo = ["user", "42"]
              , requestHeaders = [("Host", "localhost")]
              , remoteHost = SockAddrInet 12345 0x0100007f
              , vault = Vault.empty
              }
      _ <- fullApp req $ \_ -> pure ResponseReceived
      _ <- shutdownTracerProvider tp Nothing
      spans <- readIORef ref
      case spans of
        [] -> expectationFailure "no spans recorded"
        (s : _) -> do
          hot <- readIORef (spanHot s)
          lookupAttribute (hotAttributes hot) (unkey SC.http_route)
            `shouldBe` Just (AttributeValue (TextAttribute "/user/#{Int}"))

    it "uses /** pattern for subsite routes" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let waiMw = newOpenTelemetryWaiMiddleware' tp
      app <- toWaiAppPlain TestApp
      let fullApp = waiMw app
          req =
            defaultRequest
              { requestMethod = "GET"
              , rawPathInfo = "/api"
              , pathInfo = ["api"]
              , requestHeaders = [("Host", "localhost")]
              , remoteHost = SockAddrInet 12345 0x0100007f
              , vault = Vault.empty
              }
      _ <- fullApp req $ \_ -> pure ResponseReceived
      _ <- shutdownTracerProvider tp Nothing
      spans <- readIORef ref
      case spans of
        [] -> expectationFailure "no spans recorded"
        (s : _) -> do
          hot <- readIORef (spanHot s)
          lookupAttribute (hotAttributes hot) (unkey SC.http_route)
            `shouldBe` Just (AttributeValue (TextAttribute "/api/**"))
          lookupAttribute (hotAttributes hot) "http.handler"
            `shouldBe` Just (AttributeValue (TextAttribute "ApiR"))

    it "uses /** pattern for subsite nested routes" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let waiMw = newOpenTelemetryWaiMiddleware' tp
      app <- toWaiAppPlain TestApp
      let fullApp = waiMw app
          req =
            defaultRequest
              { requestMethod = "GET"
              , rawPathInfo = "/api/item/7"
              , pathInfo = ["api", "item", "7"]
              , requestHeaders = [("Host", "localhost")]
              , remoteHost = SockAddrInet 12345 0x0100007f
              , vault = Vault.empty
              }
      _ <- fullApp req $ \_ -> pure ResponseReceived
      _ <- shutdownTracerProvider tp Nothing
      spans <- readIORef ref
      case spans of
        [] -> expectationFailure "no spans recorded"
        (s : _) -> do
          hot <- readIORef (spanHot s)
          lookupAttribute (hotAttributes hot) (unkey SC.http_route)
            `shouldBe` Just (AttributeValue (TextAttribute "/api/**"))
