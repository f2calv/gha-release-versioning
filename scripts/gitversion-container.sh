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

# Extract the major version number from GV_SPEC (e.g., "5" from "5.x", "6" from "6.x").
GV_MAJOR="${GV_SPEC%%.*}"
export GV_MAJOR

# The gittools/gitversion Docker Hub registry does not publish major-version-only
# tags (e.g. ':5' or ':6'). Query Docker Hub to find the latest simple X.Y.Z tag
# for this major version so we always use an actual published image.
GV_IMAGE_TAG=$(curl --silent --fail \
  "https://hub.docker.com/v2/repositories/gittools/gitversion/tags/?page_size=100&ordering=-last_updated" | \
  python3 -c "
import json, sys, os
major = os.environ['GV_MAJOR']
data = json.load(sys.stdin)
tags = [
    t['name'] for t in data.get('results', [])
    if t['name'].startswith(major + '.') and '-' not in t['name']
]
if not tags:
    print(f'::error::No gittools/gitversion Docker image tag found for major version {major}', file=sys.stderr)
    sys.exit(1)
print(tags[0])
") || { echo "::error::Failed to query Docker Hub for gittools/gitversion tags"; exit 1; }

echo "Using Docker image: gittools/gitversion:${GV_IMAGE_TAG}"

# Capture stdout to a variable first so that any error output written to stdout
# does not corrupt GitVersion.json, and so that set -e can catch a non-zero exit
# before the file is written.
OUTPUT=$(docker run --rm \
  -v "$GITHUB_WORKSPACE:/repo" \
  -e GITHUB_ACTIONS=true \
  -e GITHUB_REF="$GITHUB_REF" \
  "gittools/gitversion:${GV_IMAGE_TAG}" /repo /nofetch)
echo "$OUTPUT" > GitVersion.json
cat GitVersion.json
