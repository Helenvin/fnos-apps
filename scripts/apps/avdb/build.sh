#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

# 镜像 tag：CI 传入 UPSTREAM_TAG（如 20260909-1521），本地构建从归一化版本还原
if [ -n "${UPSTREAM_TAG:-}" ]; then
    IMAGE_TAG="$UPSTREAM_TAG"
else
    date_part="${VERSION%%-*}"
    suffix="${VERSION#*-}"
    local_y=0; local_m=0; local_d=0
    IFS='.' read -r local_y local_m local_d <<< "$date_part"
    IMAGE_TAG=$(printf '%04d%02d%02d-%s' "$local_y" "$local_m" "$local_d" "$suffix")
fi

echo "==> Building avdb ${VERSION} (Docker-based), image tag: ${IMAGE_TAG}"

dst=app_root
mkdir -p "$dst/docker"

cp apps/avdb/fnos/docker/docker-compose.yaml "$dst/docker/"
sed -i.bak "s/\${VERSION}/${IMAGE_TAG}/g" "$dst/docker/docker-compose.yaml"
rm -f "$dst/docker/docker-compose.yaml.bak"

cp -a apps/avdb/fnos/ui "$dst/ui"

cd app_root
tar -czf ../app.tgz .
