## 2026-09-12

- 首次发布：simple_sq_music_plus v3.1.29 + 自研「发现」页补丁
- 发现页：QQ 25 个榜单匿名浏览、逐首下载、整榜批量下载；歌单广场分类浏览（解析下载需在设置中 QQ 扫码登录）
- 应用打开默认进入发现页；搜索/下载/解析/监听等原有功能全部保留
- 仅支持 x86（mysql:5.7 无 arm64 镜像）

## 2026-09-13 后端镜像源切换 GHCR

- sqmusic_main 镜像从作者 aliyun 源切换为上游官方 GHCR（ghcr.io/59799517/simple_sq_music_plus:v<ver>），同一构建产物；国内直连实测 ~3.2MB/s（aliyun OSS 仅 ~0.5MB/s），1.3GB 镜像拉取从约 48 分钟缩短到约 7 分钟。
- nginx / mysql 仍走 DOCKER_MIRROR 加速链。

## 2026-09-13 v3.2.0 多平台歌单监听（自研版）

- 后端基于 Helenvin/simple_sq_music_plus（3.0 分支）自研重构，版本号升级 3.2.0：
  - **新增酷我/酷狗/QQ音乐歌单监听下载**（原版仅支持网易云）：`ScanKwKgQqPlayList` 每分钟错峰扫描，
    与网易云一致的增量模式（歌单元数据回填 + sq_sync 防重），前提是在设置中开启对应插件。
  - 监听添加页支持粘贴酷我 `playlist_detail`、酷狗（含 global_collection_id）、QQ 塔歌/网页歌单链接。
  - QQ 歌单列表接口匿名化（原版强制要求 QQ VIP 登录后才能解析歌单，实测接口本身匿名可用）。
- sqmusic_main 镜像切换为自研版 GHCR：`ghcr.io/helenvin/simple_sq_music_plus:v<ver>`（由 fork CI 自动构建，双架构）。
- 前端补丁更新：监听页提示文案支持四平台；QQ 登录二维码获取失败时给出错误提示（原为静默空白）。

## 2026-09-13 v3.2.1 分享短链接支持 + 发现页洛雪风格 UI

- **监听添加支持分享短链接**（此前仅支持完整链接，短链会报"不能识别"）：
  - QQ 短链（如 `https://c6.y.qq.com/base/fcgi-bin/u?__=xxx`）：后端多跳 302 展开后再解析歌单 id
  - 酷狗短链（如 `https://t1.kugou.com/xxxx`）：302 展开为分享页，支持酷狗"收藏/最近"分享列表（SSR 内嵌歌曲列表，扫描任务按 hash 增量下载）
- **发现页 UI 重做为洛雪音乐风格**：左侧窄导航（搜索/榜单/歌单）+ 主区列表视图（歌曲/歌手/专辑/时长/音质标签/下载），主色调洛雪绿
- 发现页新增**搜索下载**（QQ 源聚合搜索，洛雪式逐首下载 + 整页批量）
- 歌单广场详情链路确认匿名可用，移除"需要 QQ 扫码登录"误导提示，改为中性重试提示
- 后端 `ghcr.io/helenvin/simple_sq_music_plus:v3.2.1`

## 2026-09-13 v3.2.2 发现页 YesPlayMusic 化 + QQ 歌单匿名解析根治

- **发现页 UI 重做为 YesPlayMusic 风格**（不只是换皮，功能链路重做）：
  - 左侧图标导航（发现音乐/排行榜/歌单广场）+ 顶部圆角搜索，主色调 YPM 蓝 (#335eea)
  - 首页：渐变 hero 横幅 + 推荐歌单大封面卡片网格 + 排行榜横排卡片
  - 歌单详情改为 **YPM 大封面页**：180px 封面 + 歌单名/数量/简介 + 下载全部/后台解析整单
- **根治"歌单必须扫码登录/扫了也没用"**：QQ 歌单接口 `CgiGetDiss` 拒绝后端所发
  `Referer: https://y.qq.com`（实测返回 inner code 10000 "invalid referer" → 空数据），
  已移除该请求头，歌单名/封面/总数/分页列表全部**匿名可用**（监听扫描同步受益）
- **歌单详情真正显示歌曲列表**：此前前端误用仅返回元数据的 parserUrlInfo（永远 0 首），
  改为并行调用 parserUrlInfo（头部元数据）+ parserUrl（完整歌曲列表，含音质码率可直接下载）
- **修复监听添加插件名错误**（所有平台都被存成 netease 的 bug）：后端 ParserInfo 历史拼写
  `plugNmae` 的 JSON 序列化键统一为 `plugName`，前端兼容读取
- 榜单歌曲行增强：带封面/歌曲 id（songmid/albummid 推导）；无插件信息行下载改为搜索换票（修复下载按钮报"无可下载码率"）
- 后端 `ghcr.io/helenvin/simple_sq_music_plus:v3.2.2`
- ⚠️ 升级后请删除升级前添加的错误监听记录（如"插件名称：netease"的 QQ 歌单），重新添加即可正确识别
