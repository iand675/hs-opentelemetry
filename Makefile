.PHONY: all
all: all.stack-8.10 all.stack-9.0 all.stack-9.2 all.cabal-9.0

.PHONY: all.stack-8.10
all.stack-8.10:
	stack --stack-yaml stack-ghc-8.10.yaml build --test --bench

.PHONY: all.stack-9.0
all.stack-9.0:
	stack --stack-yaml stack.yaml build --test --bench

.PHONY: all.stack-9.2
all.stack-9.2:
	stack --stack-yaml stack-ghc-9.2.yaml build --test --bench

.PHONY: all.cabal-9.0
all.cabal-9.0:
	cabal v2-build --jobs --enable-tests --enable-benchmarks all
	cabal v2-test --jobs all

.PHONY: build.all
build.all: build.all.stack-8.10 build.all.stack-9.0 build.all.stack-9.2 build.all.cabal-9.0

.PHONY: build.all.stack-8.10
build.all.stack-8.10:
	stack --stack-yaml stack-ghc-8.10.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.stack-9.0
build.all.stack-9.0:
	stack --stack-yaml stack.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.stack-9.2
build.all.stack-9.2:
	stack --stack-yaml stack-ghc-9.2.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.cabal-9.0
build.all.cabal-9.0:
	cabal build --jobs --enable-tests --enable-benchmarks all

.PHONY: format
format:
	fourmolu --mode inplace $$(git ls-files | grep -E "\.hs$$")

.PHONY: format.check
format.check:
	fourmolu --mode check $$(git ls-files | grep -E "\.hs$$")

CABALS := \
  api/hs-opentelemetry-api.cabal\
  examples/hspec/hspec-example.cabal\
  examples/yesod-minimal/yesod-minimal.cabal\
  exporters/handle/hs-opentelemetry-exporter-handle.cabal\
  exporters/in-memory/hs-opentelemetry-exporter-in-memory.cabal\
  exporters/jaeger/hs-opentelemetry-exporter-jaeger.cabal\
  exporters/otlp/hs-opentelemetry-exporter-otlp.cabal\
  exporters/prometheus/hs-opentelemetry-exporter-prometheus.cabal\
  exporters/zipkin/hs-opentelemetry-exporter-zipkin.cabal\
  instrumentation/cloudflare/hs-opentelemetry-instrumentation-cloudflare.cabal\
  instrumentation/conduit/hs-opentelemetry-instrumentation-conduit.cabal\
  instrumentation/hspec/hs-opentelemetry-instrumentation-hspec.cabal\
  instrumentation/http-client/hs-opentelemetry-instrumentation-http-client.cabal\
  instrumentation/persistent/hs-opentelemetry-instrumentation-persistent.cabal\
  instrumentation/postgresql-simple/hs-opentelemetry-instrumentation-postgresql-simple.cabal\
  instrumentation/wai/hs-opentelemetry-instrumentation-wai.cabal\
  instrumentation/yesod/hs-opentelemetry-instrumentation-yesod.cabal\
  otlp/hs-opentelemetry-otlp.cabal\
  propagators/b3/hs-opentelemetry-propagator-b3.cabal\
  propagators/jaeger/hs-opentelemetry-propagator-jaeger.cabal\
  propagators/w3c/hs-opentelemetry-propagator-w3c.cabal\
  sdk/hs-opentelemetry-sdk.cabal\
  utils/exceptions/hs-opentelemetry-utils-exceptions.cabal

.PHONY: hpack
hpack: $(CABALS)

api/hs-opentelemetry-api.cabal: api/package.yaml FORCE
	(cd api; hpack)

examples/hspec/hspec-example.cabal: examples/hspec/package.yaml FORCE
	(cd examples/hspec; hpack)

examples/yesod-minimal/yesod-minimal.cabal: examples/yesod-minimal/package.yaml FORCE
	(cd examples/yesod-minimal; hpack)

exporters/handle/hs-opentelemetry-exporter-handle.cabal: exporters/handle/package.yaml FORCE
	(cd exporters/handle; hpack)

exporters/in-memory/hs-opentelemetry-exporter-in-memory.cabal: exporters/in-memory/package.yaml FORCE
	(cd exporters/in-memory; hpack)

exporters/jaeger/hs-opentelemetry-exporter-jaeger.cabal: exporters/jaeger/package.yaml FORCE
	(cd exporters/jaeger; hpack)

exporters/otlp/hs-opentelemetry-exporter-otlp.cabal: exporters/otlp/package.yaml FORCE
	(cd exporters/otlp; hpack)

exporters/prometheus/hs-opentelemetry-exporter-prometheus.cabal: exporters/prometheus/package.yaml FORCE
	(cd exporters/prometheus; hpack)

exporters/zipkin/hs-opentelemetry-exporter-zipkin.cabal: exporters/zipkin/package.yaml FORCE
	(cd exporters/zipkin; hpack)

instrumentation/cloudflare/hs-opentelemetry-instrumentation-cloudflare.cabal: instrumentation/cloudflare/package.yaml FORCE
	(cd instrumentation/cloudflare; hpack)

instrumentation/conduit/hs-opentelemetry-instrumentation-conduit.cabal: instrumentation/conduit/package.yaml FORCE
	(cd instrumentation/conduit; hpack)

instrumentation/hspec/hs-opentelemetry-instrumentation-hspec.cabal: instrumentation/hspec/package.yaml FORCE
	(cd instrumentation/hspec; hpack)

instrumentation/http-client/hs-opentelemetry-instrumentation-http-client.cabal: instrumentation/http-client/package.yaml FORCE
	(cd instrumentation/http-client; hpack)

instrumentation/persistent/hs-opentelemetry-instrumentation-persistent.cabal: instrumentation/persistent/package.yaml FORCE
	(cd instrumentation/persistent; hpack)

instrumentation/postgresql-simple/hs-opentelemetry-instrumentation-postgresql-simple.cabal: instrumentation/postgresql-simple/package.yaml FORCE
	(cd instrumentation/postgresql-simple; hpack)

instrumentation/wai/hs-opentelemetry-instrumentation-wai.cabal: instrumentation/wai/package.yaml FORCE
	(cd instrumentation/wai; hpack)

instrumentation/yesod/hs-opentelemetry-instrumentation-yesod.cabal: instrumentation/yesod/package.yaml FORCE
	(cd instrumentation/yesod; hpack)

otlp/hs-opentelemetry-otlp.cabal: otlp/package.yaml FORCE
	(cd otlp; hpack)

propagators/b3/hs-opentelemetry-propagator-b3.cabal: propagators/b3/package.yaml FORCE
	(cd propagators/b3; hpack)

propagators/jaeger/hs-opentelemetry-propagator-jaeger.cabal: propagators/jaeger/package.yaml FORCE
	(cd propagators/jaeger; hpack)

propagators/w3c/hs-opentelemetry-propagator-w3c.cabal: propagators/w3c/package.yaml FORCE
	(cd propagators/w3c; hpack)

sdk/hs-opentelemetry-sdk.cabal: sdk/package.yaml FORCE
	(cd sdk; hpack)

utils/exceptions/hs-opentelemetry-utils-exceptions.cabal: utils/exceptions/package.yaml FORCE
	(cd utils/exceptions; hpack)

# Hack https://www.gnu.org/software/make/manual/html_node/Force-Targets.html
FORCE:
