#!/usr/bin/env bash
# For every platform in TARGETS, gathers its binary from BIN_DIR/<goos>_<goarch>/, the license files, readme, its images and changelog
# in PACKAGE_DIR and archives that into DIST_DIR. The archives are named for RELEASE_VERSION, or dev when that is not set.
# WORKSPACE_FOLDER, BIN_DIR, BINARY_NAME, PACKAGE_DIR and DIST_DIR default as set in lib/config.sh and can be set in the environment.
set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/config.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Moves to the workspace and creates the output directory
function setup() {
  cd "$WORKSPACE_FOLDER"
  mkdir -p "$DIST_DIR"
}

# Prints the path of the archive for the given version, os and architecture
function archivePath() {
  local version="$1" goos="$2" goarch="$3"
  echo "$WORKSPACE_FOLDER/$DIST_DIR/${BINARY_NAME}_${version}_${goos}_${goarch}.tar.gz"
}

# Gathers the files to ship for the given os and architecture in the package directory, replacing the binary of the previous target
function stagePackage() {
  local goos="$1" goarch="$2"

  mkdir -p "$PACKAGE_DIR/docs"
  cp "$BIN_DIR/${goos}_${goarch}/$BINARY_NAME" LICENSE README.md CHANGELOG.md "$PACKAGE_DIR/"
  #cp -R docs/images "$PACKAGE_DIR/docs/"
}

# Archives the content of the package directory into the given archive path
function createArchive() {
  local archive="$1"

  (
    cd "$PACKAGE_DIR"
    # The tar of macOS adds its extended attributes to the archive as extra ._ files unless COPYFILE_DISABLE is set
    if [[ "$(uname)" == "Darwin" ]]; then
      COPYFILE_DISABLE=1 tar --no-xattrs --exclude .DS_Store -czf "$archive" -- *
    else
      tar -czf "$archive" -- *
    fi
  )
}

# Packages the binary and its accompanying files into an archive of the given version for every target
function package() {
  local version="$1" target goos goarch

  for target in "${TARGETS[@]}"; do
    goos="${target%/*}"
    goarch="${target#*/}"
    stagePackage "$goos" "$goarch"
    createArchive "$(archivePath "$version" "$goos" "$goarch")"
  done
}

# Packages the release for every target
function main() {
  setup
  package "${RELEASE_VERSION:-dev}"
}

main
