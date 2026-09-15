# Emby-LTS

EmbyServer 媒体服务器的**版本锁定版** —— 固定 4.10.0.40，不随上游每日更新。

## 与 `emby` 条目的区别

| | `emby` | `emby-lts` |
|---|---|---|
| 版本来源 | 每天自动跟随 MediaBrowser/Emby.Releases 的 Latest | 锁定 4.10.0.40，永不自动变 |
| App ID | `embyserver` | `embyserverlts` |
| 桌面入口 | `embyserver.Application` | `embyserverlts.Application` |
| 数据目录 | `/var/apps/embyserver/shares/embyserver` | `/var/apps/embyserverlts/shares/embyserverlts` |

两条目在商店并存，**可同时安装**（App ID 与数据目录完全隔离，互不覆盖）。

## 注意：不能同时运行

两者默认都占用 **8096 端口**，且底层真实进程名同为 deb 里的 `EmbyServer`：

- 端口冲突 → 后启动的那个起不来
- `service_preuninst` / `service_poststop` 里有 `pkill -x "EmbyServer"` 兜底清理 → 停掉一个时可能连带终止另一个的进程

因此请**停掉其中一个再启动另一个**，作为切换使用；不要指望两者并行提供服务。

## 如何更换锁定的版本

编辑 `scripts/apps/emby-lts/get-latest-version.sh` 里的 `PINNED_VERSION`，改完提交即可。CI 下次扫描到时会当作新版本发布一次（之后继续钉在这个新版本上）。

```bash
PINNED_VERSION="4.10.0.40"
```

## 打包说明

与原版 Emby 完全一致：直接下载 MediaBrowser/Emby.Releases 官方 `.deb` 并提取重打包，不修改任何上游业务逻辑。以 root 运行并加入 `video` / `render` 组，保留硬件转码能力。
