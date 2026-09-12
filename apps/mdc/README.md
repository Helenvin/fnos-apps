# MDC 影音整理

基于 [mdcng/mdc](https://github.com/Helenvin/mdc-ng) Docker 镜像（`docker.io/mdcng/mdc`，amd64/arm64 多架构）的 fnOS 应用包。

- **WebUI**: 端口 9208
- **平滑迁移**: 数据默认存放在应用专属数据空间（TRIM_PKGVAR，fnOS 自动管理，卸载时可选择清除）；在安装向导中填写旧配置目录绝对路径即可原地继承手动部署的数据，容器名保持 `mdc`，外部联动不受影响
- **媒体库**: 安装向导填写一次（默认 `/vol1/1000`），挂载为容器 `/media`
- **自动跟踪**: CI 每日检查 Docker Hub `mdcng/mdc` 的新 semver tag（`v1.36.0` → manifest `1.36.0`），自动重打包发布

## 本地构建

```bash
cd apps/mdc
./update_mdc.sh              # 最新版本，自动检测架构
./update_mdc.sh --arch x86   # 指定 x86
./update_mdc.sh 1.36.0       # 指定版本
```

产物输出到仓库根目录 `dist/`。
