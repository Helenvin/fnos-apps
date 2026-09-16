自动构建的 fnOS 安装包

- 基于 [MoviePilot v${VERSION}](https://github.com/jxxghp/MoviePilot/releases/tag/v${VERSION})
- **原生运行**：自带 CPython 3.14、Node、前端与站点资源，不依赖 Docker；Chromium 不随包，首次使用浏览器仿真类站点时自动下载
- 安装包内只有一个不透明的载荷文件，真正的运行时由应用在安装时后台展开、启动前补齐（装完第一次启动要多等一会儿）
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/Helenvin/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/Helenvin/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
