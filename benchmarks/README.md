# Benchmark Conventions

This folder defines project-wide benchmark suite conventions.

## Case taxonomy

Benchmarks should prefer semantic case labels over raw numeric labels:

- `small`
- `medium`
- `large`

Raw cardinalities remain package-local and workload-specific, but each benchmark
suite should map its local fixture sizes to this taxonomy.

## Component registry

`components.txt` is the source of truth for the full benchmark suite run by
`scripts/run-benchmarks`.
