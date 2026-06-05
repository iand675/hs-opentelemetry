#!/usr/bin/env bash
#
# Regenerate Haskell OTLP bindings from the opentelemetry-proto repo using
# wireform-proto's code generator (no protoc / proto-lens required).
#
# Reads the target version from OTLP_VERSION in the otlp package directory.
#
# Requirements: a GHC toolchain + cabal able to build hs-opentelemetry-otlp
# (which depends on wireform-proto). The generator itself is the
# hs-opentelemetry-otlp-gen executable, guarded behind the `codegen` flag.

set -eo pipefail

OTLP_PACKAGE_DIR='otlp'

DESTINATION_DIR="$(git rev-parse --show-toplevel)/$OTLP_PACKAGE_DIR"
cd "$DESTINATION_DIR"

OTLP_VERSION=$(tr -d '[:space:]' < OTLP_VERSION)

if [ -z "$OTLP_VERSION" ]; then
  printf '%s\n' 'OTLP_VERSION file is empty or missing.'
  exit 1
fi

printf 'Generating bindings for OTLP %s\n' "$OTLP_VERSION"

OTLP_REPO='https://github.com/open-telemetry/opentelemetry-proto.git'
OTLP_REPO_DIR='opentelemetry-proto.git'
rm -fr "$OTLP_REPO_DIR"
git clone -q "$OTLP_REPO" "$OTLP_REPO_DIR"

OTLP_GIT_TAG=$(git -C "$OTLP_REPO_DIR" tag -l "$OTLP_VERSION" | head -n1)
if [ "$OTLP_GIT_TAG" != "$OTLP_VERSION" ]; then
  printf '%s\n' "The following git tag does not exist: $OTLP_VERSION"
  exit 1
fi

git -C "$OTLP_REPO_DIR" switch --detach "tags/$OTLP_VERSION" >/dev/null 2>&1

OTLP_PROTO_DIR='proto'
rm -fr "$OTLP_PROTO_DIR"
mkdir "$OTLP_PROTO_DIR"

# Copy proto files. Uses -s (macOS bsdtar) instead of --transform (GNU tar).
find "$OTLP_REPO_DIR" -type f -name '*.proto' -print0 |
  tar -cf - --null -s "|${OTLP_REPO_DIR}/||" --files-from=- |
  tar -xf - -C "$OTLP_PROTO_DIR"

rm -fr "$OTLP_REPO_DIR"

# wireform-proto's IDL parser does not accept the trailing ';' that protoc
# tolerates after a message/enum block (e.g. `};`). Strip those so the
# vendored proto files parse cleanly.
find "$OTLP_PROTO_DIR" -type f -name '*.proto' -print0 |
  xargs -0 sed -i 's/}[[:space:]]*;/}/g'

HASKELL_OUT_DIR='src'
rm -fr "$HASKELL_OUT_DIR"
mkdir "$HASKELL_OUT_DIR"

# Generate Haskell modules via the wireform-proto code generator. The generator
# is shipped as an executable in this package, guarded behind the `codegen`
# flag so that it is not built as part of the normal library build.
cabal run -v0 --flag codegen hs-opentelemetry-otlp-gen -- "$OTLP_PROTO_DIR" "$HASKELL_OUT_DIR"

printf 'Done. Generated %d modules in %s/\n' \
  "$(find "$HASKELL_OUT_DIR" -name '*.hs' | wc -l | tr -d ' ')" \
  "$HASKELL_OUT_DIR"
