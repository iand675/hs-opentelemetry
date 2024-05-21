import Network.HTTP.Client (Request (requestHeaders), defaultRequest)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Instrumentation.HttpClient.Raw (httpTracerProvider, instrumentRequest)
import OpenTelemetry.Propagator
import OpenTelemetry.Trace.Core (getTracerProviderPropagators, getTracerTracerProvider)
import Test.Hspec


main :: IO ()
main = hspec $ do
  describe "OpenTelemetry.Instrumentation.HttpClient" $ do
    describe "Raw" $ do
      describe "instrumentRequest" $ do
        specify "Request has the correct attributes" $ do
          request <- instrumentRequest mempty Context.empty defaultRequest
          tracer <- httpTracerProvider
          context <- extract (getTracerProviderPropagators $ getTracerTracerProvider $ tracer) (requestHeaders request) Context.empty
          let maybeAttributes = Context.lookupSpan context
          pending