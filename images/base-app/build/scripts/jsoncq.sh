#!/usr/bin/env bash

# jsoncq.sh - A script to process JSONC files with jq
# ATTENTION: This script removes comments before processing it with jq, so the final output will not contain comments.

set -euo pipefail

function help() {
  echo "Usage: $0 [options] <jq filter> [file]"
  exit 1
}

# We need at least two arguments: a jq filter and a file path
if [[ $# -lt 2 ]]; then
  help
fi

# check if the last argument is a file path with an existing file
JSONC_FILE="${@: -1}"
if [[ -z "${JSONC_FILE:-}" ]] || [[ ! -f "${JSONC_FILE:-}" ]]; then
  echo "ERROR: $JSONC_FILE is not a valid file."
  help
fi

# Remove the last argument from the list
set -- "${@:1:$(($# - 1))}"

# Copy current config to a temporary file without comments
TMP_JSON=$(mktemp)
sed '/^\s*\/\//d' "$JSONC_FILE" > "$TMP_JSON"

# Validate JSON
if ! jq -e . "$TMP_JSON" >/dev/null; then
  echo -e "Invalid JSON in $TMP_JSON" >&2
  exit 1
fi

# Pass all arguments to jq
jq "$@" "$TMP_JSON"

# Cleanup
rm -f "$TMP_JSON"
