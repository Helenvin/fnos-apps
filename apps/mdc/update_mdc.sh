#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="mdc"
APP_DISPLAY_NAME="MDC 影音整理"
APP_VERSION_VAR="MDC_VERSION"
APP_VERSION="${MDC_VERSION:-latest}"
APP_DEPS=(curl)
APP_FPK_PREFIX="mdc"
APP_HELP_VERSION_EXAMPLE="1.36.0"

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.36.0     # 指定版本，x86 架构
  $0 1.36.0                # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(bash "$REPO_ROOT/scripts/apps/mdc/get-latest-version.sh" | \
            grep '^VERSION=' | head -1 | cut -d= -f2)
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.36.0"

    info "目标版本: $APP_VERSION"
}

app_download() {
    info "Docker 镜像版本: mdcng/mdc:v${APP_VERSION}"
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker-based)..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/docker" "$dst/ui"

    cp "$PKG_DIR/docker/docker-compose.yaml" "$dst/docker/"
    sed -i.bak "s/\${VERSION}/v${APP_VERSION}/g" "$dst/docker/docker-compose.yaml"
    rm -f "$dst/docker/docker-compose.yaml.bak"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
