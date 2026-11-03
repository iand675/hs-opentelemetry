WEAVER ?= weaver
CABAL ?= cabal
WEAVER_VERSION := 0.28.0
YAML_FILES := $(shell find model/model -type f \( -name "*.yml" -o -name "*.yaml" \))
MODEL := .generated/model.json

.PHONY: build
build: src/OpenTelemetry/SemanticConventions.hs
	$(CABAL) build lib:hs-opentelemetry-semantic-conventions

$(MODEL): $(YAML_FILES) dev/templates/haskell/weaver.yaml dev/templates/haskell/model.json.j2
	test "$$($(WEAVER) --version)" = "weaver $(WEAVER_VERSION)"
	$(WEAVER) registry generate -r model/model --templates dev/templates haskell .generated

src/OpenTelemetry/SemanticConventions.hs: hs-opentelemetry-semantic-conventions.cabal dev/generate.hs $(MODEL)
	$(CABAL) run hs-opentelemetry-semantic-conventions:exe:generate -- $(MODEL)
