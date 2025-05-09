#!/usr/bin/env bash

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

# use the package directory as the default destination directory
DESTINATION_DIR="$(git rev-parse --show-toplevel)/$OTLP_PACKAGE_DIR"
cd "$DESTINATION_DIR"

OTLP_VERSION=$(cat OTLP_VERSION)

if [ -z "$OTLP_VERSION" ]; then
  printf '%s\n' 'Missing OTLP git tag version as first argument.'
  exit 1
fi

# clone the opentelemetry-proto repository
OTLP_REPO='https://github.com/open-telemetry/opentelemetry-proto.git'
OTLP_REPO_DIR='opentelemetry-proto.git'
rm -fr "$OTLP_REPO_DIR"
git clone -q "$OTLP_REPO" "$OTLP_REPO_DIR"

# check if the version exist
OTLP_GIT_TAG=$(git -C "$OTLP_REPO_DIR" tag -l "$OTLP_VERSION" | head -n1)
if [ "$OTLP_GIT_TAG" != "$OTLP_VERSION" ]; then
  printf '%s\n' "The following git tag does not exist: $OTLP_VERSION"
  exit 1
fi

# switch to the right release
git -C "$OTLP_REPO_DIR" switch --detach "tags/$OTLP_VERSION" >/dev/null 2>&1

# make the protobuf output dir
OTLP_PROTO_DIR='proto'
rm -fr "$OTLP_PROTO_DIR"
mkdir "$OTLP_PROTO_DIR"

# copy all the protobuf file in the OTLP_PROTO_DIR directory
find "$OTLP_REPO_DIR" -type f -name '*.proto' -print0 |
  tar -cf - --null --transform "s|$OTLP_REPO_DIR/||" --files-from=- |
  tar -xf - -C "$OTLP_PROTO_DIR"

# make the Haskell output dir
HASKELL_OUT_DIR='src'
rm -fr "$HASKELL_OUT_DIR"
mkdir "$HASKELL_OUT_DIR"

# generate Haskell opentelemetry protocol files
find "$OTLP_REPO_DIR" -type f -name '*.proto' -print0 |
  xargs -r0 -L1 protoc --plugin=protoc-gen-haskell="$PROTO_LENS" \
    --haskell_out="$HASKELL_OUT_DIR" --proto_path="$OTLP_REPO_DIR"

# patch generated files for ignoring linting
find "$HASKELL_OUT_DIR" -type f -name '*.hs' -print0 |
  xargs -r0 sed -i '1i{- HLINT ignore -}'

# clean up git repository
rm -fr "$OTLP_REPO_DIR"
