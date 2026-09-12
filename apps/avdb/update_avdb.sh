#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="avdb"
APP_DISPLAY_NAME="AVdb 影音自动化"
APP_VERSION_VAR="AVDB_VERSION"
APP_VERSION="${AVDB_VERSION:-latest}"
APP_DEPS=(curl)
APP_FPK_PREFIX="avdb"
APP_HELP_VERSION_EXAMPLE="2026.9.9-1521"

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2026.9.9-1521      # 指定归一化版本，x86 架构
  $0 20260909-1521                 # 指定原始日期 tag，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(bash "$REPO_ROOT/scripts/apps/avdb/get-latest-version.sh" | \
            grep '^VERSION=' | head -1 | cut -d= -f2)
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2026.9.9-1521"

    info "目标版本: $APP_VERSION"
}

app_download() {
    info "Docker 镜像版本: leolitaly/avdb:${APP_VERSION}"
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker-based)..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/docker" "$dst/ui"

    # 归一化版本还原为原始日期 tag（YYYYMMDD-HHMM）
    local date_part suffix image_tag
    date_part="${APP_VERSION%%-*}"
    suffix="${APP_VERSION#*-}"
    local y m d
    IFS='.' read -r y m d <<< "$date_part"
    image_tag=$(printf '%04d%02d%02d-%s' "$y" "$m" "$d" "$suffix")

    cp "$PKG_DIR/docker/docker-compose.yaml" "$dst/docker/"
    sed -i.bak "s/\${VERSION}/${image_tag}/g" "$dst/docker/docker-compose.yaml"
    rm -f "$dst/docker/docker-compose.yaml.bak"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
