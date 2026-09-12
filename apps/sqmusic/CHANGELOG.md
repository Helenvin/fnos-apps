## 2026-09-12

- 首次发布：simple_sq_music_plus v3.1.29 + 自研「发现」页补丁
- 发现页：QQ 25 个榜单匿名浏览、逐首下载、整榜批量下载；歌单广场分类浏览（解析下载需在设置中 QQ 扫码登录）
- 应用打开默认进入发现页；搜索/下载/解析/监听等原有功能全部保留
- 仅支持 x86（mysql:5.7 无 arm64 镜像）

## 2026-09-13 后端镜像源切换 GHCR

- sqmusic_main 镜像从作者 aliyun 源切换为上游官方 GHCR（ghcr.io/59799517/simple_sq_music_plus:v<ver>），同一构建产物；国内直连实测 ~3.2MB/s（aliyun OSS 仅 ~0.5MB/s），1.3GB 镜像拉取从约 48 分钟缩短到约 7 分钟。
- nginx / mysql 仍走 DOCKER_MIRROR 加速链。
