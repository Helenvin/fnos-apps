#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# 原始日期 tag（YYYYMMDD-HHMM）→ 归一化版本（Y.M.D-HHMM，符合 fnOS X.Y.Z-后缀）
raw_to_version() {
    local raw="$1"
    local y="${raw:0:4}" m="$((10#${raw:4:2}))" d="$((10#${raw:6:2}))" s="${raw#*-}"
    echo "${y}.${m}.${d}-${s}"
}

# 归一化版本 → 原始日期 tag（镜像 tag 用）
version_to_raw() {
    local v="$1"
    local date_part="${v%%-*}" suffix="${v#*-}"
    local y m d
    IFS='.' read -r y m d <<< "$date_part"
    printf '%04d%02d%02d-%s' "$y" "$m" "$d" "$suffix"
}

if [ -n "$INPUT_VERSION" ]; then
  if [[ "$INPUT_VERSION" =~ ^[0-9]{8}-[0-9]{4}$ ]]; then
    UPSTREAM_TAG="$INPUT_VERSION"
    VERSION="$(raw_to_version "$INPUT_VERSION")"
  else
    VERSION="$INPUT_VERSION"
    UPSTREAM_TAG="$(version_to_raw "$INPUT_VERSION")"
  fi
else
  # Docker Hub 按 last_updated 排序，仅匹配日期构建 tag（自动排除 latest/dev/buildcache 等）
  UPSTREAM_TAG=$(curl -fsSL "https://hub.docker.com/v2/repositories/leolitaly/avdb/tags/?page_size=100&ordering=last_updated" | \
    jq -r '.results[].name' | grep -E '^[0-9]{8}-[0-9]{4}$' | head -1 || true)
  [ -z "$UPSTREAM_TAG" ] && { echo "Failed to resolve version for avdb" >&2; exit 1; }
  VERSION="$(raw_to_version "$UPSTREAM_TAG")"
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for avdb" >&2; exit 1; }

echo "VERSION=$VERSION"
echo "UPSTREAM_TAG=$UPSTREAM_TAG"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=$UPSTREAM_TAG" >> "$GITHUB_OUTPUT"
fi
