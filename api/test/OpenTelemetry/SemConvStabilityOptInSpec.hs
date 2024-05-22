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
    it "defaults to 'Old' when env var has incorrect value" $ do
      setEnv envVarName "http/du" -- intentionally similar to "http/dup" and "http"
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Old
    it "is 'Stable' when env var is 'http'" $ do
      setEnv envVarName "http"
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Stable
    it "is 'Both' when env var is 'http/dup'" $ do
      setEnv envVarName "http/dup"
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Both
    it "is 'Both' when env var is 'http/dup,http'" $ do
      setEnv envVarName "http/dup,http"
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Both
    it "is 'Both' when env var is 'http,http/dup'" $ do
      setEnv envVarName "http,http/dup"
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Both
    it "is 'Both' when env var is 'http,something-random,http/dup'" $ do
      setEnv envVarName "http,http/dup"
      semConvStabilityOptIn <- getSemConvStabilityOptIn
      semConvStabilityOptIn `shouldBe` Both
