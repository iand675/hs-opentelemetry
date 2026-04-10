#!/usr/bin/env bash
#
# Regenerate Haskell proto-lens bindings from the opentelemetry-proto repo.
# Reads the target version from OTLP_VERSION in the otlp package directory.
#
# Requirements: protoc, proto-lens-protoc (both available via nix develop)

set -eo pipefail

if ! command -v protoc >/dev/null 2>&1; then
  printf '%s\n' 'protoc is not available' 1>&2
  exit 1
fi

if ! command -v proto-lens-protoc >/dev/null 2>&1; then
  printf '%s\n' 'proto-lens-protoc is not available' 1>&2
  exit 1
fi

PROTO_LENS=$(command -v proto-lens-protoc)

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

HASKELL_OUT_DIR='src'
rm -fr "$HASKELL_OUT_DIR"
mkdir "$HASKELL_OUT_DIR"

# Generate Haskell proto-lens modules (xargs -0 works on both GNU and BSD)
find "$OTLP_REPO_DIR" -type f -name '*.proto' -print0 |
  xargs -0 -L1 protoc --plugin=protoc-gen-haskell="$PROTO_LENS" \
    --haskell_out="$HASKELL_OUT_DIR" --proto_path="$OTLP_REPO_DIR"

# Prepend HLINT ignore pragma (sed -i '' is macOS; GNU sed uses sed -i)
if sed --version >/dev/null 2>&1; then
  # GNU sed
  find "$HASKELL_OUT_DIR" -type f -name '*.hs' -print0 |
    xargs -0 sed -i '1i{- HLINT ignore -}'
else
  # BSD sed (macOS)
  find "$HASKELL_OUT_DIR" -type f -name '*.hs' -print0 |
    xargs -0 sed -i '' $'1i\\\n{- HLINT ignore -}\n'
fi

rm -fr "$OTLP_REPO_DIR"

printf 'Done. Generated %d modules in %s/\n' \
  "$(find "$HASKELL_OUT_DIR" -name '*.hs' | wc -l | tr -d ' ')" \
  "$HASKELL_OUT_DIR"
