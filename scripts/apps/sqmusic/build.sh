#!/bin/bash
set -euo pipefail

# Build app.tgz for sqmusic (Docker mode).
# Inputs: $1=VERSION, env UPSTREAM_TAG (optional, upstream tag without v prefix).
# Output: app.tgz in the repo root containing docker/ and ui/.

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

# GHCR image tag: v3.1.30 (workflow tags images v[version]; VERSION itself has no v prefix)
IMAGE_TAG="v${UPSTREAM_TAG:-${VERSION}}"

echo "==> Building sqmusic ${VERSION} (Docker-based), image tag: ${IMAGE_TAG}"

dst=app_root
mkdir -p "$dst/docker"

# 1) compose: inject backend image tag with the canonical sed (see AGENTS.md anti-pattern #1)
cp apps/sqmusic/fnos/docker/docker-compose.yaml "$dst/docker/"
sed -i.bak "s/\${VERSION}/${IMAGE_TAG}/g" "$dst/docker/docker-compose.yaml"
rm -f "$dst/docker/docker-compose.yaml.bak"

# 2) UI
cp -a apps/sqmusic/fnos/ui "$dst/ui"

# 3) web frontend image tag: read webversion from upstream application.yml at tag UPSTREAM_TAG, fallback v3.1.5
CURL_AUTH=()
if [ -n "${GH_TOKEN:-}" ]; then
    CURL_AUTH=(-H "Authorization: Bearer ${GH_TOKEN}")
fi
UPST="${UPSTREAM_TAG:-${VERSION}}"
WEB_TAG=""
UPSTREAM_YML=$(curl -fsSL "${CURL_AUTH[@]}" \
    "https://api.github.com/repos/Helenvin/simple_sq_music_plus/contents/src/main/resources/application.yml?ref=${UPST}" 2>/dev/null \
    | jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null || true)
if [ -n "${UPSTREAM_YML}" ]; then
    WEB_TAG=$(printf '%s\n' "${UPSTREAM_YML}" | grep -E '^webversion:' | head -1 | sed 's/^webversion:[[:space:]]*//' | tr -d '"' | sed 's/^/v/')
fi
if ! printf '%s' "${WEB_TAG}" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
    WEB_TAG="v3.1.5"
    echo "WARN: webversion fetch failed, fallback to ${WEB_TAG}" >&2
fi
echo "WEB_TAG=${WEB_TAG}"
sed -i.bak "s/\${WEB_TAG}/${WEB_TAG}/g" "$dst/docker/docker-compose.yaml"
rm -f "$dst/docker/docker-compose.yaml.bak"

cd app_root
tar -czf ../app.tgz .
