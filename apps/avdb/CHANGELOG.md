## 2026-09-12

- 首次发布：基于 leolitaly/avdb（多架构镜像），安装向导默认接管既有手动部署的 /data 数据目录，原数据库/规则/下载记录无缝继承，保留 docker.sock 联动与 avdb_net 网络
- 调整：数据目录默认改为应用专属数据空间（TRIM_PKGVAR，向导留空即用默认），继承旧数据改为在向导中填写旧路径（如 /vol1/1000/docker/avdb/data）；PUID/PGID 改用 fnOS 注入的 TRIM_UID/TRIM_GID（兜底 1000）
