#!/usr/bin/env bash
set -euo pipefail

# Run GitVersion via the .NET global tool installed in the previous step.
#
# Outputs are written to GitVersion.json for consumption by the semver-select
# step.  /nofetch prevents GitVersion from fetching additional git history;
# full history is already available because actions/checkout ran with
# fetch-depth: 0.

dotnet tool update -g GitVersion.Tool

# Capture stdout to a variable first so that any error output written to stdout
# does not corrupt GitVersion.json, and so that set -e can catch a non-zero exit
# before the file is written.
OUTPUT=$("$HOME/.dotnet/tools/dotnet-gitversion" "$GITHUB_WORKSPACE" /nofetch)
echo "$OUTPUT" > GitVersion.json
cat GitVersion.json
