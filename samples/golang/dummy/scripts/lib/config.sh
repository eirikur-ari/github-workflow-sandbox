# shellcheck shell=bash
# Defaults of the values the scripts share, each overridden by an environment variable of the same name.
# Sourced by the scripts, it sets no shell options and runs nothing.

# Absolute path of the repository root, which is the parent of the directory holding scripts/
: "${WORKSPACE_FOLDER:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

: "${BINARY_NAME:=dummy}"
: "${BUILD_DIR:=build}"
: "${BIN_DIR:=bin}"
: "${DIST_DIR:=$BUILD_DIR/dist}"
: "${PACKAGE_DIR:=$BUILD_DIR/package}"

# Platforms the release is built for, as <goos>/<goarch>
TARGETS=(linux/amd64 linux/arm64 darwin/amd64 darwin/arm64)
