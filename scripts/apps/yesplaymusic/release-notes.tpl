自动构建的 fnOS 安装包

- 基于 [YesPlayMusic](https://github.com/qier222/YesPlayMusic) v${UPSTREAM_TAG} 第三方网易云网页客户端（单容器 nginx 前端 + NetEase API）
- 已打通 SQMusic：歌曲右键「下载到 NAS（sqmusic）」直推 SQMusic 后端，统一落盘 /vol1/1000/audio/music
- 平台: fnOS x86（单容器，浏览器打开即用）
- 默认端口: ${DEFAULT_PORT}
- 容器名 yesplaymusic；安装向导可指定 SQMusic 联动地址（默认 http://172.17.0.1:8097）${REVISION_NOTE}
${CHANGELOG}