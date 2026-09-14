#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"
DEB_ARCH="${2:-${DEB_ARCH:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }
[ -z "${DEB_ARCH}" ] && { echo "DEB_ARCH is required" >&2; exit 1; }

echo "==> Building Emby ${VERSION} (${DEB_ARCH})"
curl -fL -o emby.deb "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-deb_${VERSION}_${DEB_ARCH}.deb"
ar -x emby.deb
mkdir -p extracted
tar -xf data.tar.xz -C extracted

src=extracted/opt/emby-server
dst=app_root
mkdir -p "$dst"
for dir in bin etc extra lib licenses share system; do
  [ -d "$src/$dir" ] && cp -a "$src/$dir" "$dst/"
done
mkdir -p "$dst/config" "$dst/ui/images"

# 预置插件：apps/emby/plugins/<插件名>/… → 应用内 plugins-default/
if [ -d apps/emby/plugins ] && [ -n "$(ls -A apps/emby/plugins 2>/dev/null)" ]; then
  mkdir -p "$dst/plugins-default"
  tar -cf - -C apps/emby/plugins \
    --exclude='README.md' --exclude='.gitkeep' --exclude='.*' . \
    | tar -xf - -C "$dst/plugins-default"
  echo "==> Plugins bundled: $(ls -A "$dst/plugins-default" | wc -l | tr -d ' ') item(s)"
else
  echo "==> No bundled plugins"
fi

cp apps/emby/fnos/EmbyServer.sc "$dst/"
cp apps/emby/fnos/config/* "$dst/config/"
cp -a apps/emby/fnos/ui/* "$dst/ui/"
cp apps/emby/fnos/bin/emby-server "$dst/bin/emby-server"
chmod +x "$dst/bin/emby-server"

cd app_root
tar -czf ../app.tgz .
