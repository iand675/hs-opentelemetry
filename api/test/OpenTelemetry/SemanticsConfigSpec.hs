module OpenTelemetry.SemanticsConfigSpec where

import OpenTelemetry.SemanticsConfig
import System.Environment
import Test.Hspec


envVarName :: String
envVarName = "OTEL_SEMCONV_STABILITY_OPT_IN"


spec :: Spec
spec = do
  describe "SemanticsConfig" $ do
    describe "HttpOption" $ do
      it "defaults to 'Old' when env var has no value" $ do
        unsetEnv envVarName
        semanticsOptions <- getSemanticsOptions'
        httpOption semanticsOptions `shouldBe` Old
      mapM_
        ( \(envVarVal, expectedVal) ->
            it ("returns " ++ show expectedVal ++ " when env var is " ++ show envVarVal) $ do
              setEnv envVarName envVarVal
              semanticsOptions <- getSemanticsOptions'
              httpOption semanticsOptions `shouldBe` expectedVal
        )
        [ ("http", Stable)
        , ("http/du", Old) -- intentionally similar to both "http/dup" and "http"
        , ("http/dup", StableAndOld)
        , ("http/dup,http", StableAndOld)
        , ("http,http/dup", StableAndOld)
        , ("http,something-random,http/dup", StableAndOld)
        ]
    context "memoization" $ do
      it "works" $ do
        setEnv envVarName "http"
        semanticsOptions <- getSemanticsOptions
        httpOption semanticsOptions `shouldBe` Stable
      it ("does not change when " ++ envVarName ++ " changes") $ do
        setEnv envVarName "http"
        semanticsOptions <- getSemanticsOptions
        setEnv envVarName "http/dup"
        semanticsOptions <- getSemanticsOptions
        httpOption semanticsOptions `shouldBe` Stable -- and not StableAndOld because of memoization
