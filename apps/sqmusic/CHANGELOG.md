## 2026-09-12

- 首次发布：simple_sq_music_plus v3.1.29 + 自研「发现」页补丁
- 发现页：QQ 25 个榜单匿名浏览、逐首下载、整榜批量下载；歌单广场分类浏览（解析下载需在设置中 QQ 扫码登录）
- 应用打开默认进入发现页；搜索/下载/解析/监听等原有功能全部保留
- 仅支持 x86（mysql:5.7 无 arm64 镜像）

## 2026-09-13 后端镜像源切换 GHCR

- sqmusic_main 镜像从作者 aliyun 源切换为上游官方 GHCR（ghcr.io/59799517/simple_sq_music_plus:v<ver>），同一构建产物；国内直连实测 ~3.2MB/s（aliyun OSS 仅 ~0.5MB/s），1.3GB 镜像拉取从约 48 分钟缩短到约 7 分钟。
- nginx / mysql 仍走 DOCKER_MIRROR 加速链。

## 2026-09-13 v3.2.0 多平台歌单监听（自研版）

- 后端基于 Helenvin/simple_sq_music_plus（3.0 分支）自研重构，版本号升级 3.2.0：
  - **新增酷我/酷狗/QQ音乐歌单监听下载**（原版仅支持网易云）：`ScanKwKgQqPlayList` 每分钟错峰扫描，
    与网易云一致的增量模式（歌单元数据回填 + sq_sync 防重），前提是在设置中开启对应插件。
  - 监听添加页支持粘贴酷我 `playlist_detail`、酷狗（含 global_collection_id）、QQ 塔歌/网页歌单链接。
  - QQ 歌单列表接口匿名化（原版强制要求 QQ VIP 登录后才能解析歌单，实测接口本身匿名可用）。
- sqmusic_main 镜像切换为自研版 GHCR：`ghcr.io/helenvin/simple_sq_music_plus:v<ver>`（由 fork CI 自动构建，双架构）。
- 前端补丁更新：监听页提示文案支持四平台；QQ 登录二维码获取失败时给出错误提示（原为静默空白）。
