#!/bin/bash
set -euo pipefail

# Build app.tgz for sqmusic (Docker mode).
# Inputs: $1=VERSION, env UPSTREAM_TAG (optional, upstream tag without v prefix).
# Output: app.tgz in the repo root containing docker/, ui/ and webdist/.

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

# GHCR image tag: v3.2.3 (workflow tags images v[version]; VERSION itself has no v prefix)
IMAGE_TAG="v${UPSTREAM_TAG:-${VERSION}}"

echo "==> Building sqmusic ${VERSION} (Docker-based), image tag: ${IMAGE_TAG}"

dst=app_root
mkdir -p "$dst/docker" "$dst/webdist"

# 1) compose: inject image tag with the canonical sed (see AGENTS.md anti-pattern #1)
cp apps/sqmusic/fnos/docker/docker-compose.yaml "$dst/docker/"
sed -i.bak "s/\${VERSION}/${IMAGE_TAG}/g" "$dst/docker/docker-compose.yaml"
rm -f "$dst/docker/docker-compose.yaml.bak"

# 2) UI
cp -a apps/sqmusic/fnos/ui "$dst/ui"

# 3) Patched web frontend (Discover page) + nginx conf with /qq/ proxy
tar -xzf apps/sqmusic/webdist/dist.tgz -C "$dst/webdist"
[ -f "$dst/webdist/dist/index.html" ] || { echo "webdist/dist/index.html missing - rebuild dist.tgz (see apps/sqmusic/webpatch/README.md)" >&2; exit 1; }
[ -f "$dst/webdist/nginx.conf" ] || { echo "webdist/nginx.conf missing" >&2; exit 1; }

cd app_root
tar -czf ../app.tgz .
