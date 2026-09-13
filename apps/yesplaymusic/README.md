# YesPlayMusic（fnOS 商店版）

[YesPlayMusic](https://github.com/qier222/YesPlayMusic) 网页客户端的单容器 Docker 打包（nginx 前端 + `@neteaseapireborn/api`），供 fnOS 应用中心安装。

## 特性

- 第三方网易云音乐播放器：每日推荐 / 私人 FM / 歌单广场 / 搜索 / 歌词 / 云盘
- 浏览器打开即用（`ui/config` type=url），单容器部署，端口默认 8100
- **SQMusic 联动（下载到 NAS）**：歌曲右键菜单「下载到 NAS（sqmusic）」→ 容器内 nginx `/sqmusic/` 反代 → SQMusic 后端搜索换票 → `POST /api/download/downloadSong` 入库，文件统一落盘 `/vol1/1000/audio/music`（与 SQMusic 共用音乐库）

## SQMusic 联动地址

镜像内 nginx 配置由 `docker/nginx.conf.example` 模板化（envsubst `${SQMUSIC_API}`），compose 注入：

```
SQMUSIC_API=${wizard_sqmusic_api:-http://172.17.0.1:8097}
```

fnOS 商店 SQMusic 的 WebUI 端口为 8097（其 nginx 已反代 `/api` 到后端）。如安装时改过端口，在 YesPlayMusic 安装向导中填写实际地址。

## 版本链路

- 应用版本跟随 `Helenvin/YesPlayMusic` master `package.json` 的 `version`（上游 0.4.x）
- GHCR 镜像：`ghcr.io/helenvin/yesplaymusic:v<version>`（`.github/workflows/build-ghcr.yml` 多架构构建）
- `get-latest-version.sh` 读 package.json version；`build.sh` 注入 `IMAGE_TAG=v<UPSTREAM_TAG>`
