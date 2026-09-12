自动构建的 fnOS 安装包

- 基于 [simple_sq_music_plus ${UPSTREAM_TAG}](https://github.com/59799517/simple_sq_music_plus/releases/tag/${UPSTREAM_TAG}) 多源音乐下载引擎
- 内置自研「发现」页：QQ 25 个榜单匿名浏览、逐首下载、整榜批量下载；歌单广场分类浏览（解析下载需在设置中 QQ 扫码登录）
- 平台: fnOS x86（mysql 5.7 + Java 后端 + nginx 前端三容器）
- 默认端口: ${DEFAULT_PORT}（WebUI 单入口，打开即发现页）
- 容器名 sqmusic_main / sqmusic_web / sqmusic_mysql 与手动部署一致；安装向导可指定音乐目录与 MySQL 数据目录，原地接管既有部署${REVISION_NOTE}
${CHANGELOG}
