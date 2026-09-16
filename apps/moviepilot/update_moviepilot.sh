#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="moviepilot"
APP_DISPLAY_NAME="MoviePilot"
APP_VERSION_VAR="MOVIEPILOT_VERSION"
APP_VERSION="${MOVIEPILOT_VERSION:-latest}"
APP_DEPS=(curl tar zstd sha256sum)
APP_FPK_PREFIX="moviepilot"
APP_HELP_VERSION_EXAMPLE="3.0.3"

RUNTIME_REPO="Helenvin/moviepilot-fpk"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 3.0.3       # 指定版本，x86 架构
  $0 3.0.3                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/jxxghp/MoviePilot/releases" 2>/dev/null | \
        jq -r '[.[] | select(.tag_name | test("^v3\\."))][0].tag_name // ""' | sed 's/^v//')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 3.0.3"

    info "目标版本: $APP_VERSION"
}

app_download() {
    # 运行时载荷由 Helenvin/moviepilot-fpk 构建，这里只下载，不改内容。
    local runtime_url="https://github.com/${RUNTIME_REPO}/releases/download/runtime/v${APP_VERSION}/moviepilot-runtime-${TARBALL_ARCH}.tar.zst"

    info "下载运行时载荷 ($ARCH): $runtime_url"
    mkdir -p "$WORK_DIR"
    curl -L -f --retry 3 --retry-all-errors -o "$WORK_DIR/runtime.tar.zst" "$runtime_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/runtime.tar.zst" | cut -f1)"

    if curl -fsL --retry 3 --retry-all-errors \
        -o "$WORK_DIR/runtime.tar.zst.sha256" "${runtime_url}.sha256"; then
        ( cd "$WORK_DIR" && sha256sum -c runtime.tar.zst.sha256 ) || error "载荷校验失败"
    else
        warn "载荷未发布 .sha256，跳过校验"
    fi
}

app_build_app_tgz() {
    info "解包运行时载荷..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/runtime"
    tar --zstd -xf "$WORK_DIR/runtime.tar.zst" -C "$dst/runtime"

    [ -x "$dst/runtime/venv/bin/python" ] || error "载荷不完整: 缺少 venv/bin/python"
    [ -f "$dst/runtime/app/version.py" ] || error "载荷不完整: 缺少后端"

    # app.tgz 的形状由共享库统一保证：载荷收成一个不透明的 payload.tar.gz，并剔掉
    # 随包 Chromium。外层必须是 3 个成员，fnOS 的安装器才解得动——细节见那个库的注释。
    pack_runtime_payload "$dst" "$WORK_DIR/app.tgz"
}

source "$REPO_ROOT/scripts/lib/pack-runtime-payload.sh"
source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
