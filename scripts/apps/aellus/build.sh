#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
# Upstream asset names: Aellus-<version>-linux-x64 / Aellus-<version>-linux-arm64.
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_SUFFIX="x64" ;;
  arm64) UPSTREAM_SUFFIX="arm64" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Aellus ${VERSION} for linux-${UPSTREAM_SUFFIX}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Bare static Go ELF binary, no archive wrapper.
curl -fL -o "$WORK_DIR/aellus" \
  "https://github.com/YGQ8988/Aellus/releases/download/${VERSION}/Aellus-${VERSION}-linux-${UPSTREAM_SUFFIX}"
chmod +x "$WORK_DIR/aellus"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"

cp "$WORK_DIR/aellus" "$WORK_DIR/app_root/aellus"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/aellus/fnos/bin/aellus-server" "$WORK_DIR/app_root/bin/aellus-server"
chmod +x "$WORK_DIR/app_root/bin/aellus-server"
cp -a "${SCRIPT_DIR}/../../../apps/aellus/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for Aellus ${VERSION} (linux-${UPSTREAM_SUFFIX})"
