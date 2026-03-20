#!/usr/bin/env bash
set -euo pipefail

# Create or move the rolling major and major.minor version tags to the current
# commit.
#
# This lets callers pin to a major or minor granularity (e.g. @v1 or @v1.2)
# rather than having to update to every patch release.
#
# MAJOR and MINOR are loaded from $GITHUB_ENV by the runner between steps.
# TAG_PREFIX is injected via the step's env: block from the tag-prefix input.

git config user.name "GitHub Actions Bot"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Move (or create) the major version tag, e.g. v1
TAG="${TAG_PREFIX}${MAJOR}"
echo "TAG=$TAG"
git tag -fa "$TAG" -m "move $TAG tag"
git push origin "$TAG" --force

# Move (or create) the major.minor version tag, e.g. v1.2
TAG="${TAG_PREFIX}${MAJOR}.${MINOR}"
echo "TAG=$TAG"
git tag -fa "$TAG" -m "move $TAG tag"
git push origin "$TAG" --force
