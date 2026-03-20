#!/usr/bin/env bash
set -euo pipefail

# Publish all version components as step outputs so that callers can reference
# them via steps.<id>.outputs.<name>.
#
# SEMVER, FULLSEMVER, MAJOR, MINOR and PATCH are loaded from $GITHUB_ENV by
# the runner between steps.  RELEASE_EXISTS is injected via the step's env:
# block from the check-release-exists step output.

# Validate required environment variables
: "${SEMVER:?SEMVER is required}"
: "${FULLSEMVER:?FULLSEMVER is required}"
: "${MAJOR:?MAJOR is required}"
: "${MINOR:?MINOR is required}"
: "${PATCH:?PATCH is required}"
: "${RELEASE_EXISTS:?RELEASE_EXISTS is required}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"

echo "semVer=${SEMVER}"                 >> "$GITHUB_OUTPUT"
echo "fullSemVer=${FULLSEMVER}"         >> "$GITHUB_OUTPUT"
echo "major=${MAJOR}"                   >> "$GITHUB_OUTPUT"
echo "minor=${MINOR}"                   >> "$GITHUB_OUTPUT"
echo "patch=${PATCH}"                   >> "$GITHUB_OUTPUT"
echo "release-exists=${RELEASE_EXISTS}" >> "$GITHUB_OUTPUT"
