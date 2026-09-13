#!/bin/bash
set -euo pipefail

# Resolve YesPlayMusic version from package.json on master (fork has no releases).
# The GHCR docker image tag is v<version> (workflow reads package.json version).

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
    VERSION="${INPUT_VERSION#v}"
else
    CURL_AUTH=()
    if [ -n "${GH_TOKEN:-}" ]; then
        CURL_AUTH=(-H "Authorization: Bearer ${GH_TOKEN}")
    fi
    VERSION=$(curl -fsSL "${CURL_AUTH[@]}" \
        "https://api.github.com/repos/Helenvin/YesPlayMusic/contents/package.json?ref=master" \
        | jq -r '.content' | base64 -d | jq -r '.version')
fi

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Failed to resolve valid version for yesplaymusic: '$VERSION'" >&2
    exit 1
fi

echo "VERSION=$VERSION"
echo "UPSTREAM_TAG=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
    echo "upstream_tag=$VERSION" >> "$GITHUB_OUTPUT"
fi