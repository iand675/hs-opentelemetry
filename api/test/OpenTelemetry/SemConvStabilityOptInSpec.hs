module OpenTelemetry.SemConvStabilityOptInSpec where

import OpenTelemetry.SemConvStabilityOptIn
import System.Environment
import Test.Hspec


envVarName :: String
envVarName = "OTEL_SEMCONV_STABILITY_OPT_IN"


spec :: Spec
spec = do
  describe "SemConvStabilityOptIn" $ do
    it "defaults to 'Old' when env var has no value" $ do
      unsetEnv envVarName
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Old
    mapM_
      ( \(envVarVal, expectedVal) ->
          it ("returns '" ++ show expectedVal ++ "' when env var is '" ++ show envVarVal ++ "'") $ do
            setEnv envVarName envVarVal
            semConvStabilityOptIn <- getSemConvStabilityOptIn
            semConvStabilityOptIn `shouldBe` expectedVal
      )
      [ ("http", Stable)
      , ("http/du", Old) -- intentionally similar to both "http/dup" and "http"
      , ("http/dup", Both)
      , ("http/dup,http", Both)
      , ("http,http/dup", Both)
      , ("http,something-random,http/dup", Both)
      ]
