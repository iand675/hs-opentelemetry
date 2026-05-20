import qualified OpenTelemetry.AttributesSpec as Attributes
import qualified OpenTelemetry.BaggageSpec as Baggage
import OpenTelemetry.Context
import qualified OpenTelemetry.Context.EnvironmentSpec as ContextEnvironment
import qualified OpenTelemetry.Context.PropagationSpec as ContextPropagation
import qualified OpenTelemetry.Context.ThreadLocalSpec as ContextThreadLocal
import qualified OpenTelemetry.ContextSpec as ContextSpec
import qualified OpenTelemetry.Contrib.CarryOnsSpec as CarryOns
import qualified OpenTelemetry.Contrib.SpanTraversalsSpec as SpanTraversals
import qualified OpenTelemetry.EnvironmentSpec as Environment
import qualified OpenTelemetry.InstrumentationLibrarySpec as InstrumentationLibrary
import qualified OpenTelemetry.Internal.LoggingSpec as Logging
import qualified OpenTelemetry.Log.CoreSpec as CoreSpec
import qualified OpenTelemetry.MetricSpec as MetricsSpec
import qualified OpenTelemetry.PropagatorSpec as PropagatorSpec
import qualified OpenTelemetry.RegistrySpec as Registry
import qualified OpenTelemetry.ResourceSpec as Resource
import qualified OpenTelemetry.SemanticsConfigSpec as SemanticsConfigSpec
import qualified OpenTelemetry.Trace.ExceptionHandlerSpec as ExceptionHandler
import qualified OpenTelemetry.Trace.IdCodecSpec as IdCodec
import qualified OpenTelemetry.Trace.MonadSpec as TraceMonad
import qualified OpenTelemetry.Trace.SamplerSpec as Sampler
import qualified OpenTelemetry.Trace.TraceFlagsSpec as TraceFlags
import qualified OpenTelemetry.Trace.TracerSpec as Tracer
import qualified OpenTelemetry.Trace.UtilsSpec as Utils
import Test.Hspec


main :: IO ()
main = hspec $ do
  Attributes.spec
  Baggage.spec
  ContextSpec.spec
  ContextEnvironment.spec
  ContextThreadLocal.spec
  ContextPropagation.spec
  CarryOns.spec
  SpanTraversals.spec
  Environment.spec
  Resource.spec
  InstrumentationLibrary.spec
  Logging.spec
  ExceptionHandler.spec
  IdCodec.spec
  TraceMonad.spec
  Sampler.spec
  TraceFlags.spec
  Tracer.spec
  Utils.spec
  SemanticsConfigSpec.spec
  CoreSpec.spec
  MetricsSpec.spec
  PropagatorSpec.spec
  Registry.spec
