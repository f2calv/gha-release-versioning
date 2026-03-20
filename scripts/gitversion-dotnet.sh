#!/usr/bin/env bash
set -euo pipefail

# Run GitVersion via the .NET global tool installed in the previous step.
#
# Outputs are written to GitVersion.json for consumption by the semver-select
# step.  /nofetch prevents GitVersion from fetching additional git history;
# full history is already available because actions/checkout ran with
# fetch-depth: 0.

GV_MAJOR="${GV_SPEC%%.*}"

# Install the correct major version of GitVersion.Tool to match GV_SPEC.
# Without a version constraint, 'dotnet tool update' always installs the latest
# release, which cannot parse config files from a different major version.
dotnet tool update -g GitVersion.Tool --version "${GV_MAJOR}.*"

# Capture stdout to a variable first so that any error output written to stdout
# does not corrupt GitVersion.json, and so that set -e can catch a non-zero exit
# before the file is written.
# Use an absolute config path so GitVersion finds the correct file regardless of
# the current working directory.
OUTPUT=$("$HOME/.dotnet/tools/dotnet-gitversion" "$GITHUB_WORKSPACE" /nofetch /config "${GITHUB_WORKSPACE}/${GV_CONFIG}")
echo "$OUTPUT" > GitVersion.json
cat GitVersion.json
