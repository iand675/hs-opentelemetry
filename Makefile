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

# format requires fourmolu 0.13.1.0 or later
.PHONY: format
format:
	fourmolu --mode inplace $$(git ls-files '*.hs' ':!:otlp/')

.PHONY: format.check
format.check:
	fourmolu --mode check $$(git ls-files '*.hs' ':!:otlp/')


# Hack https://www.gnu.org/software/make/manual/html_node/Force-Targets.html
FORCE:
