{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.ConfigurationSpec (spec) where

import Control.Exception (bracket, bracket_)
import qualified Data.Map.Strict as Map
import Data.Text (Text, pack)
import OpenTelemetry.Attributes (lookupAttribute, toAttribute)
import OpenTelemetry.Configuration.Create (OTelComponents (..), createFromConfig)
import OpenTelemetry.Configuration.Parse (ConfigParseError (..), parseConfigBytes, parseConfigFile)
import OpenTelemetry.Configuration.Types
import OpenTelemetry.Propagator (Propagator (..))
import OpenTelemetry.Resource (getMaterializedResourcesAttributes)
import OpenTelemetry.Trace (detectSpanLimits)
import OpenTelemetry.Trace.Core (SpanLimits (..), getTracerProviderResources)
import System.Environment (lookupEnv, setEnv, unsetEnv)
import Test.Hspec


spec :: Spec
spec = do
  -- File configuration: declarative SDK configuration (YAML)
  -- https://opentelemetry.io/docs/specs/otel/configuration/
  describe "OpenTelemetry.Configuration.Parse.parseConfigBytes" $ do
    -- Configuration file_format and empty document defaults
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses minimal valid config with defaults elsewhere" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> do
          configFileFormat cfg `shouldBe` "1.0"
          cfg `shouldBe` emptyConfiguration

    -- Configuration: tracer_provider processors and sampler
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses full tracer_provider with batch processor and always_on sampler" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  processors:\n\
            \    - batch:\n\
            \        schedule_delay: 5000\n\
            \        exporter:\n\
            \          otlp_http:\n\
            \            endpoint: \"http://localhost:4318\"\n\
            \  sampler:\n\
            \    always_on: {}\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configTracerProvider cfg of
          Nothing -> expectationFailure "expected configTracerProvider"
          Just tp -> do
            case tpProcessors tp of
              Nothing -> expectationFailure "expected tpProcessors"
              Just procs -> do
                length procs `shouldBe` 1
                case procs of
                  (SpanProcessorBatch bsp : _) -> do
                    bspScheduleDelay bsp `shouldBe` Just 5000
                    case bspExporter bsp of
                      SpanExporterOtlpHttp otlp ->
                        otlpCfgEndpoint otlp `shouldBe` Just "http://localhost:4318"
                      other ->
                        expectationFailure $ "expected SpanExporterOtlpHttp, got " ++ show other
                  _ ->
                    expectationFailure "expected SpanProcessorBatch as first processor"
            tpSampler tp `shouldBe` Just SamplerAlwaysOn

    -- Configuration: top-level disabled flag
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses disabled: true" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \disabled: true\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> configDisabled cfg `shouldBe` Just True

    -- Configuration: resource.attributes map
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses resource attributes map" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \resource:\n\
            \  attributes:\n\
            \    service.name: my-service\n\
            \    service.version: \"1.0\"\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configResource cfg of
          Nothing -> expectationFailure "expected configResource"
          Just res -> case resourceAttributes res of
            Nothing -> expectationFailure "expected resourceAttributes"
            Just attrs -> do
              Map.lookup "service.name" attrs `shouldBe` Just "my-service"
              Map.lookup "service.version" attrs `shouldBe` Just "1.0"

    -- Implementation-specific: parser surfaces YAML errors as ConfigYamlError
    it "returns ConfigYamlError for invalid YAML" $ do
      let garbage :: Text
          garbage = "this is not : valid ::: yaml [[[\n"
      result <- parseConfigBytes garbage
      case result of
        Right cfg -> expectationFailure $ "expected Left, got Right: " ++ show cfg
        Left err -> case err of
          ConfigYamlError _ -> pure ()
          other -> expectationFailure $ "expected ConfigYamlError, got " ++ show other

    -- Configuration: ${ENV} substitution in config file
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "substitutes environment variables in YAML before parsing" $ do
      let varName :: String
          varName = "HS_OTEL_CONFIG_PARSE_TEST_SUBST_913847"
          yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  processors:\n\
            \    - batch:\n\
            \        exporter:\n\
            \          otlp_http:\n\
            \            endpoint: \"${HS_OTEL_CONFIG_PARSE_TEST_SUBST_913847}\"\n"
      bracketEnv varName "http://example.test:4318" $ do
        result <- parseConfigBytes yaml
        case result of
          Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
          Right cfg -> case configTracerProvider cfg of
            Nothing -> expectationFailure "expected configTracerProvider"
            Just tp -> case tpProcessors tp of
              Nothing -> expectationFailure "expected tpProcessors"
              Just [] -> expectationFailure "expected non-empty processors"
              Just (SpanProcessorBatch bsp : _) -> case bspExporter bsp of
                SpanExporterOtlpHttp otlp ->
                  otlpCfgEndpoint otlp `shouldBe` Just "http://example.test:4318"
                other ->
                  expectationFailure $ "expected SpanExporterOtlpHttp, got " ++ show other
              Just (_ : _) ->
                expectationFailure "expected SpanProcessorBatch as first processor"

    -- Configuration: default value syntax for unset env vars
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "uses default after :- when environment variable is unset" $ do
      let varName :: String
          varName = "HS_OTEL_CONFIG_PARSE_TEST_NONEXISTENT_774019"
          yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  processors:\n\
            \    - batch:\n\
            \        exporter:\n\
            \          otlp_http:\n\
            \            endpoint: \"${"
              <> pack varName
              <> ":-fallback_value}\"\n"
      unsetEnv varName
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configTracerProvider cfg of
          Nothing -> expectationFailure "expected configTracerProvider"
          Just tp -> case tpProcessors tp of
            Nothing -> expectationFailure "expected tpProcessors"
            Just (proc : _) -> case proc of
              SpanProcessorBatch bsp -> case bspExporter bsp of
                SpanExporterOtlpHttp otlp ->
                  otlpCfgEndpoint otlp `shouldBe` Just "fallback_value"
                other ->
                  expectationFailure $ "expected SpanExporterOtlpHttp, got " ++ show other
              other ->
                expectationFailure $ "expected SpanProcessorBatch, got " ++ show other
            Just [] -> expectationFailure "expected non-empty processors"

  describe "parseConfigBytes (branches)" $ do
    -- Configuration: meter_provider.readers (periodic + exporter)
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses meter_provider with periodic reader and otlp_http exporter" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \meter_provider:\n\
            \  readers:\n\
            \    - periodic:\n\
            \        interval: 30000\n\
            \        timeout: 5000\n\
            \        exporter:\n\
            \          otlp_http:\n\
            \            endpoint: \"http://localhost:4318\"\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configMeterProvider cfg of
          Nothing -> expectationFailure "expected configMeterProvider"
          Just mp -> case mpReaders mp of
            Nothing -> expectationFailure "expected mpReaders"
            Just (MetricReaderPeriodic pr : _) -> do
              pmrInterval pr `shouldBe` Just 30000
              pmrTimeout pr `shouldBe` Just 5000
              case pmrExporter pr of
                PushMetricExporterOtlpHttp o ->
                  otlpCfgEndpoint o `shouldBe` Just "http://localhost:4318"
                other -> expectationFailure $ "expected PushMetricExporterOtlpHttp, got " ++ show other
            _ -> expectationFailure "expected MetricReaderPeriodic"

    -- Configuration: logger_provider processors
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses logger_provider with batch processor" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \logger_provider:\n\
            \  processors:\n\
            \    - batch:\n\
            \        schedule_delay: 1000\n\
            \        exporter:\n\
            \          console: {}\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configLoggerProvider cfg of
          Nothing -> expectationFailure "expected configLoggerProvider"
          Just lp -> case lpProcessors lp of
            Nothing -> expectationFailure "expected lpProcessors"
            Just (LogRecordProcessorBatch blp : _) -> do
              blpScheduleDelay blp `shouldBe` Just 1000
              case blpExporter blp of
                LogRecordExporterConsole _ -> pure ()
                other -> expectationFailure $ "expected LogRecordExporterConsole, got " ++ show other
            _ -> expectationFailure "expected LogRecordProcessorBatch"

    -- Configuration: tracer_provider simple processor
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses simple span processor" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  processors:\n\
            \    - simple:\n\
            \        exporter:\n\
            \          console: {}\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configTracerProvider cfg of
          Nothing -> expectationFailure "expected configTracerProvider"
          Just tp -> case tpProcessors tp of
            Nothing -> expectationFailure "expected tpProcessors"
            Just (SpanProcessorSimple ssp : _) -> case sspExporter ssp of
              SpanExporterConsole _ -> pure ()
              other -> expectationFailure $ "expected SpanExporterConsole, got " ++ show other
            _ -> expectationFailure "expected SpanProcessorSimple"

    -- Configuration: parent_based sampler
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses parent_based sampler with nested always_on root" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  sampler:\n\
            \    parent_based:\n\
            \      root:\n\
            \        always_on: {}\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configTracerProvider cfg >>= tpSampler of
          Just (SamplerParentBased pb) -> pbRoot pb `shouldBe` Just SamplerAlwaysOn
          other -> expectationFailure $ "expected SamplerParentBased with root always_on, got " ++ show other

    -- Configuration: trace_id_ratio_based sampler
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses trace_id_ratio_based sampler" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  sampler:\n\
            \    trace_id_ratio_based:\n\
            \      ratio: 0.5\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configTracerProvider cfg >>= tpSampler of
          Just (SamplerTraceIdRatioBased r) -> ratioValue r `shouldBe` 0.5
          other -> expectationFailure $ "expected SamplerTraceIdRatioBased, got " ++ show other

    -- Implementation-specific: validation rejects non-object root
    it "returns ConfigValidationError for non-object YAML" $ do
      result <- parseConfigBytes "hello\n"
      case result of
        Right cfg -> expectationFailure $ "expected Left, got Right: " ++ show cfg
        Left err -> case err of
          ConfigValidationError _ -> pure ()
          other -> expectationFailure $ "expected ConfigValidationError, got " ++ show other

    -- Implementation-specific: parseConfigFile IO error surface
    it "returns ConfigFileNotFound for missing file" $ do
      result <- parseConfigFile "/nonexistent/hs_opentelemetry_config_missing_01928374.yaml"
      case result of
        Right cfg -> expectationFailure $ "expected Left, got Right: " ++ show cfg
        Left err -> err `shouldBe` ConfigFileNotFound "/nonexistent/hs_opentelemetry_config_missing_01928374.yaml"

    -- Implementation-specific: substitution edge cases
    it "env substitution: malformed ${...} without closing brace preserves literal" $ do
      let yaml :: Text
          yaml =
            "file_format: '${UNCLOSED'\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> configFileFormat cfg `shouldBe` "${UNCLOSED"

    -- Implementation-specific: empty ${} substitution
    it "env substitution: empty variable name ${} is handled gracefully" $ do
      let yaml :: Text
          yaml =
            "file_format: '${}'\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> configFileFormat cfg `shouldBe` ""

    -- Configuration: tracer_provider.limits (span limits)
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "parses span limits" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \tracer_provider:\n\
            \  limits:\n\
            \    attribute_value_length_limit: 1\n\
            \    attribute_count_limit: 2\n\
            \    event_count_limit: 3\n\
            \    link_count_limit: 4\n\
            \    event_attribute_count_limit: 5\n\
            \    link_attribute_count_limit: 6\n"
      result <- parseConfigBytes yaml
      case result of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg -> case configTracerProvider cfg >>= tpLimits of
          Nothing -> expectationFailure "expected tpLimits"
          Just sl -> do
            slAttributeValueLengthLimit sl `shouldBe` Just 1
            slAttributeCountLimit sl `shouldBe` Just 2
            slEventCountLimit sl `shouldBe` Just 3
            slLinkCountLimit sl `shouldBe` Just 4
            slEventAttributeCountLimit sl `shouldBe` Just 5
            slLinkAttributeCountLimit sl `shouldBe` Just 6

  describe "OpenTelemetry.Configuration.Create.createFromConfig" $ do
    -- Configuration: SDK startup from parsed file (components graph)
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "createFromConfig produces components from minimal config" $ do
      let yaml :: Text
          yaml = "file_format: \"1.0\"\n"
      ep <- parseConfigBytes yaml
      case ep of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg ->
          bracket (createFromConfig cfg) otelShutdown $ \comps -> do
            not (null (propagatorFields (otelPropagators comps))) `shouldBe` True

    -- Configuration: disabled SDK (no-op telemetry)
    -- https://opentelemetry.io/docs/specs/otel/configuration/
    it "createFromConfig with disabled=true returns noop components" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \disabled: true\n"
      ep <- parseConfigBytes yaml
      case ep of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg ->
          bracket (createFromConfig cfg) otelShutdown $ \comps -> do
            propagatorFields (otelPropagators comps) `shouldBe` []

    -- Resource SDK: attributes from configuration merged into TracerProvider resource
    -- https://opentelemetry.io/docs/specs/otel/resource/sdk/
    it "createFromConfig resource attributes are propagated" $ do
      let yaml :: Text
          yaml =
            "file_format: \"1.0\"\n\
            \resource:\n\
            \  attributes:\n\
            \    service.name: my-service\n\
            \    service.version: \"1.0\"\n"
      ep <- parseConfigBytes yaml
      case ep of
        Left err -> expectationFailure $ "expected Right, got Left: " ++ show err
        Right cfg ->
          bracket (createFromConfig cfg) otelShutdown $ \comps -> do
            let attrs =
                  getMaterializedResourcesAttributes $
                    getTracerProviderResources $
                      otelTracerProvider comps
            lookupAttribute attrs "service.name" `shouldBe` Just (toAttribute ("my-service" :: Text))
            lookupAttribute attrs "service.version" `shouldBe` Just (toAttribute ("1.0" :: Text))

  describe "detectSpanLimits (environment)" $ sequential $ do
    -- General SDK environment variables for span limits (OTEL_SPAN_*)
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    it "maps OTEL_SPAN_LINK_COUNT_LIMIT and OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT to distinct SpanLimits fields" $
      bracketUnset spanLimitEnvKeys $ \_ -> do
        setEnv "OTEL_SPAN_LINK_COUNT_LIMIT" "42"
        setEnv "OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT" "77"
        sl <- detectSpanLimits
        linkCountLimit sl `shouldBe` Just 42
        eventAttributeCountLimit sl `shouldBe` Just 77


spanLimitEnvKeys :: [String]
spanLimitEnvKeys =
  [ "OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT"
  , "OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT"
  , "OTEL_SPAN_EVENT_COUNT_LIMIT"
  , "OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT"
  , "OTEL_SPAN_LINK_COUNT_LIMIT"
  , "OTEL_LINK_ATTRIBUTE_COUNT_LIMIT"
  ]


bracketUnset :: [String] -> ([(String, Maybe String)] -> IO a) -> IO a
bracketUnset keys act =
  bracket
    ( do
        saved <- mapM (\k -> (,) k <$> lookupEnv k) keys
        mapM_ unsetEnv keys
        pure saved
    )
    (mapM_ restore)
    act
  where
    restore (k, Nothing) = unsetEnv k
    restore (k, Just v) = setEnv k v


bracketEnv :: String -> String -> IO a -> IO a
bracketEnv name value = bracket_ (setEnv name value) (unsetEnv name)
