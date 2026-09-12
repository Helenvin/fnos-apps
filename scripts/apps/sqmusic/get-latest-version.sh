#!/bin/bash
set -euo pipefail

# Resolve latest simple_sq_music_plus version from GitHub releases.
# Upstream tags look like 3.1.29 (no v prefix); the aliyun docker image tag is v3.1.29.
# Output: VERSION=x.y.z, UPSTREAM_TAG=x.y.z (+ GITHUB_OUTPUT when running in CI)

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
    VERSION="${INPUT_VERSION#v}"
else
    CURL_AUTH=()
    if [ -n "${GH_TOKEN:-}" ]; then
        CURL_AUTH=(-H "Authorization: Bearer ${GH_TOKEN}")
    fi
    VERSION=$(curl -fsSL "${CURL_AUTH[@]}" \
        "https://api.github.com/repos/59799517/simple_sq_music_plus/releases/latest" \
        | jq -r '.tag_name' | sed 's/^v//')
fi

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Failed to resolve valid version for sqmusic: '$VERSION'" >&2
    exit 1
fi

echo "VERSION=$VERSION"
echo "UPSTREAM_TAG=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
    echo "upstream_tag=$VERSION" >> "$GITHUB_OUTPUT"
fi
