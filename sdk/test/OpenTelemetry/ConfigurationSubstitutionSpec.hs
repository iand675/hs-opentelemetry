{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.ConfigurationSubstitutionSpec (spec, emptyEnvironmentHelper) where

import Control.Exception (bracket)
import Control.Monad (forM_)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Configuration.Parse (ConfigParseError (..), parseConfigBytes)
import OpenTelemetry.Configuration.Types
import System.Environment (getEnvironment, getExecutablePath, lookupEnv, setEnv, unsetEnv)
import System.Exit (ExitCode (..))
import System.Process (CreateProcess (..), proc, readCreateProcessWithExitCode)
import Test.Hspec


-- OTel 1.62.0 configuration/data-model.md#environment-variable-substitution.
-- Exercise the public parser so YAML structure and scalar resolution are tested
-- together with substitution, rather than just checking string replacements.
spec :: Spec
spec = describe "configuration environment substitution" $ around_ (withEnvironment testEnvironment) $ do
  forM_ stringCases $ \(input, expected) ->
    it ("resolves scalar " <> T.unpack input) $ expectAttribute (attributeYaml input) expected

  forM_ ["'", "\""] $ \quote -> do
    forM_ [("STRING", "value"), ("BOOL", "true"), ("INT", "1"), ("FLOAT", "1.1"), ("HEX", "0xdeadbeef")] $ \(name, expected) ->
      it ("preserves string coercion for " <> T.unpack (quote <> reference name <> quote)) $ do
        result <- parseConfigBytes ("file_format: " <> quote <> reference name <> quote)
        fmap configFileFormat result `shouldBe` Right expected

  it "resolves an unquoted boolean after substitution" $ do
    result <- parseConfigBytes ("disabled: " <> reference "BOOL")
    fmap configDisabled result `shouldBe` Right (Just True)

  it "resolves an unquoted integer after substitution" $ do
    result <- parseConfigBytes ("attribute_limits:\n  attribute_count_limit: " <> reference "INT")
    fmap (fmap alAttributeCountLimit . configAttributeLimits) result `shouldBe` Right (Just (Just 1))

  forM_ [("FLOAT", 1.1), ("HEX", 3735928559)] $ \(name, expected) ->
    it ("resolves unquoted numeric " <> T.unpack name <> " after substitution") $ do
      result <- parseConfigBytes ("tracer_provider:\n  sampler:\n    trace_id_ratio_based:\n      ratio: " <> reference name)
      fmap (fmap tpSampler . configTracerProvider) result
        `shouldBe` Right (Just (Just (SamplerTraceIdRatioBased (TraceIdRatioSamplerConfig expected))))

  it "resolves an undefined plain value as null and a quoted value as an empty string" $ do
    plain <- parseConfigBytes ("file_format: " <> reference "MISSING")
    quoted <- parseConfigBytes ("file_format: '" <> reference "MISSING" <> "'")
    fmap configFileFormat plain `shouldBe` Right "1.0"
    fmap configFileFormat quoted `shouldBe` Right ""

  it "uses a default when the environment variable exists but is empty" $ do
    -- base's setEnv unsets empty values. A child process lets us supply an
    -- actually empty environment entry, without adding a POSIX-only test API.
    executable <- getExecutablePath
    environment <- getEnvironment
    (status, output, errors) <-
      readCreateProcessWithExitCode
        (proc executable ["--config-empty-env-helper"])
          { env = Just (("HS_OTEL_CONFIG_EMPTY", "") : filter ((/= "HS_OTEL_CONFIG_EMPTY") . fst) environment)
          }
        ""
    (status, output, errors) `shouldBe` (ExitSuccess, "fallback\n", "")

  it "allows an environment variable named env to have a default" $
    withEnvironment [("env", Nothing)] $ do
      expectAttribute (attributeYaml "${env:-fallback}") "fallback"
      expectAttribute (attributeYaml "${env:env:-fallback}") "fallback"

  it "does not substitute mapping keys, including invalid reference syntax" $ do
    result <- parseConfigBytes "resource:\n  attributes:\n    '${HS_OTEL_CONFIG_STRING}': keep\n    '${1INVALID}': also-keep\n"
    fmap attributes result
      `shouldBe` Right (Map.fromList [("${HS_OTEL_CONFIG_STRING}", "keep"), ("${1INVALID}", "also-keep")])

  forM_ ["original\n    injected: surprise", "{injected: true}", "[1, 2]", "value\n---\ndisabled: true", "value # comment", "\"'\\ λ"] $ \replacement ->
    it ("keeps replacement data inside one scalar: " <> show replacement) $
      withEnvironment [("HS_OTEL_CONFIG_STRING", Just (T.unpack replacement))] $
        expectAttribute (attributeYaml (reference "STRING")) replacement

  forM_ ["|", ">"] $ \style ->
    it ("keeps block scalar style " <> T.unpack style <> " as a string") $ do
      result <- parseConfigBytes ("file_format: " <> style <> "-\n  " <> reference "BOOL")
      fmap configFileFormat result `shouldBe` Right "true"

  it "substitutes sequence elements and nested mappings" $ do
    result <- parseConfigBytes "propagator:\n  composite: ['${HS_OTEL_CONFIG_STRING}', '${HS_OTEL_CONFIG_MISSING:-baggage}']\n"
    fmap (fmap propagatorComposite . configPropagator) result `shouldBe` Right (Just (Just ["value", "baggage"]))

  it "preserves quoted flow-style mapping values" $
    expectAttribute "resource: {attributes: {value: '${HS_OTEL_CONFIG_STRING}'}}" "value"

  it "does not substitute YAML comments" $
    expectAttribute (attributeYaml "keep # ${1INVALID}") "keep"

  it "handles aliases of scalar keys and values according to their use site" $ do
    result <- parseConfigBytes "resource:\n  attributes:\n    &key '${HS_OTEL_CONFIG_STRING}': keep\n    from-key: *key\n    value: &value '${HS_OTEL_CONFIG_STRING}'\n    *value: also-keep\n"
    fmap attributes result
      `shouldBe` Right (Map.fromList [("${HS_OTEL_CONFIG_STRING}", "also-keep"), ("from-key", "value"), ("value", "value")])

  it "preserves aliases of mappings and YAML merges" $ do
    result <- parseConfigBytes "attribute_limits: &limits\n  attribute_count_limit: ${HS_OTEL_CONFIG_INT}\ntracer_provider:\n  limits:\n    <<: *limits\n    event_count_limit: ${HS_OTEL_CONFIG_INT}\n"
    fmap (fmap tpLimits . configTracerProvider) result
      `shouldBe` Right (Just (Just (SpanLimitsConfig Nothing (Just 1) (Just 1) Nothing Nothing Nothing)))

  it "does not reuse a scalar anchor after the name is rebound to a mapping" $ do
    result <- parseConfigBytes "file_format: &reused '${HS_OTEL_CONFIG_STRING}'\nattribute_limits: &reused\n  attribute_count_limit: ${HS_OTEL_CONFIG_INT}\ntracer_provider:\n  limits: *reused\n"
    fmap (fmap tpLimits . configTracerProvider) result
      `shouldBe` Right (Just (Just (SpanLimitsConfig Nothing (Just 1) Nothing Nothing Nothing Nothing)))

  it "still rejects unknown aliases and multiple documents" $ do
    expectFailure "resource: *unknown"
    expectFailure "file_format: '1.0'\n---\nfile_format: '1.0'"

  forM_ ["${1INVALID}", "${HS_OTEL_CONFIG_STRING:?error}", "${HS_OTEL_CONFIG_STRING:bad}", "${HS_OTEL_CONFIG_STRING-default}", "${ HS_OTEL_CONFIG_STRING}", "${HS_OTEL_CONFIG_STRING }", "${HS_OTEL_CONFIG_STRING$}", "${env:}", "${sys:HS_OTEL_CONFIG_STRING}"] $ \invalid ->
    it ("rejects invalid references without returning a partial config: " <> T.unpack invalid) $ do
      result <- parseConfigBytes ("disabled: true\n" <> attributeYaml ("'" <> invalid <> "'"))
      case result of
        Left (ConfigValidationError _) -> pure ()
        other -> expectationFailure ("expected substitution error, got " <> show other)


stringCases :: [(Text, Text)]
stringCases =
  [ (reference "STRING", "value")
  , ("${env:HS_OTEL_CONFIG_STRING}", "value")
  , (reference "INJECT", "value\nkey:value")
  , ("foo " <> reference "STRING" <> " " <> reference "FLOAT", "foo value 1.1")
  , (reference "MISSING", "")
  , ("${HS_OTEL_CONFIG_MISSING:-fallback}", "fallback")
  , (reference "REPLACE", "${HS_OTEL_CONFIG_OTHER}")
  , ("${HS_OTEL_CONFIG_MISSING:-" <> reference "STRING" <> "}", reference "STRING")
  , ("$" <> reference "STRING", reference "STRING")
  , ("$$" <> reference "STRING", "$value")
  , ("$$$" <> reference "STRING", "$" <> reference "STRING")
  , ("$${HS_OTEL_CONFIG_STRING:-fallback}", "${HS_OTEL_CONFIG_STRING:-fallback}")
  , ("$${HS_OTEL_CONFIG_STRING:-" <> reference "STRING" <> "}", "${HS_OTEL_CONFIG_STRING:-value}")
  , ("${HS_OTEL_CONFIG_MISSING:-$" <> reference "MISSING" <> "}", "${HS_OTEL_CONFIG_MISSING:-" <> reference "MISSING" <> "}")
  , (reference "WITH_ESCAPE", "value$$")
  , ("a $$ b", "a $ b")
  , ("a $ b", "a $ b")
  , ("'${env:HS_OTEL_CONFIG_MISSING:-}'", "")
  , ("'$${1INVALID}'", "${1INVALID}")
  , ("'${}'", "${}")
  , ("'${UNCLOSED'", "${UNCLOSED")
  ]


reference :: Text -> Text
reference name = "${HS_OTEL_CONFIG_" <> name <> "}"


testEnvironment :: [(String, Maybe String)]
testEnvironment =
  [ ("HS_OTEL_CONFIG_STRING", Just "value")
  , ("HS_OTEL_CONFIG_BOOL", Just "true")
  , ("HS_OTEL_CONFIG_INT", Just "1")
  , ("HS_OTEL_CONFIG_FLOAT", Just "1.1")
  , ("HS_OTEL_CONFIG_HEX", Just "0xdeadbeef")
  , ("HS_OTEL_CONFIG_INJECT", Just "value\nkey:value")
  , ("HS_OTEL_CONFIG_OTHER", Just "never use this value")
  , ("HS_OTEL_CONFIG_REPLACE", Just "${HS_OTEL_CONFIG_OTHER}")
  , ("HS_OTEL_CONFIG_WITH_ESCAPE", Just "value$$")
  , ("HS_OTEL_CONFIG_MISSING", Nothing)
  ]


withEnvironment :: [(String, Maybe String)] -> IO a -> IO a
withEnvironment replacements action = bracket save restore (const (restore replacements >> action))
  where
    save = mapM (\(name, _) -> (,) name <$> lookupEnv name) replacements
    restore = mapM_ $ \case
      (name, Nothing) -> unsetEnv name
      (name, Just value) -> setEnv name value


attributeYaml :: Text -> Text
attributeYaml scalar = "resource:\n  attributes:\n    value: " <> scalar <> "\n"


attributes :: OTelConfiguration -> Map.Map Text Text
attributes cfg = maybe Map.empty id (resourceAttributes =<< configResource cfg)


expectAttribute :: Text -> Text -> Expectation
expectAttribute input expected = do
  result <- parseConfigBytes input
  fmap attributes result `shouldBe` Right (Map.singleton "value" expected)


expectFailure :: Text -> Expectation
expectFailure input =
  parseConfigBytes input >>= \case
    Left _ -> pure ()
    Right cfg -> expectationFailure ("expected parse error, got " <> show cfg)


-- Invoked before the test runner initializes its providers or environment.
emptyEnvironmentHelper :: IO ()
emptyEnvironmentHelper = do
  result <- parseConfigBytes "file_format: '${HS_OTEL_CONFIG_EMPTY:-fallback}'"
  case result of
    Left err -> error (show err)
    Right cfg -> putStrLn (T.unpack (configFileFormat cfg))
