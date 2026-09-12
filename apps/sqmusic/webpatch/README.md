# webdist/dist.tgz 重建说明

`dist.tgz` 是对上游 [59799517/simple_sq_music_plus_web](https://github.com/59799517/simple_sq_music_plus_web)
**v3 分支**构建产物的补丁版打包，包含 `dist/`（Vue 构建产物）+ `nginx.conf`（含 `/qq/` 代理）。
`scripts/apps/sqmusic/build.sh` 在打 app.tgz 时解包到 `webdist/` 目录，由 `sqmusic_web` 容器只读挂载。

## 本目录内容（保持上游目录结构，重建时直接覆盖同名文件）

| 文件 | 说明 |
|---|---|
| `src/components/V3Discover.vue` | 新增：发现页（QQ 榜单 25 个匿名可看可下 + 歌单广场浏览），每首歌带下载按钮，支持整单批量下载 |
| `src/components/V3TopWitge.vue` | 修改：PC + 移动端导航首位置插入"发现"入口（/v3discover） |
| `src/router/index.js` | 修改：注册 `/v3discover` 路由，`/home` 默认重定向改为发现页 |
| `nginx.conf` | 修改：新增 `location /qq/` 反代 `c.y.qq.com`（注入 Referer https://y.qq.com/ ，否则 fcg 接口返回 code=-2） |

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

- 发现页的 QQ fcg 接口依赖 nginx `/qq/` 代理注入 Referer，直接访问 `c.y.qq.com` 会被拒（code=-2），
  因此 nginx.conf 必须随 dist 一起打包，且 `sqmusic_web` 容器务必挂载本目录的 nginx.conf。
- 歌单广场的**歌单详情/整单下载**走后端 `/api/parser/parserUrlInfo`（需在设置里 QQ 扫码登录）；
  榜单功能完全匿名可用。
- 上游若升级到 v4 等不兼容版本，需按新版组件结构重做补丁。
