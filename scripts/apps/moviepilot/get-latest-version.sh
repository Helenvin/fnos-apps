#!/bin/bash
set -euo pipefail
# 上游 tag 形如 v3.0.3，manifest 里只写 3.0.3；运行时载荷的 release tag
# 由 build.sh 用 "runtime/v${VERSION}" 拼回去。
PINNED_VERSION="3.0.3"
INPUT_VERSION="${1:-}"

VERSION="${INPUT_VERSION#v}"

if [ -z "$VERSION" ] && [ -n "${GH_TOKEN:-}" ]; then
  VERSION="$(curl -fsSL \
      -H "Authorization: Bearer ${GH_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/jxxghp/MoviePilot/releases?per_page=50" \
    | jq -r '[.[] | select(.tag_name | test("^v3\\."))][0].tag_name // ""' \
    | sed 's/^v//')" || VERSION=""
fi

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  VERSION="$PINNED_VERSION"
fi

echo "VERSION=$VERSION"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
