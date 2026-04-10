YAML_FILES := $(shell find model/model -type f -name "*.yml" -o -name "*.yaml")

.PHONY: build
build: src/OpenTelemetry/SemanticConventions.hs
	cabal build hs-opentelemetry-semantic-conventions:libs

src/OpenTelemetry/SemanticConventions.hs: hs-opentelemetry-semantic-conventions.cabal dev/generate.hs $(YAML_FILES)
	cabal run hs-opentelemetry-semantic-conventions:exe:generate
