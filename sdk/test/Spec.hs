import qualified OpenTelemetry.BaggageSpec as BaggageSpec
import qualified OpenTelemetry.ContextSpec as ContextSpec
import qualified OpenTelemetry.ResourceSpec as ResourceSpec
import OpenTelemetry.Trace (initializeGlobalTracerProvider)
import qualified OpenTelemetry.TraceSpec as TraceSpec
import System.Environment (setEnv)
import Test.Hspec


main :: IO ()
main = do
  -- For the attribute length limit test
  setEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT" "50"
  -- For the resource attributes initialization test
  setEnv "OTEL_RESOURCE_ATTRIBUTES" "host.name=env_host_name,example.name=env_example_name,example.count=42"
  initializeGlobalTracerProvider
  hspec $ do
    BaggageSpec.spec
    ContextSpec.spec
    TraceSpec.spec
    ResourceSpec.spec
