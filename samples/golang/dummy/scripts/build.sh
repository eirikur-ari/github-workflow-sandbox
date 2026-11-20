#!/usr/bin/env bash
# Builds the binary for the host platform into BIN_DIR, or for every platform in TARGETS into BIN_DIR/<goos>_<goarch>/.
# The binary reports RELEASE_VERSION as its version when that is set in the environment.
# WORKSPACE_FOLDER, BIN_DIR and BINARY_NAME default as set in lib/config.sh and can be set in the environment.
set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/config.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Compiles a static binary for the given platform at the given output path
function gobuild() {
  local goos="$1" goarch="$2" output="$3"
 # local version_var=github.com/github-workflow-sandbox/samples/golang/dummy/internal/composition.releaseVersion

  CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" GOFLAGS=-mod=readonly \
    go build -trimpath -buildvcs=false -ldflags "-s -w" -o "$output" ./cmd
}

# Builds the binary for the platform the script runs on
function buildHost() {
  local goos goarch

  goos=$(go env GOOS) || return
  goarch=$(go env GOARCH) || return
  gobuild "$goos" "$goarch" "$BIN_DIR/$BINARY_NAME"
}

# Builds the binary for every target
function buildAll() {
  local target goos goarch

  for target in "${TARGETS[@]}"; do
    goos="${target%/*}"
    goarch="${target#*/}"
    echo "Building $goos/$goarch"
    gobuild "$goos" "$goarch" "$BIN_DIR/${goos}_${goarch}/$BINARY_NAME"
  done
}

# Builds the binaries of the requested mode
function main() {
  cd "$WORKSPACE_FOLDER"

  case "${1:-}" in
    host) buildHost ;;
    all) buildAll ;;
    *)
      echo "missing or unknown argument, it must be one of the following: host, all" >&2
      exit 2
      ;;
  esac
}

main "$@"
