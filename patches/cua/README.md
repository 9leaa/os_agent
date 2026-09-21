# Cua / Lume 项目补丁

这里只保留本项目实际实现的隔离改动，不存放整套 Cua 上游副本。

- 来源：https://github.com/trycua/cua
- 固定基点：9bbfa7dd3e27ca7f1861ede70aaca390174493f9
- 项目改动来源：旧开发提交 e29e22a83；清理前发布树 466dd627b4a23284eae5b9d248312bbd07f010f4 的 cua/。
- 许可证：[MIT](LICENSE.md)；上游规则与完整历史可从固定源和 Git 历史读取。
- 补丁：[lume-host-isolation.patch](lume-host-isolation.patch)。

补丁包含 3 个已有文件修改、1 个隔离 helper 和 1 个测试文件，路径均相对 Cua 根目录。LUME_MVP_HOST_ISOLATION=1 时拒绝宿主挂载、native 查看器／剪贴板桥及动态共享，并去掉隐式目录共享设备；不是受测 Agent 的工具权限系统。

## 重建（开发侧，非 Agent 工具）

以下会下载源码和构建依赖，须在获准的独立目录执行；不要在运行中的 VM 目录或非空项目目录覆盖 clone。补丁路径替换为本仓库的绝对路径。

```bash
git clone https://github.com/trycua/cua.git cua-upstream
cd cua-upstream
git checkout --detach 9bbfa7dd3e27ca7f1861ede70aaca390174493f9
git apply --check /absolute/path/to/mac_agent/patches/cua/lume-host-isolation.patch
git apply /absolute/path/to/mac_agent/patches/cua/lume-host-isolation.patch
cd libs/lume
LUME_MVP_HOST_ISOLATION=1 LUME_TELEMETRY_ENABLED=false /usr/bin/arch -arm64 /usr/bin/xcrun swift test --jobs 2 --filter mvpIsolation
```

构建环境需兼容该上游版本；历史使用 Swift 6.2。运行前还需按上游说明为开发二进制配置 virtualization entitlement 和签名；单元测试通过不等于签名、VM 启动或零共享已验证。不要替换用户全局 Lume。

历史 2 项隔离测试及 VM 配置检查通过；本轮只验证补丁可应用和现有 Python 测试，不重新构建、签名或启动 VM。
