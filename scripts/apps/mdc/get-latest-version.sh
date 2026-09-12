#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  # 支持带 v 前缀的输入，统一去掉
  VERSION="${INPUT_VERSION#v}"
else
  VERSION=$(curl -fsSL "https://hub.docker.com/v2/repositories/mdcng/mdc/tags/?page_size=100&ordering=last_updated" | \
    jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/^v//' | sort -V | tail -1 || true)
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for mdc" >&2; exit 1; }

echo "VERSION=$VERSION"
echo "UPSTREAM_TAG=v${VERSION}"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=v${VERSION}" >> "$GITHUB_OUTPUT"
fi
