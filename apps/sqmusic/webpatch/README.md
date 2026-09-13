# webdist/dist.tgz 重建说明

`dist.tgz` 是对上游 [59799517/simple_sq_music_plus_web](https://github.com/59799517/simple_sq_music_plus_web)
**v3 分支**构建产物的补丁版打包，包含 `dist/`（Vue 构建产物）+ `nginx.conf`（含 `/qq/` 代理）。
`scripts/apps/sqmusic/build.sh` 在打 app.tgz 时解包到 `webdist/` 目录，由 `sqmusic_web` 容器只读挂载。

> **补丁源码仓库（2026-09-13 起，以此为准）**：[Helenvin/simple_sq_music_plus_web](https://github.com/Helenvin/simple_sq_music_plus_web)（v3 分支）。
> 4 个补丁已合入 fork 源码，仓库内含 `PATCHES.md`（补丁清单 + 上游同步/冲突重放说明）、`build-dist.sh`（一键构建）、
> Actions「Build dist」（在线产 dist.tgz）。以后更新流程：fork 页 Sync fork → 有冲突按 PATCHES.md 重放 →
> 本地 build-dist.sh 或跑 Actions 产 dist.tgz → 放回本目录（apps/sqmusic/webdist/dist.tgz）→ fnos-apps 发新版。

## 本目录内容（保持上游目录结构，重建时直接覆盖同名文件）

| 文件 | 说明 |
|---|---|
| `src/components/V3Discover.vue` | 发现页 v5：整页嵌入 lxserver 洛雪播放器（iframe /lx/），旧聚合门户逻辑已全部删除 |
| `src/components/V3TopWitge.vue` | 修改：PC + 移动端导航首位置插入"发现"入口（/v3discover） |
| `src/router/index.js` | 修改：注册 `/v3discover` 路由，`/home` 默认重定向改为发现页 |
| `src/components/Monitor.vue` | 修改：监听页输入提示改为「支持网易云/酷我/酷狗/QQ音乐 歌单分享链接」 |
| `src/components/V3Set.vue` | 修改：QQ/微信登录二维码获取失败时弹出错误提示（原为静默空白） |
| `nginx.conf` | /qq/ + /kg/ 外站代理；lxserver 分派（/lx/ 播放器页、/js/、/rest/、/api 白名单 → lxserver:9527，其余 /api/* → sqmusic_main） |

## 重建步骤（上游出新版或改补丁后）

```bash
# 1. 取上游 v3 分支源码（tag 形如 v3.1.5）
git clone -b v3 https://github.com/59799517/simple_sq_music_plus_web.git sqmusic-web
cd sqmusic-web

# 2. 覆盖补丁（从本仓库 apps/sqmusic/webpatch/ 取）
cp -r ../apps/sqmusic/webpatch/src ./
cp    ../apps/sqmusic/webpatch/nginx.conf ./

# 3. 构建
npm install
npm run build          # 产出 dist/

# 4. 打包（dist/ + nginx.conf 同级放入 tar）
tar -czf ../apps/sqmusic/webdist/dist.tgz dist nginx.conf
```

## 注意

- 发现页的 QQ fcg 接口依赖 nginx `/qq/` 代理注入 Referer，直接访问 `c.y.qq.com` 会被拒（code=-2）；
  酷狗榜单/歌手/专辑接口依赖 `/kg/` 代理（mobiles.kugou.com，须带 m.kugou.com Referer + 移动 UA）。
  因此 nginx.conf 必须随 dist 一起打包（`tar -czf dist.tgz dist nginx.conf`），且 `sqmusic_web` 容器务必挂载本目录的 nginx.conf。
- 播放/下载走后端 `/api/music/getDownloadUrl`（v3.2.4 起匿名可用）+ 七源搜索换票；QQ 歌单广场详情走
  后端 `/api/parser/parserUrlInfo` + `parserUrl`（匿名可用）。
- 上游若升级到 v4 等不兼容版本，需按新版组件结构重做补丁。
