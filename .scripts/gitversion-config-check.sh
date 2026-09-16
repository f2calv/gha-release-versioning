#!/usr/bin/env bash
set -euo pipefail

# Resolve the effective GitVersion version specification by inspecting the
# config file.
#
# The config file path is passed via GV_CONFIG.  We detect whether it uses the
# GitVersion v5 "tag:" syntax or the v6 "label:" syntax and set GV_SPEC
# accordingly.  If neither keyword is found, we default to 6.x.

# Validate required environment variables
: "${GV_CONFIG:?GV_CONFIG is required}"
: "${GITHUB_ENV:?GITHUB_ENV is required}"

GV_SPEC="6.x"
FILE="${GV_CONFIG:-}"

if [[ -n "$FILE" ]]; then
  if [[ -f "$FILE" ]]; then
    echo "$FILE exists"

    # Detect GitVersion major version from the config file syntax:
    #   label:  →  v6.x
    #   tag:    →  v5.x
    if grep -qE '^\s*label:' "$FILE"; then
      GV_SPEC="6.x"
      echo "Detected GitVersion 6.x config (found 'label:' in $FILE)"
    elif grep -qE '^\s*tag:' "$FILE"; then
      GV_SPEC="5.x"
      echo "Detected GitVersion 5.x config (found 'tag:' in $FILE)"
    else
      echo "No version-specific keywords detected in $FILE; defaulting to '$GV_SPEC'"
    fi
  else
    echo "::error file=$FILE::Repository versioning is managed by GitVersion, '$FILE' is therefore required!"
  fi
fi

# Export the resolved spec so subsequent steps can reference it via ${{ env.GV_SPEC }}
echo "GV_SPEC=$GV_SPEC" >> "$GITHUB_ENV"
