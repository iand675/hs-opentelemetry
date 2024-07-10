import qualified OpenTelemetry.BaggageSpec as BaggageSpec
import qualified OpenTelemetry.ContextSpec as ContextSpec
import qualified OpenTelemetry.LogRecordProcessorSpec as LogRecordProcessorSpec
import qualified OpenTelemetry.ResourceSpec as ResourceSpec
import OpenTelemetry.Trace (initializeGlobalTracerProvider)
import qualified OpenTelemetry.TraceSpec as TraceSpec
import Test.Hspec


main :: IO ()
main = do
  initializeGlobalTracerProvider
  hspec $ do
    BaggageSpec.spec
    ContextSpec.spec
    TraceSpec.spec
    ResourceSpec.spec
    LogRecordProcessorSpec.spec
