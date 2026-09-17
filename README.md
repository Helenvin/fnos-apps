# fnOS Apps

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Apps](https://img.shields.io/badge/apps-195-2ea44f)
![Platform](https://img.shields.io/badge/fnOS-third--party-orange)

面向飞牛 fnOS 的第三方应用打包仓库。自动跟踪上游版本，构建可直接安装的 `.fpk` 包。

> ⭐️ 如果觉得本项目对你有帮助，请右上角点个 Star！

## 应用一览

> 💡 推荐先安装 **fnOS Apps** 应用中心，可一键管理以下所有应用的安装与更新。

### 📦 应用中心

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/fnos-apps-store/fnos/ICON.PNG" width="28"> | **fnOS Apps** | `8011` | 第三方应用中心，一键安装与更新 | [GitHub](https://github.com/conversun/fnos-store) | [Release][r-store] |


### 🧩 原生工具（镜像自 RROrg/fn-apps）

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="native-assets/fn-VirtualHereServer/ICON_256.PNG" width="28"> | **VirtualHereServer** | — | VirtualHere USB 服务端，支持通过网络远程访问 USB 设备。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-VirtualHereServer] |
| <img src="native-assets/fn-WParted/ICON_256.PNG" width="28"> | **WParted** | — | 磁盘分区编辑器 - 创建、调整大小、删除、移动、复制、检查和格式化分区。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-WParted] |
| <img src="native-assets/fn-advancedsettings/ICON_256.PNG" width="28"> | **高级设置** | — | 管理启动设置、电源设置、屏幕设置、SSH设置、CPU设置、DNS设置、网络设置、代理设置、设备信息、端口信息、进程管理、服务管理、网络诊断。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-advancedsettings] |
| <img src="native-assets/fn-appdownload/ICON_256.PNG" width="28"> | **应用下载** | — | 官方商店和第三方源应用下载（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-appdownload] |
| <img src="native-assets/fn-appsettings/ICON_256.PNG" width="28"> | **应用设置** | — | 设置已安装应用的数据（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-appsettings] |
| <img src="native-assets/fn-audioplayer/ICON_256.PNG" width="28"> | **音频播放器** | — | 音频播放器应用，用于播放音频文件。支持包括 mp3、wav、flac、ogg、m4a、aac、wma、ape 等格式，会自动加载音频文件所在目录的歌词文件；支持客户端和服务端两种模式。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-audioplayer] |
| <img src="native-assets/fn-bluetooth/ICON_256.PNG" width="28"> | **蓝牙** | — | 蓝牙设备管理工具，支持配对连接音频设备、键鼠、文件传输、共享网络等功能。支持客户端模式（扫描连接）和服务端模式（接受连接）。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-bluetooth] |
| <img src="native-assets/fn-codeserver/ICON_256.PNG" width="28"> | **code-server** | — | code-server 是 VS Code 的在线版本，允许您通过浏览器进行代码编辑和开发。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-codeserver] |
| <img src="native-assets/fn-execute/ICON_256.PNG" width="28"> | **执行器** | — | 执行器可直接在可执行程序上右键执行，支持 sh、py、pl、rb、js、ts、lua、bash、zsh、fish、bin、run 等格式的文件。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-execute] |
| <img src="native-assets/fn-fail2ban/ICON_256.PNG" width="28"> | **fail2ban** | — | fail2ban 是一个开源的入侵防御工具，用于保护 Linux 服务器免受暴力破解攻击。 它通过监控日志文件，检测可疑的登录尝试，并自动封禁恶意 IP 地址，从而增强系统的安全性。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-fail2ban] |
| <img src="native-assets/fn-grafana-alloy/ICON_256.PNG" width="28"> | **Grafana Alloy** | — | 可观测性数据采集器，收集系统和应用日志并发送到 Loki。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-grafana-alloy] |
| <img src="native-assets/fn-iVentoy/ICON_256.PNG" width="28"> | **iVentoy** | — | iVentoy - PXE 启动服务器，支持通过局域网网络安装操作系统。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-iVentoy] |
| <img src="native-assets/fn-influxdb/ICON_256.PNG" width="28"> | **InfluxDB** | — | 高性能时序数据库，适用于指标、事件和分析工作负载。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-influxdb] |
| <img src="native-assets/fn-installer/ICON_256.PNG" width="28"> | **安装器** | — | 安装器，用于安装本地 FPK 应用文件。支持右键安装。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-installer] |
| <img src="native-assets/fn-linux-station/ICON_256.PNG" width="28"> | **linux-station** | `5900` | Linux 工作站是一个基于 Linux 的桌面环境，旨在为用户提供一个高效、稳定和易用的工作环境。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-linux-station] |
| <img src="native-assets/fn-p2s/ICON_256.PNG" width="28"> | **端口代理** | — | 通过 fnOS 应用网关路径访问本机端口服务。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-p2s] |
| <img src="native-assets/fn-scheduler/ICON_256.PNG" width="28"> | **任务计划** | — | 轻量级的任务计划应用，支持设置定时任务以自动执行脚本或命令，同时也支持基于条件的任务触发。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-scheduler] |
| <img src="native-assets/fn-scrutiny/ICON_256.PNG" width="28"> | **Scrutiny** | — | 硬盘 S.M.A.R.T 健康监控，集成 Scrutiny Web 与 Collector，提供可视化硬盘健康状态追踪。依赖 InfluxDB。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-scrutiny] |
| <img src="native-assets/fn-speedtest/ICON_256.PNG" width="28"> | **网络测速** | — | 测量客户端到服务器的速率，以及服务器到外网的出口速率。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-speedtest] |
| <img src="native-assets/fn-terminal/ICON_256.PNG" width="28"> | **terminal** | — | terminal (ttyd + tmux) 是一个基于 Web 的终端应用程序，允许用户通过浏览器访问和管理服务器终端会话，提供便捷的远程终端操作体验。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-terminal] |
| <img src="native-assets/fn-vgmng/ICON_256.PNG" width="28"> | **存储池管理** | — | 存储池管理, 支持非飞牛存储池(其他NAS系统存储池)的管理。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-vgmng] |
| <img src="native-assets/fn-wifi-hotspot/ICON_256.PNG" width="28"> | **无线热点** | — | 无线热点创建工具，允许用户轻松地将计算机变成一个 Wi-Fi 热点，分享网络连接给其他设备。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-wifi-hotspot] |
| <img src="native-assets/fn-zerotier/ICON_256.PNG" width="28"> | **ZeroTier** | — | ZeroTier 是一个无中心的虚拟网络，无需配置即可连接设备。（镜像自 RROrg/fn-apps，随上游每日自动同步） | [RROrg/fn-apps](https://github.com/RROrg/fn-apps) | [Release][r-fn-zerotier] |

### 🤖 AI

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/copaw/fnos/ICON.PNG" width="28"> | **CoPaw** | `8088` | 基于 AgentScope 的个人 AI 助手工作站，支持多渠道聊天、本地大模型和定时任务 | [GitHub](https://github.com/agentscope-ai/CoPaw) | [Release][r-copaw] |
| <img src="apps/cowagent/fnos/ICON.PNG" width="28"> | **CowAgent** | `9899` | AI 超级助手，支持微信/飞书/钉钉/QQ/Web 等多平台接入，基于大语言模型的智能对话 | [GitHub](https://github.com/zhayujie/chatgpt-on-wechat) | [Release][r-cowagent] |
| <img src="apps/zeroclaw/fnos/ICON.PNG" width="28"> | **ZeroClaw** | `42617` | 轻量级 AI 智能体运行时，Rust 编写，<5MB 内存占用 | [GitHub](https://github.com/zeroclaw-labs/zeroclaw) | [Release][r-zeroclaw] |
| <img src="apps/picoclaw/fnos/ICON.PNG" width="28"> | **PicoClaw** | `18800` | 超轻量 AI 智能体框架，Go 编写，10MB 内存占用，WebUI 端口 18800（网关 18790） | [GitHub](https://github.com/sipeed/picoclaw) | [Release][r-picoclaw] |
| <img src="apps/nanobot/fnos/ICON.PNG" width="28"> | **Nanobot** | `18780` | 超轻量 AI 智能体，Web 管理面板，默认账号 `admin/nanobot` | [GitHub](https://github.com/HKUDS/nanobot) | [Release][r-nanobot] |
| <img src="apps/localai/fnos/ICON.PNG" width="28"> | **LocalAI** | `8185` | 本地 AI 推理，兼容 OpenAI API | [官网](https://localai.io) | [Release][r-localai] |
| <img src="apps/librechat/fnos/ICON.PNG" width="28"> | **LibreChat** | `3085` | AI 聊天界面，支持多模型 | [官网](https://librechat.ai) | [Release][r-librechat] |
| <img src="apps/open-webui/fnos/ICON.PNG" width="28"> | **Open WebUI** | `8080` | AI 聊天界面，支持多模型对话 | [GitHub](https://github.com/open-webui/open-webui) | [Release][r-openwebui] |
| <img src="apps/ollama/fnos/ICON.PNG" width="28"> | **Ollama** | `11434` | 本地大语言模型运行引擎 | [官网](https://ollama.com) | [Release][r-ollama] |
| <img src="apps/maxkb/fnos/ICON.PNG" width="28"> | **MaxKB** | `8083` | AI 知识库问答系统，支持 RAG 和多模型对接 | [GitHub](https://github.com/1Panel-dev/MaxKB) | [Release][r-maxkb] |
| <img src="apps/qwenpaw/fnos/ICON.PNG" width="28"> | **QwenPaw** | `8088` | AgentScope 团队出品的自托管个人 AI 助手，多通道接入、定时任务与本地模型 | [GitHub](https://github.com/agentscope-ai/QwenPaw) | [Release][r-qwenpaw] |
| <img src="apps/astrbot/fnos/ICON.PNG" width="28"> | **AstrBot** | `6185` | 多平台 LLM 聊天机器人框架，支持 Web 管理面板和插件扩展。 | [github.com](https://github.com/AstrBotDevs/AstrBot) | [Release][r-astrbot] |
| <img src="apps/next-ai-draw-io/fnos/ICON.PNG" width="28"> | **Next AI Draw.io** | `3007` | 基于大语言模型的 draw.io 图表生成与编辑工具 | [github.com](https://github.com/chadkunsman/next-ai-draw-io) | [Release][r-next-ai-draw-io] |

### 🎬 媒体服务

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/plex/fnos/ICON.PNG" width="28"> | **Plex** | `32400` | 媒体服务器，支持硬件转码 | [官网](https://www.plex.tv) | [Release][r-plex] |
| <img src="apps/emby/fnos/ICON.PNG" width="28"> | **Emby** | `8096` | 媒体管理与流式传输 | [官网](https://emby.media) | [Release][r-emby] |
| <img src="apps/emby-lts/fnos/ICON.PNG" width="28"> | **Emby-LTS** | `8096` | Emby 版本锁定版：固定 4.10.0.40，不随上游更新；与原版 Emby 数据隔离可并存安装，但端口相同不可同时运行 | [官网](https://emby.media) | [Release][r-emby-lts] |
| <img src="apps/jellyfin/fnos/ICON.PNG" width="28"> | **Jellyfin** | `8097` | 开源媒体系统，内置 FFmpeg | [官网](https://jellyfin.org) | [Release][r-jellyfin] |
| <img src="apps/navidrome/fnos/ICON.PNG" width="28"> | **Navidrome** | `4533` | 音乐流媒体服务器 | [官网](https://www.navidrome.org) | [Release][r-navidrome] |
| <img src="apps/koel/fnos/ICON.PNG" width="28"> | **Koel** | `8060` | 个人音乐流媒体，默认账号 `admin@koel.dev/KoelIsCool` | [GitHub](https://github.com/koel/koel) | [Release][r-koel] |
| <img src="apps/immich/fnos/ICON.PNG" width="28"> | **Immich** | `2283` | 自托管照片/视频备份，支持人脸识别 | [GitHub](https://github.com/immich-app/immich) | [Release][r-immich] |
| <img src="apps/kavita/fnos/ICON.PNG" width="28"> | **Kavita** | `5000` | 漫画/电子书阅读 | [GitHub](https://github.com/Kareadita/Kavita) | [Release][r-kavita] |
| <img src="apps/tinymediamanager/fnos/ICON.PNG" width="28"> | **tinyMediaManager** | `5800` | 影视元数据管理 | [官网](https://www.tinymediamanager.org) | [Release][r-tmm] |
| <img src="apps/metatube/fnos/ICON.PNG" width="28"> | **MetaTube** | `8091` | JAV 元数据刮削服务器，搭配 Emby/Jellyfin 使用，内置 20+ 数据源 | [GitHub](https://github.com/metatube-community/metatube-sdk-go) | [Release][r-metatube] |
| <img src="apps/photoprism/fnos/ICON.PNG" width="28"> | **PhotoPrism** | `2342` | AI 驱动的照片管理 | [官网](https://photoprism.app) | [Release][r-photoprism] |
| <img src="apps/jellyseerr/fnos/ICON.PNG" width="28"> | **Jellyseerr** | `5055` | Jellyfin/Plex 媒体请求管理 | [GitHub](https://github.com/Fallenbagel/jellyseerr) | [Release][r-jellyseerr] |
| <img src="apps/tautulli/fnos/ICON.PNG" width="28"> | **Tautulli** | `8181` | Plex 使用统计与监控 | [官网](https://tautulli.com) | [Release][r-tautulli] |
| <img src="apps/seerr/fnos/ICON.PNG" width="28"> | **Seerr** | `5055` | Overseerr 社区分支，媒体请求管理 | [GitHub](https://github.com/seerr-team/seerr) | [Release][r-seerr] |
| <img src="apps/ente/fnos/ICON.PNG" width="28"> | **Ente** | `8510` | 端到端加密照片备份 | [官网](https://ente.io) | [Release][r-ente] |
| <img src="apps/sunshine/fnos/ICON.PNG" width="28"> | **Sunshine** | `47990` | 游戏串流服务器，配合 Moonlight 使用 | [GitHub](https://github.com/LizardByte/Sunshine) | [Release][r-sunshine] |
| <img src="apps/frigate/fnos/ICON.PNG" width="28"> | **Frigate** | `8971` | AI 视频监控，支持实时物体检测 | [官网](https://frigate.video) | [Release][r-frigate] |
| <img src="apps/komga/fnos/ICON.PNG" width="28"> | **Komga** | `25600` | 漫画/电子书媒体服务器，支持 OPDS | [GitHub](https://github.com/gotson/komga) | [Release][r-komga] |
| <img src="apps/koodo-reader/fnos/ICON.PNG" width="28"> | **Koodo Reader** | `8930` | 现代电子书管理器与阅读器 | [GitHub](https://github.com/koodo-reader/koodo-reader) | [Release][r-koodo] |
| <img src="apps/jellystat/fnos/ICON.PNG" width="28"> | **Jellystat** | `3004` | Jellyfin 使用统计与分析 | [GitHub](https://github.com/CyferShepard/Jellystat) | [Release][r-jellystat] |
| <img src="apps/ombi/fnos/ICON.PNG" width="28"> | **Ombi** | `3579` | 媒体请求与用户管理 | [GitHub](https://github.com/Ombi-app/Ombi) | [Release][r-ombi] |
| <img src="apps/wizarr/fnos/ICON.PNG" width="28"> | **Wizarr** | `5690` | Plex/Jellyfin 用户邀请管理 | [GitHub](https://github.com/wizarrrr/wizarr) | [Release][r-wizarr] |
| <img src="apps/medusa/fnos/ICON.PNG" width="28"> | **Medusa** | `8081` | 电视剧自动下载管理 | [GitHub](https://github.com/pymedusa/Medusa) | [Release][r-medusa] |
| <img src="apps/bililive-go/fnos/ICON.PNG" width="28"> | **Bililive-go** | `8680` | 多平台直播录制工具，支持 Bilibili、斗鱼、虎牙等 | [GitHub](https://github.com/hr3lxphr6j/bililive-go) | [Release][r-bililive-go] |
| <img src="apps/handbrake/fnos/ICON.PNG" width="28"> | **HandBrake** | `5800` | 开源视频转码工具，支持 GPU 硬件加速 | [GitHub](https://github.com/jlesage/docker-handbrake) | [Release][r-handbrake] |
| <img src="apps/suwayomi/fnos/ICON.PNG" width="28"> | **Suwayomi** | `4567` | 免费开源漫画阅读服务器，支持多来源扩展 | [GitHub](https://github.com/Suwayomi/Suwayomi-Server) | [Release][r-suwayomi] |
| <img src="apps/lyranest/fnos/ICON.PNG" width="28"> | **LyraNest** | `8080` | 律巢音乐：自托管多端音乐服务，共享曲库/歌单/播放队列，支持歌词偏移与离线下载 | [GitHub](https://github.com/WHWgogogo/LyraNest) | [Release][r-lyranest] |
| <img src="apps/miair-next/fnos/ICON.PNG" width="28"> | **MiAir Next** | `8300` | 将小米小爱音箱转换为 DLNA 渲染器与 AirPlay 接收器，含 Web 管理后台 | [GitHub](https://github.com/deerwan/miair-next) | [Release][r-miair-next] |
| <img src="https://raw.githubusercontent.com/Helenvin/LitePan-fpk/main/LitePan-x86/ICON.PNG" width="28"> | **LitePan（原生）** | `5211` | LitePan 原生版（Go 单二进制，无需 Docker）：网盘聚合挂载、STRM 刮削、目录整理，默认端口 5211。由 Helenvin/LitePan-fpk 自动同步。 | [github.com](https://github.com/Helenvin/LitePan-fpk) | [Release][r-LitePan] |
| <img src="apps/avdb/fnos/ICON.PNG" width="28"> | **AVdb 影音自动化** | `8000` | AVdb 影音自动化：串接 MDC-NG 刮削信息自动归档、维护映射表，并通过 docker.sock 联动重启 MDC。基于 leolitaly/avdb 多架构镜像的 Docker 打包，安装向导默认接管既有手动部署的数据库与规则数据。 | [github.com](https://github.com/Helenvin/AVdb-Only) | [Release][r-avdb] |
| <img src="apps/mdc/fnos/ICON.PNG" width="28"> | **MDC 影音整理** | `9208` | MDC-NG 影音刮削整理：30+ 刮削源、AI 人脸识别海报、目录监控、演员管理、Emby 联动。基于 mdcng/mdc 多架构镜像的 Docker 打包，安装向导默认接管既有手动部署的配置与媒体库路径。 | [github.com](https://github.com/Helenvin/mdc-ng) | [Release][r-mdc] |
| <img src="apps/melody-hub/fnos/ICON.PNG" width="28"> | **MelodyHub** | `3006` | Web 音乐搜索与下载服务，基于 lx-music 核心，支持多平台音源聚合搜索、服务器端下载和歌曲管理。 | [github.com](https://github.com/gefl24/melody-hub) | [Release][r-melody-hub] |
| <img src="apps/songloft/fnos/ICON.PNG" width="28"> | **Songloft** | `58091` | 自托管音乐服务器，支持本地音乐管理与 Web 播放 | [github.com](https://github.com/songloft-org/songloft) | [Release][r-songloft] |
| <img src="apps/sqmusic/fnos/ICON.PNG" width="28"> | **SQMusic 音乐下载站** | `8097` | 多源音乐下载站（simple_sq_music_plus Docker 打包）：kw/qq/qqvip/mg/netease/kg/tidal 七源搜索，歌单/专辑/单曲解析下载；网易云与 QQ 音乐歌单监听自动增量下载（QQ 公开歌单匿名添加，歌曲下载需 QQ 扫码登录），标签歌词，文件按歌手/专辑落盘适配 Emby/Jellyfin。 | [github.com](https://github.com/Helenvin/simple_sq_music_plus) | [Release][r-sqmusic] |
| <img src="apps/suggestarr/fnos/ICON.PNG" width="28"> | **SuggestArr** | `5007` | 基于观影记录自动向 Seerr/Jellyseerr 请求相似影视内容 | [github.com](https://github.com/giuseppe99barchetta/SuggestArr) | [Release][r-suggestarr] |
| <img src="apps/vibenvr/fnos/ICON.PNG" width="28"> | **VibeNVR** | `8087` | AI 网络视频录像机，支持摄像头管理、录像与硬件加速转码。 | [github.com](https://github.com/spupuz/VibeNVR) | [Release][r-vibenvr] |

### ⬇️ 下载工具

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/qbittorrent/fnos/ICON.PNG" width="28"> | **qBittorrent** | `8085` | BitTorrent 客户端，默认账号 `admin/adminadmin` | [官网](https://www.qbittorrent.org) | [Release][r-qb] |
| <img src="apps/transmission/fnos/ICON.PNG" width="28"> | **Transmission** | `9091` | 轻量级 BitTorrent 客户端 | [官网](https://transmissionbt.com) | [Release][r-transmission] |
| <img src="apps/aria2-next/fnos/ICON.PNG" width="28"> | **Aria2 Next** | `6800` | 活跃维护的 aria2 分支下载引擎（RPC，无内置网页，配 AriaNg 使用） | [GitHub](https://github.com/AnInsomniacy/aria2-next) | [Release][r-aria2-next] |
| <img src="apps/gopeed/fnos/ICON.PNG" width="28"> | **Gopeed** | `9999` | 高速下载器，支持 HTTP/BT/Magnet | [官网](https://gopeed.com) | [Release][r-gopeed] |
| <img src="apps/metube/fnos/ICON.PNG" width="28"> | **MeTube** | `8281` | 网页版 yt-dlp：粘链接即下，支持上千站点 | [GitHub](https://github.com/alexta69/metube) | [Release][r-metube] |
| <img src="apps/syncthing/fnos/ICON.PNG" width="28"> | **Syncthing** | `8384` | 文件同步工具，P2P 架构 | [官网](https://syncthing.net) | [Release][r-syncthing] |
| <img src="apps/alist/fnos/ICON.PNG" width="28"> | **Alist** | `5246` | 网盘聚合工具，挂载阿里云盘/百度盘等 | [GitHub](https://github.com/AlistGo/alist) | [Release][r-alist] |
| <img src="apps/rclone/fnos/ICON.PNG" width="28"> | **Rclone** | `5572` | 云存储同步工具，支持 50+ 存储后端 | [官网](https://rclone.org) | [Release][r-rclone] |
| <img src="apps/cloudreve/fnos/ICON.PNG" width="28"> | **Cloudreve** | `5212` | 国产云盘系统 | [官网](https://cloudreve.org) | [Release][r-cloudreve] |
| <img src="apps/sabnzbd/fnos/ICON.PNG" width="28"> | **SABnzbd** | `8780` | Usenet 下载客户端 | [官网](https://sabnzbd.org) | [Release][r-sabnzbd] |
| <img src="apps/copyparty/fnos/ICON.PNG" width="28"> | **CopyParty** | `3923` | 便携文件共享服务器 | [GitHub](https://github.com/9001/copyparty) | [Release][r-copyparty] |
| <img src="apps/verysync/fnos/ICON.PNG" width="28"> | **Verysync** | `8666` | 微力同步文件同步工具 | [www.verysync.com](https://www.verysync.com/) | [Release][r-verysync] |

### 📚 内容管理

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/siyuan/fnos/ICON.PNG" width="28"> | **SiYuan 思源笔记** | `6806` | 块级编辑与双向链接知识库，内核服务器模式，网页端访问 | [官网](https://b3log.org/siyuan) | [Release][r-siyuan] |
| <img src="apps/vikunja/fnos/ICON.PNG" width="28"> | **Vikunja** | `3456` | 待办清单与看板（列表/甘特/日历），配手机 App | [官网](https://vikunja.io) | [Release][r-vikunja] |
| <img src="apps/ani-rss/fnos/ICON.PNG" width="28"> | **ANI-RSS** | `7789` | 动漫 RSS 自动追番，默认账号 `admin/admin` | [GitHub](https://github.com/wushuo894/ani-rss) | [Release][r-ani] |
| <img src="apps/danmu-api/fnos/ICON.PNG" width="28"> | **Danmu API** | `9321` | 弹幕 API 服务器，兼容弹弹play 接口规范 | [GitHub](https://github.com/huangxd-/danmu_api) | [Release][r-danmu-api] |
| <img src="apps/auto-bangumi/fnos/ICON.PNG" width="28"> | **AutoBangumi** | `7892` | RSS 自动追番下载整理，默认账号 `admin/adminadmin` | [GitHub](https://github.com/EstrellaXD/Auto_Bangumi) | [Release][r-ab] |
| <img src="apps/audiobookshelf/fnos/ICON.PNG" width="28"> | **Audiobookshelf** | `13378` | 有声书和播客服务器 | [官网](https://www.audiobookshelf.org) | [Release][r-abs] |
| <img src="apps/openlist/fnos/ICON.PNG" width="28"> | **OpenList** | `5244` | 文件列表/WebDAV | [GitHub](https://github.com/OpenListTeam/OpenList) | [Release][r-openlist] |
| <img src="apps/kodbox/fnos/ICON.PNG" width="28"> | **KodBox** | `8500` | 私有云存储/在线文档协作 | [官网](https://kodcloud.com) | [Release][r-kodbox] |
| <img src="apps/chinesesubfinder/fnos/ICON.PNG" width="28"> | **ChineseSubFinder** | `19035` | 中文字幕自动下载 | [GitHub](https://github.com/ChineseSubFinder/ChineseSubFinder) | [Release][r-csf] |
| <img src="apps/freshrss/fnos/ICON.PNG" width="28"> | **FreshRSS** | `8082` | 自托管 RSS 阅读器 | [官网](https://freshrss.org) | [Release][r-freshrss] |
| <img src="apps/miniflux/fnos/ICON.PNG" width="28"> | **Miniflux** | `8084` | 极简 RSS 阅读器 | [官网](https://miniflux.app) | [Release][r-miniflux] |
| <img src="apps/linkwarden/fnos/ICON.PNG" width="28"> | **Linkwarden** | `3005` | 协作式书签管理 | [官网](https://linkwarden.app) | [Release][r-linkwarden] |
| <img src="apps/wikijs/fnos/ICON.PNG" width="28"> | **Wiki.js** | `3110` | 现代化 Wiki 引擎 | [官网](https://js.wiki) | [Release][r-wikijs] |
| <img src="apps/mealie/fnos/ICON.PNG" width="28"> | **Mealie** | `9925` | 食谱管理与膳食计划 | [官网](https://mealie.io) | [Release][r-mealie] |
| <img src="apps/paperless-ngx/fnos/ICON.PNG" width="28"> | **Paperless-ngx** | `8000` | 文档数字化管理，OCR 支持 | [官网](https://docs.paperless-ngx.com) | [Release][r-paperless] |
| <img src="apps/appflowy/fnos/ICON.PNG" width="28"> | **AppFlowy** | `8501` | Notion 开源替代品，协作文档平台 | [官网](https://appflowy.io) | [Release][r-appflowy] |
| <img src="apps/reactive-resume/fnos/ICON.PNG" width="28"> | **Reactive Resume** | `3200` | 在线简历制作工具 | [GitHub](https://github.com/AmruthPillworking/Reactive-Resume) | [Release][r-reactive-resume] |
| <img src="apps/lanraragi/fnos/ICON.PNG" width="28"> | **LANraragi** | `3000` | 自托管漫画/存档管理服务器，自动元数据刮削 | [GitHub](https://github.com/Difegue/LANraragi) | [Release][r-lanraragi] |
| <img src="apps/docsify/fnos/ICON.PNG" width="28"> | **Docsify** | `4001` | 轻量级 Markdown 文档站点服务 | [github.com](https://github.com/docsifyjs/docsify) | [Release][r-docsify] |
| <img src="apps/feigram/fnos/ICON.PNG" width="28"> | **Feigram** | `3088` | 非官方 Telegram Web 客户端，支持多账号、聊天、媒体预览和下载缓存 | [github.com](https://github.com/g-star1024/Feigram-Public) | [Release][r-feigram] |
| <img src="apps/fileview/fnos/ICON.PNG" width="28"> | **Fileview** | `9000` | 新一代通用型在线文件预览引擎，支持 Office、PDF、OFD、CAD、图片、代码文件等格式。 | [github.com](https://github.com/basemetas/fileview) | [Release][r-fileview] |
| <img src="apps/mail-archiver/fnos/ICON.PNG" width="28"> | **Mail Archiver** | `5008` | IMAP/Microsoft 365 邮件归档、搜索与导出系统 | [github.com](https://github.com/s1t5/mail-archiver) | [Release][r-mail-archiver] |
| <img src="apps/memos/fnos/ICON.PNG" width="28"> | **Memos** | `5230` | 轻量级自托管笔记服务,支持Markdown,适合个人知识管理和日常记录。 | [www.usememos.com](https://www.usememos.com) | [Release][r-memos] |
| <img src="apps/nextcloud/fnos/ICON.PNG" width="28"> | **Nextcloud** | `8082` | 开源私有云存储平台,支持文件同步、在线文档协作和日历联系人管理。 | [nextcloud.com](https://nextcloud.com) | [Release][r-nextcloud] |
| <img src="apps/obsidian/fnos/ICON.PNG" width="28"> | **Obsidian** | `8080` | 基于 Docker 的 Obsidian 个人知识库 | [obsidian.md](https://obsidian.md) | [Release][r-obsidian] |
| <img src="apps/puter/fnos/ICON.PNG" width="28"> | **Puter** | `4100` | 开源云桌面环境,在浏览器中提供完整的桌面体验,支持文件管理和应用生态。 | [puter.com](https://puter.com) | [Release][r-puter] |
| <img src="apps/seafile/fnos/ICON.PNG" width="28"> | **Seafile** | `8002` | 开源文件同步与共享平台 | [github.com](https://github.com/haiwen/seafile-docker) | [Release][r-seafile] |

### 🎵 媒体自动化

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/moviepilot/fnos/ICON.PNG" width="28"> | **MoviePilot** | `3300` | 影视自动化管理：订阅、下载、整理入库，原生运行无需 Docker（装完首次启动要展开载荷，需几分钟） | [GitHub](https://github.com/jxxghp/MoviePilot) | [Release][r-mp] |
| <img src="apps/sonarr/fnos/ICON.PNG" width="28"> | **Sonarr** | `8989` | 电视剧自动下载管理 | [官网](https://sonarr.tv) | [Release][r-sonarr] |
| <img src="apps/radarr/fnos/ICON.PNG" width="28"> | **Radarr** | `7878` | 电影自动下载管理 | [官网](https://radarr.video) | [Release][r-radarr] |
| <img src="apps/lidarr/fnos/ICON.PNG" width="28"> | **Lidarr** | `8686` | 音乐自动下载管理 | [官网](https://lidarr.audio) | [Release][r-lidarr] |
| <img src="apps/readarr/fnos/ICON.PNG" width="28"> | **Readarr** | `8787` | 电子书自动下载管理 | [官网](https://readarr.com) | [Release][r-readarr] |
| <img src="apps/prowlarr/fnos/ICON.PNG" width="28"> | **Prowlarr** | `9696` | 索引器管理，整合 Sonarr/Radarr 等 | [官网](https://prowlarr.com) | [Release][r-prowlarr] |
| <img src="apps/bazarr/fnos/ICON.PNG" width="28"> | **Bazarr** | `6767` | 字幕自动下载管理 | [官网](https://www.bazarr.media) | [Release][r-bazarr] |
| <img src="apps/jackett/fnos/ICON.PNG" width="28"> | **Jackett** | `9117` | Torrent 索引器代理，Prowlarr 替代 | [GitHub](https://github.com/Jackett/Jackett) | [Release][r-jackett] |
| <img src="apps/zonefoundry-bridge/fnos/ICON.PNG" width="28"> | **ZoneFoundry Bridge** | `18790` | ZoneFoundry 自建桥接，连接家中 Sonos 与 ZoneFoundry 云端中继，远程通过语音 / IM / 网页操控 Sonos 音箱。 | [zonefoundry.dev](https://zonefoundry.dev) | [Release][r-zonefoundry-bridge] |

### 🔧 系统工具

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/sun-panel/fnos/ICON.PNG" width="28"> | **Sun-Panel** | `3002` | 服务器/NAS 导航面板 | [官网](https://doc.sun-panel.top/zh_cn) | [Release][r-sunpanel] |
| <img src="apps/homepage/fnos/ICON.PNG" width="28"> | **Homepage** | `3003` | 高度可定制的应用仪表盘 | [官网](https://gethomepage.dev) | [Release][r-homepage] |
| <img src="apps/homarr/fnos/ICON.PNG" width="28"> | **Homarr** | `7575` | 服务器仪表盘与应用管理 | [官网](https://homarr.dev) | [Release][r-homarr] |
| <img src="apps/glance/fnos/ICON.PNG" width="28"> | **Glance** | `9678` | 高颜值聚合仪表盘：RSS/书签/监控/市场几十种小组件 | [GitHub](https://github.com/glanceapp/glance) | [Release][r-glance] |
| <img src="apps/certimate/fnos/ICON.PNG" width="28"> | **Certimate** | `8090` | SSL 证书管理 | [GitHub](https://github.com/certimate-go/certimate) | [Release][r-certimate] |
| <img src="apps/vaultwarden/fnos/ICON.PNG" width="28"> | **Vaultwarden** | `8880` | 密码管理（Bitwarden 兼容） | [GitHub](https://github.com/dani-garcia/vaultwarden) | [Release][r-vw] |
| <img src="apps/nginx/fnos/ICON.PNG" width="28"> | **Nginx** | `8888` | HTTP 服务与反向代理 | [官网](https://nginx.org) | [Release][r-nginx] |
| <img src="apps/nginx-ui/fnos/ICON.PNG" width="28"> | **Nginx UI** | `9000` | Nginx 可视化管理面板，内置 Nginx 引擎 | [GitHub](https://github.com/0xJacky/nginx-ui) | [Release][r-nginx-ui] |
| <img src="apps/gotify/fnos/ICON.PNG" width="28"> | **Gotify** | `8070` | 自托管推送通知服务 | [官网](https://gotify.net) | [Release][r-gotify] |
| <img src="apps/pocket-id/fnos/ICON.PNG" width="28"> | **Pocket ID** | `1411` | 轻量 OIDC/Passkey 单点登录，为自托管应用统一免密登录 | [GitHub](https://github.com/pocket-id/pocket-id) | [Release][r-pocket-id] |
| <img src="apps/ddns-go/fnos/ICON.PNG" width="28"> | **DDNS-GO** | `9876` | 动态 DNS 解析客户端 | [GitHub](https://github.com/jeessy2/ddns-go) | [Release][r-ddnsgo] |
| <img src="apps/wolgoweb/fnos/ICON.PNG" width="28"> | **WolGoWeb** | `9095` | 网络唤醒 (Wake-on-LAN) 管理 | [GitHub](https://github.com/xiaoxinpro/WolGoWeb) | [Release][r-wolgoweb] |
| <img src="apps/adguardhome/fnos/ICON.PNG" width="28"> | **AdGuardHome** | `3080` | 全网广告拦截与 DNS 管理 | [官网](https://adguard.com/adguard-home/overview.html) | [Release][r-adguardhome] |
| <img src="apps/uptime-kuma/fnos/ICON.PNG" width="28"> | **Uptime Kuma** | `3001` | 自托管服务监控 | [GitHub](https://github.com/louislam/uptime-kuma) | [Release][r-uptimekuma] |
| <img src="apps/beszel/fnos/ICON.PNG" width="28"> | **Beszel** | `18090` | 轻量级服务器监控 | [GitHub](https://github.com/henrygd/beszel) | [Release][r-beszel] |
| <img src="apps/filebrowser/fnos/ICON.PNG" width="28"> | **FileBrowser** | `8089` | Web 文件管理器 | [官网](https://filebrowser.org) | [Release][r-filebrowser] |
| <img src="apps/stirling-pdf/fnos/ICON.PNG" width="28"> | **Stirling-PDF** | `18080` | 自托管 PDF 工具箱 | [官网](https://stirlingpdf.io) | [Release][r-stirlingpdf] |
| <img src="apps/actual-budget/fnos/ICON.PNG" width="28"> | **Actual Budget** | `5006` | 自托管个人财务管理 | [官网](https://actualbudget.org) | [Release][r-actual] |
| <img src="apps/homebox/fnos/ICON.PNG" width="28"> | **Homebox** | `7745` | 家庭物品资产管理与库存：位置/标签/保修归档 | [GitHub](https://github.com/sysadminsmedia/homebox) | [Release][r-homebox] |
| <img src="apps/lucky/fnos/ICON.PNG" width="28"> | **Lucky** | `16601` | DDNS/反向代理/端口转发多功能工具 | [官网](https://lucky666.cn) | [Release][r-lucky] |
| <img src="apps/frps/fnos/ICON.PNG" width="28"> | **FRP Server** | `7000` | 高性能内网穿透服务端 frps，Web 面板 7500 | [GitHub](https://github.com/fatedier/frp) | [Release][r-frps] |
| <img src="apps/rustdesk-server/fnos/ICON.PNG" width="28"> | **RustDesk Server** | `21116` | 远程桌面自建服务端（hbbs+hbbr），流量不经第三方 | [官网](https://rustdesk.com) | [Release][r-rustdesk-server] |
| <img src="apps/1panel/fnos/ICON.PNG" width="28"> | **1Panel** | `10086` | 开源服务器管理面板 | [官网](https://1panel.cn) | [Release][r-1panel] |
| <img src="apps/grafana/fnos/ICON.PNG" width="28"> | **Grafana** | `3010` | 可视化监控仪表盘 | [官网](https://grafana.com) | [Release][r-grafana] |
| <img src="apps/prometheus/fnos/ICON.PNG" width="28"> | **Prometheus** | `9090` | 时序数据库与监控系统 | [官网](https://prometheus.io) | [Release][r-prometheus] |
| <img src="apps/loki/fnos/ICON.PNG" width="28"> | **Loki** | `3100` | 日志聚合系统，Grafana 生态 | [GitHub](https://github.com/grafana/loki) | [Release][r-loki] |
| <img src="apps/glances/fnos/ICON.PNG" width="28"> | **Glances** | `61208` | 系统监控，Web UI 版 htop | [GitHub](https://github.com/nicolargo/glances) | [Release][r-glances] |
| <img src="apps/n8n/fnos/ICON.PNG" width="28"> | **n8n** | `5678` | 工作流自动化工具 | [官网](https://n8n.io) | [Release][r-n8n] |
| <img src="apps/ntfy/fnos/ICON.PNG" width="28"> | **Ntfy** | `2586` | 自托管推送通知服务 | [官网](https://ntfy.sh) | [Release][r-ntfy] |
| <img src="apps/gitea/fnos/ICON.PNG" width="28"> | **Gitea** | `3033` | 轻量级 Git 代码托管 | [官网](https://gitea.com) | [Release][r-gitea] |
| <img src="apps/duplicati/fnos/ICON.PNG" width="28"> | **Duplicati** | `8200` | 加密备份工具 | [官网](https://duplicati.com) | [Release][r-duplicati] |
| <img src="apps/it-tools/fnos/ICON.PNG" width="28"> | **IT-Tools** | `8280` | 开发者工具箱 | [官网](https://it-tools.tech) | [Release][r-it-tools] |
| <img src="apps/mattermost/fnos/ICON.PNG" width="28"> | **Mattermost** | `8065` | 企业即时通讯，Slack 替代 | [官网](https://mattermost.com) | [Release][r-mattermost] |
| <img src="apps/homeassistant/fnos/ICON.PNG" width="28"> | **Home Assistant** | `8123` | 智能家居中枢平台 | [官网](https://www.home-assistant.io) | [Release][r-homeassistant] |
| <img src="apps/nginx-proxy-manager/fnos/ICON.PNG" width="28"> | **Nginx Proxy Manager** | `81` | 反向代理可视化管理 | [GitHub](https://github.com/NginxProxyManager/nginx-proxy-manager) | [Release][r-npm] |
| <img src="apps/dpanel/fnos/ICON.PNG" width="28"> | **DPanel** | `8807` | 轻量级 Docker 管理面板 | [GitHub](https://github.com/donknap/dpanel) | [Release][r-dpanel] |
| <img src="apps/netdata/fnos/ICON.PNG" width="28"> | **Netdata** | `19999` | 实时系统性能监控 | [官网](https://www.netdata.cloud) | [Release][r-netdata] |
| <img src="apps/node-red/fnos/ICON.PNG" width="28"> | **Node-RED** | `1880` | 可视化流程自动化工具 | [官网](https://nodered.org) | [Release][r-nodered] |
| <img src="apps/forgejo/fnos/ICON.PNG" width="28"> | **Forgejo** | `3005` | 社区驱动的 Git 代码托管 | [官网](https://forgejo.org) | [Release][r-forgejo] |
| <img src="apps/clamav/fnos/ICON.PNG" width="28"> | **ClamAV** | `3310` | 开源杀毒引擎 | [官网](https://www.clamav.net) | [Release][r-clamav] |
| <img src="apps/ezbookkeeping/fnos/ICON.PNG" width="28"> | **EZBookkeeping** | `8580` | 轻量级个人记账应用，支持多币种、多账户和预算管理 | [GitHub](https://github.com/mayswind/ezbookkeeping) | [Release][r-ezbookkeeping] |
| <img src="apps/penpot/fnos/ICON.PNG" width="28"> | **Penpot** | `9001` | 开源设计和原型工具，Figma 的自托管替代方案 | [官网](https://penpot.app) | [Release][r-penpot] |
| <img src="apps/surveyking/fnos/ICON.PNG" width="28"> | **SurveyKing** | `1991` | 开源问卷调查和在线考试系统，支持多种题型、逻辑跳转和数据导出 | [官网](https://github.com/anji-plus/survey) | [Release][r-surveyking] |
| <img src="apps/nvidia-driver/fnos/ICON.PNG" width="28"> | **NVIDIA Driver** | — | NVIDIA GPU 驱动（R580 LTS）+ nvidia-container-toolkit，仅 x86 | [官网](https://www.nvidia.com/drivers) | [Release][r-nvidia-driver] |
| <img src="apps/arcane/fnos/ICON.PNG" width="28"> | **Arcane** | `3552` | 现代化 Docker 管理界面，可视化管理容器、镜像、Compose 项目与存储卷 | [GitHub](https://github.com/getarcaneapp/arcane) | [Release][r-arcane] |
| <img src="apps/surface-battery/fnos/ICON.PNG" width="28"> | **Surface 电池驱动** | — | Microsoft Surface 电池驱动（Surface Aggregator），应用内按需编译安装，仅 x86 | [GitHub](https://github.com/xiowo/fnos_surface_battery_driver) | [Release][r-surface-battery] |
| <img src="apps/calibre-web/fnos/ICON.PNG" width="28"> | **Calibre-Web** | `8083` | Calibre 电子书库 Web 管理与在线阅读 | [github.com](https://github.com/janeczku/calibre-web) | [Release][r-calibre-web] |
| <img src="apps/clouddrive2/fnos/ICON.PNG" width="28"> | **CloudDrive2** | `19798` | 多网盘挂载与管理工具 | [www.clouddrive2.com](https://www.clouddrive2.com/) | [Release][r-clouddrive2] |
| <img src="apps/coolercontrol/fnos/ICON.PNG" width="28"> | **CoolerControl** | `11987` | Linux 风扇与散热设备监控控制面板 | [github.com](https://github.com/codifryed/coolercontrol) | [Release][r-coolercontrol] |
| <img src="apps/daidai-panel/fnos/ICON.PNG" width="28"> | **Daidai Panel** | `5701` | 轻量现代的定时任务与脚本管理面板 | [github.com](https://github.com/linzixuanzz/daidai-panel) | [Release][r-daidai-panel] |
| <img src="apps/fnclearup/fnos/ICON.PNG" width="28"> | **清理精灵（原生）** | — | 智能扫描已卸载应用、网盘挂载与 Docker 残留目录及重复文件，一键安全清理（Node.js 原生版，root 运行，经 fnOS 桌面打开）。安装前需先在应用中心安装 nodejs_v24 运行时；每日自动同步 FnDepot。 | [github.com](https://github.com/Wyf841015/FnDepot) | [Release][r-fnclearup] |
| <img src="apps/komari/fnos/ICON.PNG" width="28"> | **Komari** | `25774` | 轻量级自托管服务器监控工具，通过 Web 界面查看服务器状态，配合轻量 agent 采集数据。 | [github.com](https://github.com/komari-monitor/komari) | [Release][r-komari] |
| <img src="apps/qinglong/fnos/ICON.PNG" width="28"> | **QingLong** | `5700` | 支持 Python/JavaScript/Shell/TypeScript 的定时任务管理面板 | [github.com](https://github.com/whyour/qinglong) | [Release][r-qinglong] |
| <img src="apps/rocketchat/fnos/ICON.PNG" width="28"> | **Rocket.Chat** | `3003` | 开源团队协作通讯平台,支持即时消息、音视频通话和文件共享。 | [rocket.chat](https://rocket.chat) | [Release][r-rocketchat] |
| <img src="apps/sub-store/fnos/ICON.PNG" width="28"> | **Sub-Store** | `3001` | 订阅链接管理工具，支持 QX、Loon、Surge、Stash、Egern 和 Shadowrocket 等多种代理客户端的订阅聚合与转换。 | [github.com](https://github.com/sub-store-org/Sub-Store) | [Release][r-sub-store] |
| <img src="apps/visor/fnos/ICON.PNG" width="28"> | **Visor** | `1081` | 现代化堡垒机 + 自动化运维平台，支持 SSH/RDP/VNC 在线终端、文件管理、批量操作、计划任务、主机监控。 | [github.com](https://github.com/dromara/orion-visor) | [Release][r-visor] |

### 🌐 网络工具

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/aellus/fnos/ICON.PNG" width="28"> | **Aellus** | `8000` | 局域网文件互传：浏览器访问即传即取，按设备归档、免配置 | [GitHub](https://github.com/YGQ8988/Aellus) | [Release][r-aellus] |
| <img src="apps/smartdns/fnos/ICON.PNG" width="28"> | **SmartDNS** | `6580` | 本地 DNS 加速与优选 | [GitHub](https://github.com/pymumu/smartdns) | [Release][r-smartdns] |
| <img src="apps/mosdns/fnos/ICON.PNG" width="28"> | **MosDNS** | `5354` | DNS 转发与分流 | [GitHub](https://github.com/IrineSistiana/mosdns) | [Release][r-mosdns] |
| <img src="apps/pihole/fnos/ICON.PNG" width="28"> | **Pi-hole** | `8053` | 全网广告拦截 (DNS) | [官网](https://pi-hole.net) | [Release][r-pihole] |
| <img src="apps/wg-easy/fnos/ICON.PNG" width="28"> | **WG-Easy** | `51821` | WireGuard VPN 管理界面 | [GitHub](https://github.com/wg-easy/wg-easy) | [Release][r-wg-easy] |
| <img src="apps/headscale/fnos/ICON.PNG" width="28"> | **Headscale** | `8480` | Tailscale 自托管控制服务器 | [GitHub](https://github.com/juanfont/headscale) | [Release][r-headscale] |
| <img src="apps/netbird/fnos/ICON.PNG" width="28"> | **NetBird** | `8820` | Zero Trust VPN 平台 | [官网](https://netbird.io) | [Release][r-netbird] |
| <img src="apps/tailscale/fnos/ICON.PNG" width="28"> | **Tailscale** | `8088` | Mesh VPN 客户端 | [官网](https://tailscale.com) | [Release][r-tailscale] |
| <img src="apps/cloudflared/fnos/ICON.PNG" width="28"> | **Cloudflare Tunnel** | `14333` | Cloudflare 内网穿透隧道，通过 Web 界面管理 Tunnel Token 配置 | [GitHub](https://github.com/WisdomSky/Cloudflared-web) | [Release][r-cloudflared] |
| <img src="apps/easytier/fnos/ICON.PNG" width="28"> | **EasyTier** | `11210` | 简单安全的去中心化异地组网方案，支持 Web 管理和子网代理 | [GitHub](https://github.com/EasyTier/EasyTier) | [Release][r-easytier] |
| <img src="apps/mihomo/fnos/ICON.PNG" width="28"> | **Mihomo** | `9097` | Clash.Meta 内核 + MetaCubeXD dashboard，含开箱即用配置模板、TUN 模式与 LAN 混合代理 | [GitHub](https://github.com/MetaCubeX/mihomo) | [Release][r-mihomo] |
| <img src="apps/opensurge/fnos/ICON.PNG" width="28"> | **OpenSurge** | `61767` | 旁路由透明代理网关（mihomo + dnsmasq + nftables），TUN 模式与按设备分流（另用 7890/53） | [GitHub](https://github.com/funchs/opensurge-fnos) | [Release][r-opensurge] |
| <img src="apps/msf/fnos/ICON.PNG" width="28"> | **MSF** | `7777` | MosDNS + Mihomo DNS 分流与透明代理管理面板 | [github.com](https://github.com/scoltzero/msf) | [Release][r-msf] |
| <img src="apps/sakurafrp/fnos/ICON.PNG" width="28"> | **SakuraFrp** | `7102` | 樱花内网穿透客户端，免费端口映射服务。 | [www.natfrp.com](https://www.natfrp.com) | [Release][r-sakurafrp] |
| <img src="apps/zerotier/fnos/ICON.PNG" width="28"> | **ZeroTier** | `3008` | ZeroTier 自托管控制器与 ZTNET Web 管理界面，支持可视化管理虚拟局域网。 | [github.com](https://github.com/sinamics/ztnet) | [Release][r-zerotier] |
| <img src="native-assets/fn-knock/ICON_256.PNG" width="28"> | **敲门 Knock（标准版）** | — | 零信任安全网关：把相册、下载器与自建应用收敛到同一个入口，访客先登录再访问，默认拒绝未授权连接。内置反向代理、TOTP/Passkey 认证、ACME 证书、DDNS、IP 白名单、WAF、内网穿透与运维监控。网关端口 `7999`，以 root 运行、经 fnOS 桌面图标打开管理面板（商店另有非 root 精简版 knock Lite，公网暴露场景建议用本版本）。镜像自 kci-lnk/fn-knock-turborepo，随上游每日自动同步 | [官网](https://www.fnknock.cn/) | [Release][r-fn-knock] |

### 🌐 浏览器

| | App | 端口 | 说明 | 来源 | 下载 |
|:---:|---|---:|---|:---:|:---:|
| <img src="apps/firefox/fnos/ICON.PNG" width="28"> | **Firefox** | `5801` | 远程浏览器，支持中文 | [GitHub](https://github.com/jlesage/docker-firefox) | [Release][r-firefox] |
| <img src="apps/chromium/fnos/ICON.PNG" width="28"> | **Chromium** | `5802` | 远程浏览器，支持中文 | [GitHub](https://github.com/jlesage/docker-chromium) | [Release][r-chromium] |

## 反馈与请求

- 新应用请求：[Open App Request](https://github.com/conversun/fnos-apps/issues/new?template=new-app-request.yml)
- 问题反馈：[Open Bug Report](https://github.com/conversun/fnos-apps/issues/new?template=bug-report.yml)

## 快速开始

### 安装

1. 下载对应 App 的 [Release](https://github.com/conversun/fnos-apps/releases) 页面中的 `.fpk` 文件
2. 在 fnOS 应用中心选择「手动安装」
3. 上传 `.fpk` 并完成安装

### 本地构建

```bash
# 构建单个应用（以 plex 为例）
cd apps/plex && ./update_plex.sh

# 通用格式
cd apps/<app> && ./update_<app>.sh
```

构建产物统一输出到仓库根目录 `dist/`。

## 项目结构

```text
fnos-apps/
├── apps/                    # 各应用的 fnOS 包定义与构建脚本
├── shared/                  # 通用生命周期脚本与向导模板
├── scripts/
│   ├── build-fpk.sh         # 通用 fpk 打包器
│   ├── new-app.sh           # 新应用脚手架
│   ├── apps/<app>/          # 每个应用的构建合约
│   └── ci/resolve-release-tag.sh
└── .github/workflows/       # 入口 workflow + 可复用构建 workflow
```

## 新增应用（维护者）

```bash
./scripts/new-app.sh <app-slug> "<display-name>" <port>
# example
./scripts/new-app.sh jellyfin "Jellyfin" 8097
```

推荐流程：

1. 在 `apps/<app>/` 完成 fnOS 清单和启动脚本
2. 在 `scripts/apps/<app>/` 完成版本探测与 `app.tgz` 组装
3. CI 自动发现新应用，无需手动创建 workflow 文件

## CI/CD 设计

- 单一入口 `build-apps.yml` 自动发现 `apps/` 下所有应用，动态矩阵构建
- 统一使用 `scripts/build-fpk.sh` 打包，减少各应用行为漂移
- 统一使用 `reusable-build-app.yml` 实现版本检查、矩阵构建、发布
- 标签策略由 `scripts/ci/resolve-release-tag.sh` 管理，支持 `-r2/-r3` 修订版自动递增
- 日常构建由定时任务和手动触发驱动，push 触发仅构建变更的应用
- 现成的第三方原生 fpk 由 `mirror-rrog-native.yml`、`mirror-thirdparty-native.yml` 每日跟踪上游发布，自动镜像为商店命名规范并刷新 `apps.json`

## 变更记录

项目变更记录请查看 [CHANGELOG.md](CHANGELOG.md)。

## 致谢

- 应用图标来自 [Dashboard Icons](https://dashboardicons.com)（MIT License）

## 安全与透明

- 本仓库仅下载并重打包官方发布内容，不修改上游业务逻辑
- 应用默认按非 root 用户运行（提升默认安全性）；个别需要宿主机权限的原生应用（清理精灵、敲门 Knock）以 root 运行，已在其说明中标注
- 构建脚本、CI 流程与发布记录均公开可审计

<!-- Release Links -->
[r-store]: https://github.com/conversun/fnos-apps/releases?q=fnos-apps-store
[r-plex]: https://github.com/conversun/fnos-apps/releases?q=plex
[r-emby]: https://github.com/conversun/fnos-apps/releases?q=emby
[r-emby-lts]: https://github.com/Helenvin/fnos-apps/releases?q=emby-lts
[r-jellyfin]: https://github.com/conversun/fnos-apps/releases?q=jellyfin
[r-navidrome]: https://github.com/conversun/fnos-apps/releases?q=navidrome
[r-metatube]: https://github.com/conversun/fnos-apps/releases?q=metatube
[r-kavita]: https://github.com/conversun/fnos-apps/releases?q=kavita
[r-tmm]: https://github.com/conversun/fnos-apps/releases?q=tinymediamanager
[r-qb]: https://github.com/conversun/fnos-apps/releases?q=qbittorrent
[r-transmission]: https://github.com/conversun/fnos-apps/releases?q=transmission
[r-gopeed]: https://github.com/conversun/fnos-apps/releases?q=gopeed
[r-syncthing]: https://github.com/conversun/fnos-apps/releases?q=syncthing
[r-ani]: https://github.com/conversun/fnos-apps/releases?q=ani-rss
[r-abs]: https://github.com/conversun/fnos-apps/releases?q=audiobookshelf
[r-mp]: https://github.com/Helenvin/fnos-apps/releases?q=moviepilot
[r-openlist]: https://github.com/conversun/fnos-apps/releases?q=openlist
[r-kodbox]: https://github.com/conversun/fnos-apps/releases?q=kodbox
[r-sunpanel]: https://github.com/conversun/fnos-apps/releases?q=sun-panel
[r-certimate]: https://github.com/conversun/fnos-apps/releases?q=certimate
[r-vw]: https://github.com/conversun/fnos-apps/releases?q=vaultwarden
[r-nginx]: https://github.com/conversun/fnos-apps/releases?q=nginx
[r-nginx-ui]: https://github.com/conversun/fnos-apps/releases?q=nginx-ui
[r-gotify]: https://github.com/conversun/fnos-apps/releases?q=gotify
[r-ddnsgo]: https://github.com/conversun/fnos-apps/releases?q=ddns-go
[r-wolgoweb]: https://github.com/conversun/fnos-apps/releases?q=wolgoweb
[r-adguardhome]: https://github.com/conversun/fnos-apps/releases?q=adguardhome
[r-firefox]: https://github.com/conversun/fnos-apps/releases?q=firefox
[r-chromium]: https://github.com/conversun/fnos-apps/releases?q=chromium
[r-ab]: https://github.com/conversun/fnos-apps/releases?q=auto-bangumi
[r-immich]: https://github.com/conversun/fnos-apps/releases?q=immich
[r-koel]: https://github.com/conversun/fnos-apps/releases?q=koel
[r-photoprism]: https://github.com/conversun/fnos-apps/releases?q=photoprism
[r-jellyseerr]: https://github.com/conversun/fnos-apps/releases?q=jellyseerr
[r-csf]: https://github.com/conversun/fnos-apps/releases?q=chinesesubfinder
[r-freshrss]: https://github.com/conversun/fnos-apps/releases?q=freshrss
[r-miniflux]: https://github.com/conversun/fnos-apps/releases?q=miniflux
[r-linkwarden]: https://github.com/conversun/fnos-apps/releases?q=linkwarden
[r-wikijs]: https://github.com/conversun/fnos-apps/releases?q=wikijs
[r-mealie]: https://github.com/conversun/fnos-apps/releases?q=mealie
[r-paperless]: https://github.com/conversun/fnos-apps/releases?q=paperless-ngx
[r-sonarr]: https://github.com/conversun/fnos-apps/releases?q=sonarr
[r-radarr]: https://github.com/conversun/fnos-apps/releases?q=radarr
[r-lidarr]: https://github.com/conversun/fnos-apps/releases?q=lidarr
[r-readarr]: https://github.com/conversun/fnos-apps/releases?q=readarr
[r-prowlarr]: https://github.com/conversun/fnos-apps/releases?q=prowlarr
[r-bazarr]: https://github.com/conversun/fnos-apps/releases?q=bazarr
[r-homepage]: https://github.com/conversun/fnos-apps/releases?q=homepage
[r-homarr]: https://github.com/conversun/fnos-apps/releases?q=homarr
[r-uptimekuma]: https://github.com/conversun/fnos-apps/releases?q=uptime-kuma
[r-beszel]: https://github.com/conversun/fnos-apps/releases?q=beszel
[r-filebrowser]: https://github.com/conversun/fnos-apps/releases?q=filebrowser
[r-stirlingpdf]: https://github.com/conversun/fnos-apps/releases?q=stirling-pdf
[r-actual]: https://github.com/conversun/fnos-apps/releases?q=actual-budget
[r-lucky]: https://github.com/conversun/fnos-apps/releases?q=lucky
[r-aellus]: https://github.com/conversun/fnos-apps/releases?q=aellus
[r-siyuan]: https://github.com/conversun/fnos-apps/releases?q=siyuan
[r-vikunja]: https://github.com/conversun/fnos-apps/releases?q=vikunja
[r-glance]: https://github.com/conversun/fnos-apps/releases?q=glance
[r-frps]: https://github.com/conversun/fnos-apps/releases?q=frps
[r-rustdesk-server]: https://github.com/conversun/fnos-apps/releases?q=rustdesk-server
[r-pocket-id]: https://github.com/conversun/fnos-apps/releases?q=pocket-id
[r-homebox]: https://github.com/conversun/fnos-apps/releases?q=homebox
[r-metube]: https://github.com/conversun/fnos-apps/releases?q=metube
[r-smartdns]: https://github.com/conversun/fnos-apps/releases?q=smartdns
[r-mihomo]: https://github.com/conversun/fnos-apps/releases?q=mihomo
[r-mosdns]: https://github.com/conversun/fnos-apps/releases?q=mosdns
[r-tautulli]: https://github.com/conversun/fnos-apps/releases?q=tautulli
[r-seerr]: https://github.com/conversun/fnos-apps/releases?q=seerr
[r-ente]: https://github.com/conversun/fnos-apps/releases?q=ente
[r-sunshine]: https://github.com/conversun/fnos-apps/releases?q=sunshine
[r-frigate]: https://github.com/conversun/fnos-apps/releases?q=frigate
[r-alist]: https://github.com/conversun/fnos-apps/releases?q=alist
[r-rclone]: https://github.com/conversun/fnos-apps/releases?q=rclone
[r-cloudreve]: https://github.com/conversun/fnos-apps/releases?q=cloudreve
[r-appflowy]: https://github.com/conversun/fnos-apps/releases?q=appflowy
[r-jackett]: https://github.com/conversun/fnos-apps/releases?q=jackett
[r-1panel]: https://github.com/conversun/fnos-apps/releases?q=1panel
[r-grafana]: https://github.com/conversun/fnos-apps/releases?q=grafana
[r-prometheus]: https://github.com/conversun/fnos-apps/releases?q=prometheus
[r-loki]: https://github.com/conversun/fnos-apps/releases?q=loki
[r-glances]: https://github.com/conversun/fnos-apps/releases?q=glances
[r-n8n]: https://github.com/conversun/fnos-apps/releases?q=n8n
[r-ntfy]: https://github.com/conversun/fnos-apps/releases?q=ntfy
[r-gitea]: https://github.com/conversun/fnos-apps/releases?q=gitea
[r-duplicati]: https://github.com/conversun/fnos-apps/releases?q=duplicati
[r-it-tools]: https://github.com/conversun/fnos-apps/releases?q=it-tools
[r-mattermost]: https://github.com/conversun/fnos-apps/releases?q=mattermost
[r-homeassistant]: https://github.com/conversun/fnos-apps/releases?q=homeassistant
[r-localai]: https://github.com/conversun/fnos-apps/releases?q=localai
[r-librechat]: https://github.com/conversun/fnos-apps/releases?q=librechat
[r-pihole]: https://github.com/conversun/fnos-apps/releases?q=pihole
[r-wg-easy]: https://github.com/conversun/fnos-apps/releases?q=wg-easy
[r-headscale]: https://github.com/conversun/fnos-apps/releases?q=headscale
[r-netbird]: https://github.com/conversun/fnos-apps/releases?q=netbird
[r-komga]: https://github.com/conversun/fnos-apps/releases?q=komga
[r-koodo]: https://github.com/conversun/fnos-apps/releases?q=koodo-reader
[r-handbrake]: https://github.com/conversun/fnos-apps/releases?q=handbrake
[r-suwayomi]: https://github.com/conversun/fnos-apps/releases?q=suwayomi
[r-lanraragi]: https://github.com/conversun/fnos-apps/releases?q=lanraragi
[r-jellystat]: https://github.com/conversun/fnos-apps/releases?q=jellystat
[r-ombi]: https://github.com/conversun/fnos-apps/releases?q=ombi
[r-wizarr]: https://github.com/conversun/fnos-apps/releases?q=wizarr
[r-medusa]: https://github.com/conversun/fnos-apps/releases?q=medusa
[r-sabnzbd]: https://github.com/conversun/fnos-apps/releases?q=sabnzbd
[r-copyparty]: https://github.com/conversun/fnos-apps/releases?q=copyparty
[r-reactive-resume]: https://github.com/conversun/fnos-apps/releases?q=reactive-resume
[r-npm]: https://github.com/conversun/fnos-apps/releases?q=nginx-proxy-manager
[r-dpanel]: https://github.com/conversun/fnos-apps/releases?q=dpanel
[r-netdata]: https://github.com/conversun/fnos-apps/releases?q=netdata
[r-nodered]: https://github.com/conversun/fnos-apps/releases?q=node-red
[r-forgejo]: https://github.com/conversun/fnos-apps/releases?q=forgejo
[r-clamav]: https://github.com/conversun/fnos-apps/releases?q=clamav
[r-openwebui]: https://github.com/conversun/fnos-apps/releases?q=open-webui
[r-ollama]: https://github.com/conversun/fnos-apps/releases?q=ollama
[r-maxkb]: https://github.com/conversun/fnos-apps/releases?q=maxkb
[r-tailscale]: https://github.com/conversun/fnos-apps/releases?q=tailscale
[r-nvidia-driver]: https://github.com/conversun/fnos-apps/releases?q=nvidia-driver
[r-zeroclaw]: https://github.com/conversun/fnos-apps/releases?q=zeroclaw
[r-picoclaw]: https://github.com/conversun/fnos-apps/releases?q=picoclaw
[r-nanobot]: https://github.com/conversun/fnos-apps/releases?q=nanobot
[r-copaw]: https://github.com/conversun/fnos-apps/releases?q=copaw
[r-cowagent]: https://github.com/conversun/fnos-apps/releases?q=cowagent
[r-qwenpaw]: https://github.com/conversun/fnos-apps/releases?q=qwenpaw
[r-lyranest]: https://github.com/conversun/fnos-apps/releases?q=lyranest
[r-arcane]: https://github.com/conversun/fnos-apps/releases?q=arcane
[r-miair-next]: https://github.com/conversun/fnos-apps/releases?q=miair-next
[r-surface-battery]: https://github.com/conversun/fnos-apps/releases?q=surface-battery
[r-danmu-api]: https://github.com/conversun/fnos-apps/releases?q=danmu-api
[r-aria2-next]: https://github.com/conversun/fnos-apps/releases?q=aria2-next
[r-opensurge]: https://github.com/conversun/fnos-apps/releases?q=opensurge
[r-LitePan]: https://github.com/Helenvin/fnos-apps/releases?q=LitePan
[r-astrbot]: https://github.com/Helenvin/fnos-apps/releases?q=astrbot
[r-avdb]: https://github.com/Helenvin/fnos-apps/releases?q=avdb
[r-calibre-web]: https://github.com/Helenvin/fnos-apps/releases?q=calibre-web
[r-clouddrive2]: https://github.com/Helenvin/fnos-apps/releases?q=clouddrive2
[r-coolercontrol]: https://github.com/Helenvin/fnos-apps/releases?q=coolercontrol
[r-daidai-panel]: https://github.com/Helenvin/fnos-apps/releases?q=daidai-panel
[r-docsify]: https://github.com/Helenvin/fnos-apps/releases?q=docsify
[r-feigram]: https://github.com/Helenvin/fnos-apps/releases?q=feigram
[r-fileview]: https://github.com/Helenvin/fnos-apps/releases?q=fileview
[r-fn-VirtualHereServer]: https://github.com/Helenvin/fnos-apps/releases?q=fn-VirtualHereServer
[r-fn-WParted]: https://github.com/Helenvin/fnos-apps/releases?q=fn-WParted
[r-fn-advancedsettings]: https://github.com/Helenvin/fnos-apps/releases?q=fn-advancedsettings
[r-fn-appdownload]: https://github.com/Helenvin/fnos-apps/releases?q=fn-appdownload
[r-fn-appsettings]: https://github.com/Helenvin/fnos-apps/releases?q=fn-appsettings
[r-fn-audioplayer]: https://github.com/Helenvin/fnos-apps/releases?q=fn-audioplayer
[r-fn-bluetooth]: https://github.com/Helenvin/fnos-apps/releases?q=fn-bluetooth
[r-fn-codeserver]: https://github.com/Helenvin/fnos-apps/releases?q=fn-codeserver
[r-fn-execute]: https://github.com/Helenvin/fnos-apps/releases?q=fn-execute
[r-fn-fail2ban]: https://github.com/Helenvin/fnos-apps/releases?q=fn-fail2ban
[r-fn-grafana-alloy]: https://github.com/Helenvin/fnos-apps/releases?q=fn-grafana-alloy
[r-fn-iVentoy]: https://github.com/Helenvin/fnos-apps/releases?q=fn-iVentoy
[r-fn-influxdb]: https://github.com/Helenvin/fnos-apps/releases?q=fn-influxdb
[r-fn-installer]: https://github.com/Helenvin/fnos-apps/releases?q=fn-installer
[r-fn-linux-station]: https://github.com/Helenvin/fnos-apps/releases?q=fn-linux-station
[r-fn-p2s]: https://github.com/Helenvin/fnos-apps/releases?q=fn-p2s
[r-fn-scheduler]: https://github.com/Helenvin/fnos-apps/releases?q=fn-scheduler
[r-fn-scrutiny]: https://github.com/Helenvin/fnos-apps/releases?q=fn-scrutiny
[r-fn-speedtest]: https://github.com/Helenvin/fnos-apps/releases?q=fn-speedtest
[r-fn-terminal]: https://github.com/Helenvin/fnos-apps/releases?q=fn-terminal
[r-fn-vgmng]: https://github.com/Helenvin/fnos-apps/releases?q=fn-vgmng
[r-fn-wifi-hotspot]: https://github.com/Helenvin/fnos-apps/releases?q=fn-wifi-hotspot
[r-fn-zerotier]: https://github.com/Helenvin/fnos-apps/releases?q=fn-zerotier
[r-fnclearup]: https://github.com/Helenvin/fnos-apps/releases?q=fnclearup
[r-fn-knock]: https://github.com/Helenvin/fnos-apps/releases?q=fn-knock
[r-komari]: https://github.com/Helenvin/fnos-apps/releases?q=komari
[r-mail-archiver]: https://github.com/Helenvin/fnos-apps/releases?q=mail-archiver
[r-mdc]: https://github.com/Helenvin/fnos-apps/releases?q=mdc
[r-melody-hub]: https://github.com/Helenvin/fnos-apps/releases?q=melody-hub
[r-memos]: https://github.com/Helenvin/fnos-apps/releases?q=memos
[r-msf]: https://github.com/Helenvin/fnos-apps/releases?q=msf
[r-next-ai-draw-io]: https://github.com/Helenvin/fnos-apps/releases?q=next-ai-draw-io
[r-nextcloud]: https://github.com/Helenvin/fnos-apps/releases?q=nextcloud
[r-obsidian]: https://github.com/Helenvin/fnos-apps/releases?q=obsidian
[r-puter]: https://github.com/Helenvin/fnos-apps/releases?q=puter
[r-qinglong]: https://github.com/Helenvin/fnos-apps/releases?q=qinglong
[r-rocketchat]: https://github.com/Helenvin/fnos-apps/releases?q=rocketchat
[r-sakurafrp]: https://github.com/Helenvin/fnos-apps/releases?q=sakurafrp
[r-seafile]: https://github.com/Helenvin/fnos-apps/releases?q=seafile
[r-songloft]: https://github.com/Helenvin/fnos-apps/releases?q=songloft
[r-sqmusic]: https://github.com/Helenvin/fnos-apps/releases?q=sqmusic
[r-sub-store]: https://github.com/Helenvin/fnos-apps/releases?q=sub-store
[r-suggestarr]: https://github.com/Helenvin/fnos-apps/releases?q=suggestarr
[r-verysync]: https://github.com/Helenvin/fnos-apps/releases?q=verysync
[r-vibenvr]: https://github.com/Helenvin/fnos-apps/releases?q=vibenvr
[r-visor]: https://github.com/Helenvin/fnos-apps/releases?q=visor
[r-zerotier]: https://github.com/Helenvin/fnos-apps/releases?q=zerotier
[r-zonefoundry-bridge]: https://github.com/Helenvin/fnos-apps/releases?q=zonefoundry-bridge
