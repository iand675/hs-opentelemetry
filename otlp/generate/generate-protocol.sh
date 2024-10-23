#!/usr/bin/env bash

set -e

if ! type -P protoc >/dev/null 2>&1; then
  printf '%s\n' 'protoc is not available' 1>&2
  exit 1
fi

if ! type -P proto-lens-protoc >/dev/null 2>&1; then
  printf '%s\n' 'proto-lens-protoc is not available' 1>&2
  exit 1
fi

PROTO_LENS=$(type -P proto-lens-protoc)

SCRIPT_PATH=$(dirname -- "${BASH_SOURCE[0]}")
cd "${SCRIPT_PATH}"

OTLP_VERSION="$1"

if ! test -n "$OTLP_VERSION"; then
  printf '%s\n' 'OTLP protobuf version is not specified.'
  printf '%s\n' 'You should pass the corresponding git tag as an argument.'
  printf '%s\n' 'e.g.: ./generate-protocol.sh v1.0.0'
  exit 1
fi

# clone opentelemetry-proto repository
OTLP_REPO='https://github.com/open-telemetry/opentelemetry-proto.git'
OTLP_REPO_DIR='opentelemetry-proto.git'
test -e "$OTLP_REPO_DIR" && rm -fr "$OTLP_REPO_DIR"
git clone -q "$OTLP_REPO" "$OTLP_REPO_DIR"

# check if the version exist
OTLP_GIT_TAG=$(git -C "$OTLP_REPO_DIR" tag -l "$OTLP_VERSION" | head -n1)
if test "$OTLP_GIT_TAG" != "$OTLP_VERSION"; then
  printf '%s\n' "The git tag does not exist: $OTLP_VERSION"
  exit 1
fi

# switch to the right release
git -C "$OTLP_REPO_DIR" switch --detach "tags/$OTLP_VERSION" >/dev/null 2>&1

# make Haskell output dir
HASKELL_OUT_DIR='src'
test -e "$HASKELL_OUT_DIR" && rm -fr "$HASKELL_OUT_DIR"
mkdir "$HASKELL_OUT_DIR"

# generate Haskell opentelemetry protocol files
find "$OTLP_REPO_DIR" -type f -name \*.proto -print0 |
  xargs -r0 -L1 protoc --plugin=protoc-gen-haskell="$PROTO_LENS" \
    --haskell_out="$HASKELL_OUT_DIR" --proto_path="$OTLP_REPO_DIR"

# patch generated files for ignoring linting
find ./ -type f -name \*.hs -print0 |
  xargs -r0 -L1 grep -FLZ '{- HLINT ignore -}' |
  xargs -r0 sed -i '1i{- HLINT ignore -}'

# write version in the OTLP_VERSION file
echo "$OTLP_VERSION" >"$HASKELL_OUT_DIR/OTLP_VERSION"

# print the list of generated modules
printf '%s\n' ">>> Haskell modules for OTLP version $OTLP_VERSION:"
find "$HASKELL_OUT_DIR" -type f -name \*.hs |
  sed -r -e "s|^${HASKELL_OUT_DIR}/||" -e 's|\.hs$||' -e 's|/|.|g' | sort
