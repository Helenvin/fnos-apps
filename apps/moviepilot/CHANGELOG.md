## 2026-09-16（r5）

- **修复 r4 引入的「无法启用 moviepilot / 本地应用启动失败」**（比 r3 缺桌面图标更严重）
- 根因：r4 把「等载荷展开」挪进 `cmd/run_service` 时，用的是 `flock -w 600`——**等 600 秒拿不到锁就自己上手解压**。而首解 44,215 个条目在真机上会超过 600s，于是三个等待者（两个 `run_service` + 一个后台 `unpack_runtime`）在同一时刻集体超时、同时开解；GNU tar 并发解压同一棵树必然报 `Cannot open: File exists` → `unpack_payload` 返回 1 → `run_service` `exit 1` → 两个 pid 一起消失 → fnOS 记录 `APP_START_FAILED_LOCAL_APP_RUN_EXCEPTION`，应用中心显示「无法启用」，且每次重试都重复踩同一脚。实测佐证：顺序重复解压是幂等的（rc=0），只有并发解压才会报 `File exists`
- 修复：
  - **等待只能无上限地排队，绝不超时后抢着解**：拿不到锁就记一笔、再排一轮（每轮 300s，上限约 2h）
  - **同一时刻只允许一个展开者**：`service_prestart` 先非阻塞探锁，锁被占就不再起第二个后台展开进程
  - **展开完先校验关键文件在位才写 marker**（`runtime/python`、`runtime/app`、`venv/bin/python`、`app/public/service.js`、`app/.runtime/node/bin/node`），写不出 marker 就当没展开，下次重解
  - **`run_service` 绝不因展开问题退出**：失败就一直重试（每 20s），pid 活着飞牛就不会报「启动失败」；每次失败原因都落在 `moviepilot.log`
  - `SVC_WAIT_TIMEOUT` 240 → 30：单个 pid 死掉时不再空转 4 分钟卡在「启用中」
  - 无 `flock` 的环境退化成目录锁（mkdir 原子 + 持有者 pid 探活接管），不再默默无锁并发
- r4 的「装完没桌面图标」修复（启动回调不阻塞）保持不变
- ⚠️ manifest 的 `version` 仍是 `3.0.3`（跟随上游），**覆盖安装不会被飞牛当成版本变更**，请**先卸载再安装**；装完点「启用」后，首次展开仍需几分钟，日志在 `moviepilot.log` / `unpack.log`

## 2026-09-16（r4）

- **修复"装完桌面没有图标、应用中心没有「打开」按钮"**：此前 `service_prestart` 会阻塞等载荷展开（解压后约 1GB / 4 万多个文件，几分钟），而 fnOS 把「启动应用」当成安装流程的一环——启动步骤一直不返回会被判成没走完，桌面入口（app_service）就没登记上，表现为应用中心里只有「停用 / 卸载」、桌面既没图标也没「打开」，而服务本身是好的（3300 能访问）
- 等待挪进新的 `cmd/run_service`：`SERVICE_COMMAND` 两行各起一个包装进程，由 `start_daemon` 后台拉起，等多久都不占 fnOS 的启动回调；结尾 `exec`，PID 不变，启停/状态判断照旧。`service_prestart` 只把展开丢后台后立刻返回
- 构建前缀改写加了一把自己的锁：`service_prestart`、两个启动包装、后台展开可能并发走到同一批 venv 文件上，之前有并行 `sed` 改出半对半错运行时的风险
- ⚠️ 因为 manifest 的 `version` 仍是 `3.0.3`（跟随上游），**覆盖安装不会被飞牛当成版本变更**，桌面入口不会刷新。修完的包请**先卸载再安装**

## 2026-09-16（r3）

- **修复安装失败**：上一版的 `app.tgz` 里直接铺开 44,890 个文件（其中 9,931 个路径名超出 tar 的 100 字节上限），超出 fnOS 内置解压器能处理的范围，真机上会报「解压app.tgz失败」。现在 `app.tgz` 里只有一个不透明的 `payload.tar.gz`，真正的目录树由应用在安装时后台展开、启动前补齐（可重入，失败下次启动重试）
- 不再随包内置 Chromium（解压后 729MB）：安装包体积降到原来的三分之一左右，浏览器仿真类站点首次使用时由 MoviePilot 自行下载到应用数据目录
- 预置目录授权：安装即声明对 `/vol1/1000` 的读写权限，可直接把媒体库设为该目录下的子路径，无需手动授权
- 后端以 `PYTHONUNBUFFERED=1` 运行，日志实时写入；前端 watchdog 探测参数对齐上游原生模式
