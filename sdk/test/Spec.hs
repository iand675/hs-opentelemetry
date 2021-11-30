import OpenTelemetry.Trace (initializeGlobalTracerProvider)
import qualified OpenTelemetry.BaggageSpec as BaggageSpec
import qualified OpenTelemetry.ContextSpec as ContextSpec
import qualified OpenTelemetry.TraceSpec as TraceSpec
import qualified OpenTelemetry.ResourceSpec as ResourceSpec
import Test.Hspec

main :: IO ()
main = do
  initializeGlobalTracerProvider
  hspec $ do
    BaggageSpec.spec
    ContextSpec.spec
    TraceSpec.spec
    ResourceSpec.spec