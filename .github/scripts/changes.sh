#!/usr/bin/env bash
# changes prints code=true when the branch changes a file that matches none of the given patterns, and code=false otherwise.
# The patterns are globs matched against the whole path, e.g. '*.md' for every Markdown file, 'docs/*' for a directory and LICENSE for a file.
# The branch is compared with its merge-base with origin/DEFAULT_BRANCH, so a docs-only push on top of code changes still counts as a code change.
# DEFAULT_BRANCH defaults to master, and must be fetched as origin/DEFAULT_BRANCH (actions/checkout fetch-depth: 0).
set -euo pipefail

: "${DEFAULT_BRANCH:=master}"

# Succeeds when the path matches one of the patterns
function isExcluded() {
  local path="$1" pattern
  shift

  for pattern in "$@"; do
    # shellcheck disable=SC2053 # the pattern is a glob on purpose
    [[ "$path" == $pattern ]] && return 0
  done
  return 1
}

# Prints code=true when a changed file matches none of the patterns, and code=false otherwise
function main() {
  local base changed path

  base=$(git merge-base "origin/$DEFAULT_BRANCH" HEAD) || exit
  changed=$(git diff --name-only "$base" HEAD) || exit
  echo "$changed" >&2

  while IFS= read -r path; do
    if [[ -n "$path" ]] && ! isExcluded "$path" "$@"; then
      echo "code=true"
      return
    fi
  done <<< "$changed"
  echo "code=false"
}

main "$@"
