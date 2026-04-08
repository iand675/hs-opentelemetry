module OpenTelemetry.SemanticsConfigSpec where

import OpenTelemetry.SemanticsConfig
import System.Environment
import Test.Hspec


envVarName :: String
envVarName = "OTEL_SEMCONV_STABILITY_OPT_IN"


spec :: Spec
spec = do
  -- Semantic conventions §Stable vs Experimental: OTEL_SEMCONV_STABILITY_OPT_IN
  -- https://opentelemetry.io/docs/specs/semconv/general/stable-vs-experimental/
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

    describe "databaseOption" $ do
      it "defaults to 'Old' when env var has no value" $ do
        unsetEnv envVarName
        opts <- getSemanticsOptions'
        databaseOption opts `shouldBe` Old

      it "defaults to 'Old' when only http is set" $ do
        setEnv envVarName "http"
        opts <- getSemanticsOptions'
        databaseOption opts `shouldBe` Old

      mapM_
        ( \(envVarVal, expectedDb) ->
            it ("returns " ++ show expectedDb ++ " for database when env var is " ++ show envVarVal) $ do
              setEnv envVarName envVarVal
              opts <- getSemanticsOptions'
              databaseOption opts `shouldBe` expectedDb
        )
        [ ("database", Stable)
        , ("database/dup", StableAndOld)
        , ("http,database", Stable)
        , ("http/dup,database/dup", StableAndOld)
        , ("database,http", Stable)
        ]

    describe "independent http and database options" $ do
      it "http=Stable, database=Old when only http set" $ do
        setEnv envVarName "http"
        opts <- getSemanticsOptions'
        httpOption opts `shouldBe` Stable
        databaseOption opts `shouldBe` Old

      it "http=Old, database=Stable when only database set" $ do
        setEnv envVarName "database"
        opts <- getSemanticsOptions'
        httpOption opts `shouldBe` Old
        databaseOption opts `shouldBe` Stable

      it "both Stable when both set" $ do
        setEnv envVarName "http,database"
        opts <- getSemanticsOptions'
        httpOption opts `shouldBe` Stable
        databaseOption opts `shouldBe` Stable

      it "http=StableAndOld, database=Stable for mixed" $ do
        setEnv envVarName "http/dup,database"
        opts <- getSemanticsOptions'
        httpOption opts `shouldBe` StableAndOld
        databaseOption opts `shouldBe` Stable

    describe "lookupStability (generalized)" $ do
      it "returns Old for unknown keys when env var is unset" $ do
        unsetEnv envVarName
        opts <- getSemanticsOptions'
        lookupStability "messaging" opts `shouldBe` Old
        lookupStability "rpc" opts `shouldBe` Old

      it "returns Stable for a custom key when present" $ do
        setEnv envVarName "messaging"
        opts <- getSemanticsOptions'
        lookupStability "messaging" opts `shouldBe` Stable
        lookupStability "http" opts `shouldBe` Old

      it "returns StableAndOld for custom/dup key" $ do
        setEnv envVarName "messaging/dup"
        opts <- getSemanticsOptions'
        lookupStability "messaging" opts `shouldBe` StableAndOld

      it "handles multiple custom keys" $ do
        setEnv envVarName "http,messaging/dup,database"
        opts <- getSemanticsOptions'
        lookupStability "http" opts `shouldBe` Stable
        lookupStability "messaging" opts `shouldBe` StableAndOld
        lookupStability "database" opts `shouldBe` Stable
        lookupStability "rpc" opts `shouldBe` Old

      it "trims whitespace around custom keys" $ do
        setEnv envVarName " messaging , http/dup "
        opts <- getSemanticsOptions'
        lookupStability "messaging" opts `shouldBe` Stable
        lookupStability "http" opts `shouldBe` StableAndOld

    -- Implementation-specific: memoized semantics options snapshot
    -- https://opentelemetry.io/docs/specs/semconv/general/stable-vs-experimental/
    context "memoization" $ do
      it "returns a consistent value across calls" $ do
        opts1 <- getSemanticsOptions
        opts2 <- getSemanticsOptions
        httpOption opts1 `shouldBe` httpOption opts2
      it ("does not change when " ++ envVarName ++ " changes") $ do
        baseline <- getSemanticsOptions
        let baselineHttp = httpOption baseline
        setEnv envVarName "http/dup"
        opts <- getSemanticsOptions
        httpOption opts `shouldBe` baselineHttp
