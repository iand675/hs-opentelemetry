.PHONY: all
all: all.stack-9.4 all.stack-9.6 all.stack-9.8 all.stack-9.10 all.stack-9.12 all.cabal

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

.PHONY: all.stack-9.12
all.stack-9.12:
	stack --stack-yaml stack-ghc-9.12.yaml build --test --bench

.PHONY: all.cabal
all.cabal:
	cabal v2-build --jobs --enable-tests --enable-benchmarks all
	cabal v2-test --jobs all

.PHONY: build.all
build.all: build.all.stack-9.4 build.all.stack-9.6 build.all.stack-9.8 build.all.stack-9.10 build.all.stack-9.12 build.all.cabal

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

.PHONY: build.all.stack-9.12
build.all.stack-9.12:
	stack --stack-yaml stack-ghc-9.12.yaml build --test --no-run-tests --bench --no-run-benchmarks

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


# ── Benchmark regression detection ──────────────────────────────────────
# Save a baseline on your machine, then check after changes.
# Baselines are machine-specific and stored in benchmarks/.

.PHONY: bench.save
bench.save:
	scripts/bench-regression save

.PHONY: bench.check
bench.check:
	scripts/bench-regression check

# Strict mode: 10% threshold (use for focused perf work)
.PHONY: bench.check.strict
bench.check.strict:
	scripts/bench-regression check 10

.PHONY: bench.compare
bench.compare:
	scripts/bench-regression compare

.PHONY: bench.normalize
bench.normalize:
	scripts/bench-regression normalize

# Hack https://www.gnu.org/software/make/manual/html_node/Force-Targets.html
FORCE:
