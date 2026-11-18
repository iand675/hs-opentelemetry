WEAVER ?= weaver
CABAL ?= cabal
FOURMOLU ?= fourmolu
HASKELL_RENDERER ?= $(CABAL) run hs-opentelemetry-semantic-conventions:exe:generate --
WEAVER_VERSION := 0.28.0
FOURMOLU_VERSION := 0.19.0.1
YAML_FILES := $(shell find model/model -type f \( -name "*.yml" -o -name "*.yaml" \))
MODEL := .generated/model.json
METRICS := ../semantic-conventions-metrics/src/OpenTelemetry/SemanticConventions/Metrics.hs
METRIC_DOCS := ../semantic-conventions-metrics/docs/metrics.md
TEMPLATES := $(wildcard dev/templates/haskell/*)

.PHONY: build generate
build: generate
	$(CABAL) build lib:hs-opentelemetry-semantic-conventions lib:hs-opentelemetry-semantic-conventions-metrics

generate: src/OpenTelemetry/SemanticConventions.hs $(METRICS) $(METRIC_DOCS)

$(MODEL): $(YAML_FILES) $(TEMPLATES)
	test "$$($(WEAVER) --version)" = "weaver $(WEAVER_VERSION)"
	$(WEAVER) registry generate -r model/model --templates dev/templates haskell .generated

src/OpenTelemetry/SemanticConventions.hs: hs-opentelemetry-semantic-conventions.cabal dev/generate.hs $(MODEL)
	$(HASKELL_RENDERER) $(MODEL)

$(METRICS): $(MODEL)
	test "$$($(FOURMOLU) --version | head -n 1)" = "fourmolu $(FOURMOLU_VERSION)"
	mkdir -p $(dir $@)
	cp .generated/Metrics.hs $@
	$(FOURMOLU) --mode inplace $@

$(METRIC_DOCS): $(MODEL)
	mkdir -p $(dir $@)
	cp .generated/metrics.md $@
