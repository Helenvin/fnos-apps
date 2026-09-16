# MoviePilot for fnOS（原生版）

把 [MoviePilot](https://github.com/jxxghp/MoviePilot) v3 **原生**跑在 fnOS 上，不需要 Docker。

## 下载

从 [Releases](https://github.com/Helenvin/fnos-apps/releases?q=moviepilot) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件（x86 / arm）
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:3300`

> 端口是 3300 而不是 MoviePilot 默认的 3000（商店条目固定端口，
> 3000 留给其它下载/影视工具，避免冲突）。

## 说明

- 自带完整运行时：CPython 3.14、后端虚拟环境、Node、前端与站点资源，不需要 Docker，也不需要装 Python
- **不内置 Chromium**：浏览器仿真类站点（仿真登录、Cloudflare 等）第一次用到时，MoviePilot 会自己下载一份到应用数据目录（约 200MB），下载期间该类站点不可用，主体功能不受影响
- 安装时会用 `apt` 补 Chromium 依赖的系统库，首次安装耗时较长；补不上只会让浏览器仿真类站点不可用，不影响主体功能
- **安装分两步**：fnOS 先把载荷落盘，应用自己在后台展开（解压后约 1GB、4 万多个文件），所以装完后**第一次启动要多等一会儿**（视磁盘而定，几分钟内）。展开是可重入的，中途断电或重启，下次启动会接着做完
- 数据（数据库、日志、缓存、cookies）都在应用数据目录里，卸载时按向导选择是否保留
- 应用以 root 运行，并在 `config/privilege` 里用 `folder-permission` 预声明了 `/vol1/1000` 的**读写**权限，装完即可直接读写媒体库，不需要再手动配

> fnOS 会限制应用能访问的目录范围。除了包里预声明的 `/vol1/1000`，如果你还要让
> MoviePilot 读写别的路径（例如 `/vol2/media`），去 **fnOS 应用管理 → MoviePilot →
> 设置 → 目录授权** 把该目录加进去并选「读写」，然后重启应用。

## 首次配置

1. 打开 `http://<NAS-IP>:3300`，用初始账号登录
2. 在「设定 → 目录」里把下载目录、媒体库目录指向自己的共享路径（例如 `/vol1/1000/media`）
3. 在「设定 → 下载器 / 媒体服务器」里接上 qBittorrent、Emby 等

## 本地构建

```bash
./update_moviepilot.sh                    # 最新版本，自动检测架构
./update_moviepilot.sh --arch arm         # 指定架构
./update_moviepilot.sh --arch arm 3.0.3   # 指定版本
./update_moviepilot.sh --help             # 查看帮助
```

本地构建依赖 `Helenvin/moviepilot-fpk` 已经发布好对应版本的运行时载荷
（release tag 为 `runtime/v<版本>`）。

## 版本标签

- `moviepilot/v3.0.3` — 首次发布
- `moviepilot/v3.0.3-r2` — 同版本打包修订
- `moviepilot/v3.0.3-r3` — 修复安装时报「解压app.tgz失败」（载荷改为单文件、不随包 Chromium）

## Credits

- [MoviePilot](https://github.com/jxxghp/MoviePilot) - NAS 媒体库自动化管理工具
