#!/usr/bin/env bash
set -euo pipefail

# Resolve the effective GitVersion version specification.
#
# The caller passes the user-supplied spec via GV_SPEC and the config file
# path via GV_CONFIG.  We inspect the config file to determine whether it uses
# the GitVersion v5 "tag:" syntax or the v6 "label:" syntax.  If the detected
# version differs from the input spec the detected value wins, so callers only
# need to supply the correct config file — they do not have to keep gv-spec in
# sync manually.

GV_SPEC="${GV_SPEC:-5.x}"
FILE="${GV_CONFIG:-}"

if [[ -n "$FILE" ]]; then
  if [[ -f "$FILE" ]]; then
    echo "$FILE exists"

    # Detect GitVersion major version from the config file syntax:
    #   label:  →  v6.x
    #   tag:    →  v5.x
    if grep -qE '^\s*label:' "$FILE"; then
      DETECTED="6.x"
    elif grep -qE '^\s*tag:' "$FILE"; then
      DETECTED="5.x"
    fi

    if [[ -n "${DETECTED:-}" ]]; then
      if [[ "$DETECTED" != "$GV_SPEC" ]]; then
        echo "Auto-detected GitVersion spec '$DETECTED' from $FILE (overrides input '$GV_SPEC')"
        GV_SPEC="$DETECTED"
      else
        echo "Auto-detected GitVersion spec '$DETECTED' from $FILE (matches input '$GV_SPEC')"
      fi
    else
      echo "No GitVersion spec detected in $FILE; using input '$GV_SPEC'"
    fi
  else
    echo "::error file=$FILE::Repository versioning is managed by GitVersion, '$FILE' is therefore required!"
  fi
fi

# Export the resolved spec so subsequent steps can reference it via ${{ env.GV_SPEC }}
echo "GV_SPEC=$GV_SPEC" >> "$GITHUB_ENV"
