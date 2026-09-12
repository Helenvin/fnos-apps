# SQMusic 音乐下载站

基于 [Helenvin/simple_sq_music_plus](https://github.com/Helenvin/simple_sq_music_plus)（上游 [59799517/simple_sq_music_plus](https://github.com/59799517/simple_sq_music_plus) 的自研重构版，新增**酷我/酷狗/QQ音乐歌单监听下载**）的 fnOS Docker 打包，
外加自研的**「发现」页补丁**（`webpatch/`）：在官方 v3 前端里新增 QQ 音乐发现页，
打开应用即歌单广场/榜单，无需登录即可逐首或整榜下载。

## 架构

| 容器 | 镜像 | 作用 |
|---|---|---|
| `sqmusic_main` | `ghcr.io/helenvin/simple_sq_music_plus:v<ver>`（自研版，fork CI 自动构建双架构镜像） | Java 多源下载引擎（kw/qq/qqvip/mg/netease/kg/tidal）+ 多平台歌单监听 |
| `sqmusic_web` | `nginx:1.27-alpine` | 托管补丁版前端 + `/api` 反代后端 + `/qq/` 代理（注入 Referer 访问 QQ fcg 接口） |
| `sqmusic_mysql` | `mysql:5.7` | 下载记录/账号（mysql:5.7 仅 amd64，故 `SUPPORTED_ARCH=x86`） |

- 单入口 `TRIM_SERVICE_PORT → sqmusic_web:80`；后端 8099 仅容器网络内可达。
- 容器名与上游官方 compose 模板一致，手动部署可通过安装向导填写旧音乐目录 / mysql_data 路径原地接管。
- webdist 的 `dist.tgz` = 补丁版前端构建产物 + 补丁版 `nginx.conf`。

## 「发现」页功能（webpatch）

- **QQ 榜单**（匿名全功能）：25 个榜单（巅峰榜热歌/新歌/飙升/流行指数、说唱榜、电音榜等）
  → 歌曲列表 → 逐首下载 / 整榜并发下载（经后端 searchSong(qq) 换取原生 songData 再 downloadSong）。
- **歌单广场**（匿名浏览）：分类 × 分页浏览 QQ 歌单卡片；歌单详情与整单解析走后端
  `parserUrlInfo / downloadParserUrl`，需要在「设置 → 插件管理」完成 QQ 扫码登录（腾讯接口限制）。
- 下载直接进原有下载任务队列，监听下载/解析文本等原功能不受影响。

## 重建 webdist

见 `webpatch/README.md`（下载上游 v3 源码 → 覆盖补丁文件 → npm install → npm run build → 打包 dist.tgz）。

## 本地构建

```bash
VERSION=3.1.29 bash scripts/apps/sqmusic/build.sh
bash scripts/build-fpk.sh apps/sqmusic app.tgz 3.1.29 x86
# 或一键（自动取最新版本）：
bash apps/sqmusic/update_sqmusic.sh
```
