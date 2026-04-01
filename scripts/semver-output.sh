#!/usr/bin/env bash
set -euo pipefail

# Publish version components as step outputs so callers can reference them
# via steps.<id>.outputs.<name>.
#
# FULLSEMVER, MAJOR, MINOR and PATCH are loaded from $GITHUB_ENV (written by
# semver-select.sh).  RELEASE_EXISTS is injected via the step's env: block
# from the check-release-exists step output.

# Validate required environment variables
: "${FULLSEMVER:?FULLSEMVER is required}"
: "${MAJOR:?MAJOR is required}"
: "${MINOR:?MINOR is required}"
: "${PATCH:?PATCH is required}"
: "${RELEASE_EXISTS:?RELEASE_EXISTS is required}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"

echo "version=${FULLSEMVER}"            >> "$GITHUB_OUTPUT"
echo "major=${MAJOR}"                   >> "$GITHUB_OUTPUT"
echo "minor=${MINOR}"                   >> "$GITHUB_OUTPUT"
echo "patch=${PATCH}"                   >> "$GITHUB_OUTPUT"
echo "release-exists=${RELEASE_EXISTS}" >> "$GITHUB_OUTPUT"
