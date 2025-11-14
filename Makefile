.PHONY: all
all: all.stack-9.4 all.stack-9.6 all.stack-9.8 all.stack-9.10 all.cabal

.PHONY: all.stack-9.4
all.stack-9.4:
	stack --stack-yaml stack-ghc-9.4.yaml build --test --bench

.PHONY: all.stack-9.6
all.stack-9.6:
	stack --stack-yaml stack-ghc-9.6.yaml build --test --bench

.PHONY: all.stack-9.8
all.stack-9.8:
	stack --stack-yaml stack-ghc-9.8.yaml build --test --bench

.PHONY: all.stack-9.10
all.stack-9.10:
	stack --stack-yaml stack-ghc-9.10.yaml build --test --bench

.PHONY: all.cabal
all.cabal:
	cabal v2-build --jobs --enable-tests --enable-benchmarks all
	cabal v2-test --jobs all

.PHONY: build.all
build.all: build.all.stack-9.4 build.all.stack-9.6 build.all.stack-9.8 build.all.stack-9.10 build.all.cabal

.PHONY: build.all.stack-9.4
build.all.stack-9.4:
	stack --stack-yaml stack-ghc-9.4.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.stack-9.6
build.all.stack-9.6:
	stack --stack-yaml stack-ghc-9.6.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.stack-9.8
build.all.stack-9.8:
	stack --stack-yaml stack-ghc-9.8.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.stack-9.10
build.all.stack-9.10:
	stack --stack-yaml stack-ghc-9.10.yaml build --test --no-run-tests --bench --no-run-benchmarks

.PHONY: build.all.cabal
build.all.cabal:
	cabal build --jobs --enable-tests --enable-benchmarks all

# format requires fourmolu 0.13.1.0 or later
.PHONY: format
format:
	fourmolu --mode inplace $$(git ls-files '*.hs' ':!:otlp/' ':!:semantic-conventions/src/OpenTelemetry/SemanticConventions.hs')

.PHONY: format.check
format.check:
	fourmolu --mode check $$(git ls-files '*.hs' ':!:otlp/' ':!:semantic-conventions/src/OpenTelemetry/SemanticConventions.hs')


# Hack https://www.gnu.org/software/make/manual/html_node/Force-Targets.html
FORCE:
