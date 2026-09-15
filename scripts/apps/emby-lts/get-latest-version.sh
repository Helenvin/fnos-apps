#!/bin/bash
set -euo pipefail

# Emby-LTS —— 版本锁定条目
#
# 与主条目 apps/emby 的区别：
#   apps/emby      每天跟随 MediaBrowser/Emby.Releases 的 Latest 自动升级
#   apps/emby-lts  版本被钉死在 PINNED_VERSION，永不自动升级
#
# 需要换锁定的版本时，改下面的 PINNED_VERSION 提交即可（会以新版本发布一次）。
PINNED_VERSION="4.10.0.40"

INPUT_VERSION="${1:-}"
VERSION="${INPUT_VERSION:-${PINNED_VERSION}}"

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for emby-lts" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
