# Semantic metric constructors

Generated constructors for all 566 metrics in OpenTelemetry Semantic Conventions
1.45.0, with upstream names, units, descriptions and a generated
[metric catalogue](docs/metrics.md).

The package is separate from the attribute-key package because the Metrics API
already depends on those keys. Applications can depend on this package without
creating a dependency cycle or adding an SDK dependency to instrumentation code.

## Example

```haskell
import OpenTelemetry.Metric.Core
import qualified OpenTelemetry.SemanticConventions.Metrics as SC

-- meter comes from the application's MeterProvider.
histogram <- SC.create_http_server_request_duration meter defaultAdvisoryParameters
histogramRecord histogram 0.125 requestAttributes
```

Every constructor takes a `Meter` and `AdvisoryParameters`. It supplies the upstream
name, unit and description to the corresponding Meter factory. Record values in
the documented unit and include the metric's required attributes.

Counters, up/down counters and gauges have synchronous and observable variants.
For example, use `create_jvm_memory_used_int64` for synchronous updates, or
`create_observable_jvm_memory_used_int64` with callbacks for snapshots. Choose the
measurement style required by the instrumentation's semantic conventions.

Numeric annotations produce `Int64` or `Double` factories. Metrics without an
upstream numeric annotation provide both choices explicitly. Histograms use the
existing `Double`-only `Histogram` API, including integer-valued metric definitions.

Development and deprecated metrics are included and identified in the catalogue
and Haddock. Supply advisory settings such as explicit bucket boundaries when
recommended by the instrument's upstream documentation; prose recommendations
are not encoded as structured data by the registry.

## Regeneration

From a Git checkout, run `make` in `../semantic-conventions` with Weaver 0.28.0 and
Fourmolu 0.19.0.1 available. The Haskell constructors and Markdown catalogue come
from templates under `semantic-conventions/dev/templates/haskell`.
