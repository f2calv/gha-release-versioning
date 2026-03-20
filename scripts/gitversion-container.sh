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

# Extract the major version number from GV_SPEC (e.g., "5" from "5.x", "6" from "6.x")
# and use it as the Docker image tag so the correct GitVersion major is used.
GV_MAJOR="${GV_SPEC%%.*}"

# Capture stdout to a variable first so that any error output written to stdout
# does not corrupt GitVersion.json, and so that set -e can catch a non-zero exit
# before the file is written.
OUTPUT=$(docker run --rm \
  -v "$GITHUB_WORKSPACE:/repo" \
  -e GITHUB_ACTIONS=true \
  -e GITHUB_REF="$GITHUB_REF" \
  "gittools/gitversion:${GV_MAJOR}" /repo /nofetch)
echo "$OUTPUT" > GitVersion.json
cat GitVersion.json
