#!/bin/bash
# Local build mirroring CI: resolve latest upstream version -> build.sh -> build-fpk.sh
# Usage: ./update_sqmusic.sh [version]
set -euo pipefail
cd "$(dirname "$0")/../.."

APP=sqmusic
VERSION_INPUT="${1:-}"

source "scripts/apps/${APP}/meta.env"

if [ -n "$VERSION_INPUT" ]; then
    VERSION="${VERSION_INPUT#v}"
else
    VERSION=$(bash "scripts/apps/${APP}/get-latest-version.sh" | grep '^VERSION=' | cut -d= -f2)
fi

echo "==> Building ${APP} ${VERSION}"
VERSION="$VERSION" bash "scripts/apps/${APP}/build.sh" "$VERSION"
bash scripts/build-fpk.sh "apps/${APP}" app.tgz "${VERSION}" x86

mkdir -p dist
FPK="${FILE_PREFIX}_${VERSION}_x86.fpk"
mv "$FPK" dist/
echo "==> dist/$FPK"
