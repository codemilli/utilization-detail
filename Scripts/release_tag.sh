#!/bin/zsh

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./Scripts/release_tag.sh v0.1.1" >&2
  exit 1
fi

VERSION_TAG="$1"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "${ROOT_DIR}"

git fetch origin
git status --short

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or stash changes first." >&2
  exit 1
fi

if git rev-parse "${VERSION_TAG}" >/dev/null 2>&1; then
  echo "Tag ${VERSION_TAG} already exists locally." >&2
  exit 1
fi

git tag -a "${VERSION_TAG}" -m "Release ${VERSION_TAG}"
git push origin "${VERSION_TAG}"

echo "Pushed ${VERSION_TAG}. GitHub Actions will build and publish the release."
