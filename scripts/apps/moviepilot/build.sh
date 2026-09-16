#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
TARBALL_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# 载荷打包逻辑（收成单个 payload.tar.gz、剔掉随包 Chromium）在 scripts/lib/ 里，
# 与本地构建 apps/moviepilot/update_moviepilot.sh 共用同一份实现。
# 两点约束：
#   1) 那个库必须能在本脚本的 set -euo pipefail 下被 source（-u 会在首次 source 时
#      把没兜底的变量引用直接变成致命错误，踩过一次，两个架构一起挂）
#   2) 改那个库时要连着本文件一起提交：build-apps.yml 的变更检测只看 apps/** 与
#      scripts/apps/**，只动 scripts/lib/** 不会触发任何应用重建
# shellcheck source=../../lib/pack-runtime-payload.sh
. "$REPO_ROOT/scripts/lib/pack-runtime-payload.sh"

# 运行时载荷（CPython 3.14 + venv + Node + 前端 + 站点资源 + 随包 Chromium）由
# Helenvin/moviepilot-fpk 在 debian:12 上构建，release tag 与上游 tag 对齐。
# 这里只做下载 + 校验 + 重新打包，绝不改动载荷内容。
RUNTIME_REPO="Helenvin/moviepilot-fpk"
RUNTIME_TAG="runtime/v${VERSION}"
RUNTIME_FILE="moviepilot-runtime-${TARBALL_ARCH}.tar.zst"
RUNTIME_URL="https://github.com/${RUNTIME_REPO}/releases/download/${RUNTIME_TAG}/${RUNTIME_FILE}"

echo "==> Building MoviePilot ${VERSION} for ${TARBALL_ARCH}"
echo "    runtime: ${RUNTIME_URL}"

command -v zstd >/dev/null 2>&1 || { echo "zstd is required to unpack the runtime" >&2; exit 1; }

curl -fL --retry 3 --retry-all-errors -o "$RUNTIME_FILE" "$RUNTIME_URL"

if curl -fsL --retry 3 --retry-all-errors -o "${RUNTIME_FILE}.sha256" "${RUNTIME_URL}.sha256"; then
    sha256sum -c "${RUNTIME_FILE}.sha256"
else
    echo "warning: ${RUNTIME_FILE}.sha256 未发布，跳过校验" >&2
fi

rm -rf app_root
mkdir -p app_root/runtime
tar --zstd -xf "$RUNTIME_FILE" -C app_root/runtime
rm -f "$RUNTIME_FILE" "${RUNTIME_FILE}.sha256"

# 载荷形状自检：少任何一块都说明下载到的不是我们发布的东西
[ -x app_root/runtime/venv/bin/python ] || { echo "payload invalid: venv/bin/python missing" >&2; exit 1; }
[ -f app_root/runtime/app/version.py ] || { echo "payload invalid: backend missing" >&2; exit 1; }
[ -f app_root/runtime/app/public/service.js ] || { echo "payload invalid: frontend missing" >&2; exit 1; }

echo "==> payload unpacked:"
du -sh app_root/runtime/* | sort -h

# app.tgz 的形状由共享库统一保证：载荷收成一个不透明的 payload.tar.gz，并剔掉随包
# Chromium。外层必须是 3 个成员，fnOS 的安装器才解得动——细节见那个库的注释。
pack_runtime_payload app_root app.tgz
