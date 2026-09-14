自动构建的 fnOS 安装包

- 基于 [simple_sq_music_plus ${UPSTREAM_TAG}](https://github.com/Helenvin/simple_sq_music_plus/releases/tag/${UPSTREAM_TAG}) 多源音乐下载引擎（fork 新增 QQ 音乐公开歌单监听）
- 歌单监听下载：网易云/QQ 音乐歌单均可在「监听」页添加分享链接自动增量下载（QQ 公开歌单匿名添加，歌曲下载需在设置中 QQ 扫码登录）
- 七源搜索（kw/qq/qqvip/mg/netease/kg/tidal）、歌单/专辑/单曲解析下载、标签歌词，上游官方 v3 前端
- 平台: fnOS x86（mysql 5.7 + Java 后端 + nginx 前端三容器）
- 默认端口: ${DEFAULT_PORT}
- 容器名 sqmusic_main / sqmusic_web / sqmusic_mysql 与上游官方 compose 一致；安装向导可指定音乐目录与 MySQL 数据目录，原地接管既有部署${REVISION_NOTE}
${CHANGELOG}
