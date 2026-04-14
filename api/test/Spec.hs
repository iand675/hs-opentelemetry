import qualified OpenTelemetry.AttributesSpec as Attributes
import qualified OpenTelemetry.BaggageSpec as Baggage
import qualified OpenTelemetry.InstrumentationLibrarySpec as InstrumentationLibrary
import qualified OpenTelemetry.SemanticsConfigSpec as SemanticsConfigSpec
import qualified OpenTelemetry.Trace.TraceFlagsSpec as TraceFlags
import qualified OpenTelemetry.Trace.TracerSpec as Tracer
import Test.Hspec


main :: IO ()
main = hspec $ do
  Attributes.spec
  Baggage.spec
  InstrumentationLibrary.spec
  TraceFlags.spec
  Tracer.spec
  SemanticsConfigSpec.spec
