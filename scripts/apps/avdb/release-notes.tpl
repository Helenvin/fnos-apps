自动构建的 fnOS 安装包

- 基于 [leolitaly/avdb ${UPSTREAM_TAG}](https://hub.docker.com/r/leolitaly/avdb/tags)
- 上游源码: [Helenvin/AVdb-Only](https://github.com/Helenvin/AVdb-Only)
- 平台: fnOS（Docker 容器，镜像支持 amd64 / arm64）
- 默认端口: ${DEFAULT_PORT}
- 原地替换：安装向导默认接管既有手动部署的数据目录，保留 docker.sock 联动${REVISION_NOTE}
${CHANGELOG}
