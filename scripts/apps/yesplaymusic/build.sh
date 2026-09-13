#!/bin/bash
set -euo pipefail

# Build app.tgz for yesplaymusic (Docker mode, single container).
# Inputs: $1=VERSION, env UPSTREAM_TAG (optional, upstream package.json version).
# Output: app.tgz in the repo root containing docker/ and ui/.

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

# GHCR image tag: v0.4.10 (workflow tags images v[package.json version])
IMAGE_TAG="v${UPSTREAM_TAG:-${VERSION}}"

echo "==> Building yesplaymusic ${VERSION} (Docker-based), image tag: ${IMAGE_TAG}"

dst=app_root
mkdir -p "$dst/docker"

# 1) compose: inject image tag with the canonical sed (see AGENTS.md anti-pattern #1)
cp apps/yesplaymusic/fnos/docker/docker-compose.yaml "$dst/docker/"
sed -i.bak "s/\${VERSION}/${IMAGE_TAG}/g" "$dst/docker/docker-compose.yaml"
rm -f "$dst/docker/docker-compose.yaml.bak"

# 2) UI
cp -a apps/yesplaymusic/fnos/ui "$dst/ui"

cd app_root
tar -czf ../app.tgz .