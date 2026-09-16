#!/bin/bash
# 把「运行时载荷目录」打成 fnOS 装得下的 app.tgz。
#
# 背景（MoviePilot 踩过的坑）：
# fnOS 的安装器要自己解 app.tgz。一个装满解释器/venv/前端资源的载荷对它是病态的：
# MoviePilot 的载荷有 44,890 个成员、9,931 个超过 ustar 100 字节上限的名字（每个
# 都会变成一条 GNU ././@LongLink 记录）、1,056 个符号链接。真机上 fnOS 对这种
# app.tgz 直接报「解压app.tgz失败」。本仓在真机上装得起来的同类包（emby：363MB，
# 解压后 0.95GB）只有约 2,000 个成员、1 个长名字——体积只差 1.4 倍，成员数差 22 倍，
# 病根在成员数，不在体积。
#
# 所以：先把整个载荷压成一个不透明的 payload.tar.gz，app.tgz 里只放它和一份
# BUILD-INFO。fnOS 只需要创建两个文件；真正的目录树由应用自己的
# service_postinst / service_prestart 展开（见 apps/*/fnos/cmd/service-setup），
# 那边可以打日志、可重入、失败了下一次启动会重解。
#
# 随包的 Chromium 也在这里剔掉：它是载荷里最大的一块（解压后 729MB，占一半），
# 而上游 MoviePilot 本来就会按需把它下到 CLOAKBROWSER_CACHE_DIR。用 tar --exclude
# 而不是删目录，构建机上留下的 app_root 依然完整，方便排查。
#
# 用法：pack_runtime_payload <app_root 目录> <输出 app.tgz 路径>
#   app_root 的形状：里面是待安装内容（如 runtime/ 与 BUILD-INFO），顶层直接铺开。
#
# 注意：调用方（scripts/apps/*/build.sh）跑在 set -euo pipefail 下，所以这里
# 不能出现任何未定义变量的展开（写 `${X:-}`），也尽量不用靠 set -e 豁免规则
# 才不退出的写法。
#
# 改了这个库要连同引用它的应用一起提交（例如 scripts/apps/moviepilot/build.sh）：
# build-apps.yml 的变更检测是按 apps/** 与 scripts/apps/** 算矩阵的，只动
# scripts/lib/** 不会触发任何应用重建。

if [ -n "${_PACK_RUNTIME_PAYLOAD_LOADED:-}" ]; then
    return 0
fi
_PACK_RUNTIME_PAYLOAD_LOADED=1

pack_runtime_payload() {
    local app_root="${1:?pack_runtime_payload: 需要 app_root 目录}"
    local out="${2:?pack_runtime_payload: 需要输出 app.tgz 路径}"

    [ -d "$app_root" ] || { echo "pack_runtime_payload: 目录不存在: $app_root" >&2; return 1; }

    # 后面要 cd 到 stage 里打包，输出路径先转绝对
    case "$out" in
        /*) ;;
        *) out="$(pwd)/$out" ;;
    esac

    if [ -d "$app_root/runtime/browser" ]; then
        echo "==> 剔除随包 Chromium（$(du -sh "$app_root/runtime/browser" | cut -f1)，运行期按需下载）"
    fi

    # 保留一份构建信息在 app 根，排查线上问题时不用解开 venv
    if [ -f "$app_root/runtime/BUILD-INFO" ]; then
        install -m 0644 "$app_root/runtime/BUILD-INFO" "$app_root/BUILD-INFO"
    fi

    local stage
    stage="$(mktemp -d)"
    echo "==> 把载荷收成单文件 payload.tar.gz"
    tar -czf "$stage/payload.tar.gz" -C "$app_root" \
        --exclude='./runtime/browser' --exclude='./runtime/browser/*' .
    if [ -f "$app_root/BUILD-INFO" ]; then
        install -m 0644 "$app_root/BUILD-INFO" "$stage/BUILD-INFO"
    fi

    rm -f "$out"
    ( cd "$stage" && tar -czf "$out" . )
    rm -rf "$stage"

    local members
    members=$(tar -tzf "$out" | wc -l | tr -d ' ')
    echo "==> app.tgz: $(du -h "$out" | cut -f1)，成员数 ${members}"

    # 契约：外层只能是 ./ payload.tar.gz BUILD-INFO。成员数一旦涨回去，就说明有
    # 人把载荷直接铺进 app.tgz 了，那在真机上装不上，这里直接拦下来。
    if [ "${members:-0}" -gt 10 ]; then
        echo "!! app.tgz 有 ${members} 个成员，应为 3 个（./ payload.tar.gz BUILD-INFO）" >&2
        echo "!! 载荷必须保持为单个 payload.tar.gz，否则 fnOS 安装时会报「解压app.tgz失败」" >&2
        return 1
    fi
}
