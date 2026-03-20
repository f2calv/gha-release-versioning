#!/usr/bin/env bash
set -euo pipefail

# Resolve the final SemVer components from whichever GitVersion source was used,
# or parse a manually supplied version string.
#
# When SEMVER_INPUT is provided the GitVersion tooling is skipped entirely and
# the individual version components are derived by string manipulation.
# When GitVersion ran via the "actions" source its outputs are available as
# env vars (GV_ACTIONS_*) injected by the step's env: block.
# For the "dotnet" and "container" sources the results are parsed from the
# GitVersion.json file written by the respective earlier steps.
#
# All resolved values are exported to $GITHUB_ENV so that subsequent steps can
# reference them as ${{ env.SEMVER }}, ${{ env.MAJOR }}, etc.

# Validate required environment variables
: "${GV_SOURCE:?GV_SOURCE is required}"
: "${GITHUB_ENV:?GITHUB_ENV is required}"

SEMVER="${SEMVER_INPUT:-}"

if [[ -z "$SEMVER" ]]; then
  # GitVersion was used — pick up the results from the appropriate source
  if [[ "${GV_SOURCE:-}" == "actions" ]]; then
    SEMVER="${GV_ACTIONS_SEMVER:-}"
    FULLSEMVER="${GV_ACTIONS_FULLSEMVER:-}"
    MAJOR="${GV_ACTIONS_MAJOR:-}"
    MINOR="${GV_ACTIONS_MINOR:-}"
    PATCH="${GV_ACTIONS_PATCH:-}"
  elif [[ "${GV_SOURCE:-}" == "container" ]] || [[ "${GV_SOURCE:-}" == "dotnet" ]]; then
    # Validate that GitVersion.json exists and is parseable before reading it
    if [[ ! -f "GitVersion.json" ]]; then
      echo "::error::GitVersion.json not found; ensure the gitversion ${GV_SOURCE} step ran successfully."
      exit 1
    fi
    if ! jq empty GitVersion.json 2>/dev/null; then
      echo "::error::GitVersion.json is not valid JSON:"
      cat GitVersion.json
      exit 1
    fi
    # Parse the JSON output produced by the container/dotnet steps
    SEMVER=$(jq -r '.SemVer' GitVersion.json)
    FULLSEMVER=$(jq -r '.FullSemVer' GitVersion.json)
    MAJOR=$(jq -r '.Major' GitVersion.json)
    MINOR=$(jq -r '.Minor' GitVersion.json)
    PATCH=$(jq -r '.Patch' GitVersion.json)
  fi
else
  # A manual semVer was supplied — derive the individual components.
  # Ref: https://gist.github.com/bitmvr/9ed42e1cc2aac799b123de9fdc59b016
  FULLSEMVER="$SEMVER"
  VERSION="${SEMVER#[vV]}"    # strip optional leading v/V prefix
  MAJOR="${VERSION%%\.*}"
  MINOR="${VERSION#*.}"
  MINOR="${MINOR%.*}"
  PATCH="${VERSION##*.}"
fi

# Export all components for use by subsequent steps
echo "SEMVER=$SEMVER"         >> "$GITHUB_ENV"
echo "FULLSEMVER=$FULLSEMVER" >> "$GITHUB_ENV"
echo "MAJOR=$MAJOR"           >> "$GITHUB_ENV"
echo "MINOR=$MINOR"           >> "$GITHUB_ENV"
echo "PATCH=$PATCH"           >> "$GITHUB_ENV"
