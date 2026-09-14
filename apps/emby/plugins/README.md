# Emby 预置插件投放目录

把插件 dll 按「一个插件一个子目录」丢进本目录，提交后触发 CI 重新打包即可。

## 目录结构

```
apps/emby/plugins/
├── MyPluginA/                 # 目录名建议与插件名一致
│   ├── MyPluginA.dll
│   └── meta.json              # 可选，插件自带元数据
└── MyPluginB/
    └── MyPluginB.dll
```

目录名即 Emby 侧识别的插件目录名，可以包含 dll、配置、资源等任意随附文件，打包时整目录原样保留。

## 打包与生效过程

1. `scripts/apps/emby/build.sh` 把本目录内容（排除本 README 与隐藏文件）打进安装包内的 `plugins-default/`
2. 应用首次启动时，`bin/emby-server` 把缺失的插件同步到数据目录 `plugins/`（即 `-programdata` 指向的目录）
3. **已存在的同名插件目录不会被覆盖**，你在 Emby 控制台后续安装或更新的版本优先
4. 若想强制用包内置版本替换：在 Emby 控制台卸载该插件 → 重启应用（数据目录里的同名目录需一并删除）

## 注意事项

- 只投放你自己有合法分发权的插件 dll
- 不要放用于绕过 Emby Premiere 授权校验的补丁 / 破解 dll —— 这类不会通过打包
- 插件 dll 必须与 Emby Server 版本匹配，否则启动时会加载失败（可在日志里看到 LoadAssembly 报错）
