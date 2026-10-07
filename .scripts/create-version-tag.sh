#!/usr/bin/env bash

# Create the immutable full version tag at the requested commit without creating
# a GitHub Release. An existing tag is accepted only when it targets that commit.
# Required environment variables: SEMVER, TARGET_SHA
# Optional environment variables: TAG_PREFIX

if [[ -z "${SEMVER:-}" ]]; then
  echo "::error::Required environment variable SEMVER is not set."
  exit 1
fi

if [[ -z "${TARGET_SHA:-}" ]]; then
  echo "::error::Required environment variable TARGET_SHA is not set."
  exit 1
fi

: "${TAG_PREFIX:=}"

set -euo pipefail

tag="${TAG_PREFIX}${SEMVER}"
target_sha="$(git rev-parse "${TARGET_SHA}^{commit}")"
remote_target="$(git ls-remote --tags origin "refs/tags/${tag}^{}" | awk 'NR == 1 { print $1 }')"

if [[ -z "$remote_target" ]]; then
  remote_target="$(git ls-remote --tags origin "refs/tags/${tag}" | awk 'NR == 1 { print $1 }')"
fi

if [[ -n "$remote_target" ]]; then
  if [[ "$remote_target" == "$target_sha" ]]; then
    echo "Tag $tag already targets $target_sha."
    exit 0
  fi

  echo "::error::Tag $tag already exists at $remote_target; refusing to move it to $target_sha."
  exit 1
fi

git config user.name "GitHub Actions Bot"
git config user.email "github-actions[bot]@users.noreply.github.com"
git tag -a "$tag" "$target_sha" -m "$tag"
git push origin "refs/tags/$tag"