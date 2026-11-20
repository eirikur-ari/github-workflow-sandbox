#!/usr/bin/env bash
# extract unpacks the release archive of the platform it runs on, and run runs the acceptance tests against a binary.
# WORKSPACE_FOLDER, BIN_DIR, BINARY_NAME, BUILD_DIR and DIST_DIR default as set in lib/config.sh and can be set in the environment.
# ACCEPTANCE_DIR is where extract unpacks the archive, and defaults to acceptance in BUILD_DIR.
# DUMMY_BINARY is the binary the tests run against, and defaults to the binary in BIN_DIR.
set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/config.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

: "${ACCEPTANCE_DIR:=$BUILD_DIR/acceptance}"

# Prints the path of the only archive in DIST_DIR for the platform the script runs on, and fails when there is not exactly one
function archivePath() {
  local goos goarch archives

  goos=$(go env GOOS) || return
  goarch=$(go env GOARCH) || return
  archives=$(find "$DIST_DIR" -maxdepth 1 -name "${BINARY_NAME}_*_${goos}_${goarch}.tar.gz")
  if [[ -z "$archives" || "$archives" == *$'\n'* ]]; then
    echo "expected exactly one $goos/$goarch archive in $DIST_DIR, found: ${archives:-none}" >&2
    exit 1
  fi
  echo "$archives"
}

# Extracts the archive of this platform into an empty ACCEPTANCE_DIR
function extract() {
  local archive

  archive=$(archivePath)
  rm -rf "$ACCEPTANCE_DIR"
  mkdir -p "$ACCEPTANCE_DIR"
  tar -xzf "$archive" -C "$ACCEPTANCE_DIR"
}

# Runs the acceptance tests against the binary, failing when it does not exist
function run() {
  local binary="${PIDSHOOTER_BINARY:-$WORKSPACE_FOLDER/$BIN_DIR/$BINARY_NAME}"

  if [[ ! -x "$binary" ]]; then
    echo "the binary to test does not exist: $binary" >&2
    exit 1
  fi
  DUMMY_BINARY="$binary" go test -v -tags acceptance -run TestAcceptance -count=1 ./...
}

# Runs the requested step of the acceptance test
function main() {
  cd "$WORKSPACE_FOLDER"

  case "${1:-}" in
    extract) extract ;;
    run) run ;;
    *)
      echo "missing or unknown argument, it must be one of the following: extract, run" >&2
      exit 2
      ;;
  esac
}

main "$@"
