# SQMusic 音乐下载站

基于 [Helenvin/simple_sq_music_plus](https://github.com/Helenvin/simple_sq_music_plus)（上游 [59799517/simple_sq_music_plus](https://github.com/59799517/simple_sq_music_plus)，fork 新增 **QQ 音乐公开歌单监听**）的 fnOS Docker 打包。
前端使用上游官方 v3 镜像，无本地补丁。

## 架构

| 容器 | 镜像 | 作用 |
|---|---|---|
| `sqmusic_main` | `ghcr.io/helenvin/simple_sq_music_plus:v<ver>`（fork CI 自动构建双架构镜像） | Java 多源下载引擎（kw/qq/qqvip/mg/netease/kg/tidal）+ 多平台歌单监听 |
| `sqmusic_web` | `ghcr.io/59799517/simple_sq_music_plus_web:v<webversion>` | 上游官方 v3 前端（nginx 托管 + `/api` 反代 `sqmusic_main:8099`） |
| `sqmusic_mysql` | `mysql:5.7` | 下载记录/账号（mysql:5.7 仅 amd64，故 `SUPPORTED_ARCH=x86`） |

- 单入口 `TRIM_SERVICE_PORT → sqmusic_web:80`；后端 8099 仅容器网络内可达。
- web 镜像 tag 由 `scripts/apps/sqmusic/build.sh` 从上游 `application.yml` 的 `webversion` 动态读取（失败回退 v3.1.5）。
- 容器名与上游官方 compose 模板一致，手动部署可通过安装向导填写旧音乐目录 / mysql_data 路径原地接管。

## QQ 歌单监听（fork 新增）

- 「监听」页添加 QQ 音乐歌单分享链接（`y.qq.com/n/ryqq_v2/playlist/...`、`ryqq/playlist/...` 或 `taoge.html?id=...`）即可自动增量下载；
- 公开歌单匿名添加（匿名 CgiGetDiss 拉取，无需登录），歌曲实际下载需在「设置 → 插件管理」完成 QQ 扫码登录（腾讯 GetVkey 接口限制）；
- 扫描任务每分钟运行，按歌单 `dirinfo.mtime` 做变更检测，歌单未更新时每歌单每分钟仅 1 次轻量请求；
- 下载码率固定 128/320 mp3（匿名接口无 file 字段，高码率请走搜索下载）。

## 本地构建

```bash
VERSION=3.1.30 bash scripts/apps/sqmusic/build.sh
bash scripts/build-fpk.sh apps/sqmusic app.tgz 3.1.30 x86
```
