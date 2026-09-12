#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

# 镜像 tag：CI 传入 UPSTREAM_TAG（如 v1.36.0），本地构建回退为 v${VERSION}
IMAGE_TAG="${UPSTREAM_TAG:-v${VERSION}}"

echo "==> Building mdc ${VERSION} (Docker-based), image tag: ${IMAGE_TAG}"

dst=app_root
mkdir -p "$dst/docker"

cp apps/mdc/fnos/docker/docker-compose.yaml "$dst/docker/"
sed -i.bak "s/\${VERSION}/${IMAGE_TAG}/g" "$dst/docker/docker-compose.yaml"
rm -f "$dst/docker/docker-compose.yaml.bak"

cp -a apps/mdc/fnos/ui "$dst/ui"

cd app_root
tar -czf ../app.tgz .
