# AVdb 影音自动化

基于 [Helenvin/AVdb-Only](https://github.com/Helenvin/AVdb-Only) 官方镜像（`docker.io/leolitaly/avdb`，amd64/arm64 多架构）的 fnOS 应用包。

- **WebUI**: 端口 8000
- **平滑迁移**: 数据默认存放在应用专属数据空间（TRIM_PKGVAR，fnOS 自动管理，卸载时可选择清除）；在安装向导中填写旧数据目录绝对路径（如 `/vol1/1000/docker/avdb/data`）即可原地继承手动部署的数据，容器名保持 `avdb`
- **MDC 联动**: 保留 `/var/run/docker.sock` 挂载（映射表变更后自动重启 MDC）与 `avdb_net` 桥接网络、4G 内存限制
- **版本规则**: 上游日期构建 tag `20260909-1521` → 归一化为 fnOS 兼容版本 `2026.9.9-1521`（`X.Y.Z-后缀`），同日多次构建不重号
- **自动跟踪**: CI 每日检查 Docker Hub `leolitaly/avdb` 的新日期 tag（自动排除 latest/dev/buildcache），自动重打包发布

## 本地构建

```bash
cd apps/avdb
./update_avdb.sh                       # 最新版本，自动检测架构
./update_avdb.sh --arch x86            # 指定 x86
./update_avdb.sh 2026.9.9-1521         # 指定归一化版本
./update_avdb.sh 20260909-1521         # 指定原始日期 tag
```

产物输出到仓库根目录 `dist/`。
