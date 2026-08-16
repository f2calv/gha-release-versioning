#!/usr/bin/env bash
set -euo pipefail

# Run GitVersion inside the official Docker container.
#
# The workspace is mounted at /repo and GITHUB_ACTIONS/GITHUB_REF are forwarded
# so GitVersion behaves consistently with hosted runners.
# Outputs are written to GitVersion.json for consumption by the semver-select
# step.  /nofetch prevents GitVersion from fetching additional git history;
# full history is already available because actions/checkout ran with
# fetch-depth: 0.
#
# GV_SPEC is resolved by the gitversion-config-check step (written to
# $GITHUB_ENV) and is automatically available in this step's environment.

# Validate required environment variables
: "${GV_SPEC:?GV_SPEC is required}"
: "${GV_CONFIG:?GV_CONFIG is required}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
: "${GITHUB_REF:?GITHUB_REF is required}"

# Extract the major version number from GV_SPEC (e.g., "5" from "5.x", "6" from "6.x").
GV_MAJOR="${GV_SPEC%%.*}"

# Map the major version to a concrete Docker image tag.
# GitVersion 5.x: use the latest known 5.x release (5.12.0); Docker Hub does not
# publish major-only tags so we use an explicit version tag.
# GitVersion 6.x: 'latest' always tracks the current 6.x release.
if [[ "$GV_MAJOR" == "5" ]]; then
    GV_IMAGE_TAG="5.12.0"
else
    GV_IMAGE_TAG="latest"
fi

echo "Using Docker image: gittools/gitversion:${GV_IMAGE_TAG}"

# Capture stdout to a variable first so that any error output written to stdout
# does not corrupt GitVersion.json, and so that set -e can catch a non-zero exit
# before the file is written.
# The workspace is mounted at /repo inside the container, so the config path
# must use the /repo prefix.
OUTPUT=$(docker run --rm \
  -v "$GITHUB_WORKSPACE:/repo" \
  -e GITHUB_ACTIONS=true \
  -e GITHUB_REF="$GITHUB_REF" \
  "gittools/gitversion:${GV_IMAGE_TAG}" /repo /nofetch /config "/repo/${GV_CONFIG}")
echo "$OUTPUT" > GitVersion.json
cat GitVersion.json
