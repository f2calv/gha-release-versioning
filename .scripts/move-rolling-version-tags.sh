#!/usr/bin/env bash

# Create or force-move the rolling major and major.minor version tag aliases to
# the checked-out commit. The full version tag is created by action-gh-release.
#
# This lets callers pin to a major or minor granularity (e.g. @v1 or @v1.2)
# rather than having to update to every patch release.
#
# Required environment variables: TAG_PREFIX, MAJOR, MINOR
# MAJOR and MINOR are loaded from $GITHUB_ENV by the runner between steps.

for var in TAG_PREFIX MAJOR MINOR; do
	if [[ -z "${!var:-}" ]]; then
		echo "::error::Required environment variable $var is not set."
		exit 1
	fi
done

set -euo pipefail

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
