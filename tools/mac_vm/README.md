# 现有 macOS VM 工具

本目录保留项目已实现的代码，不是 Pi Agent。三个 Python 文件从旧 cua/samples/mac_agent_mvp/ 原样迁入；导入层级保持不变。

## 运行范围

- preflight.py：开发侧只读清单，不启动 VM、不调用桌面工具，输出不包含 VNC 密码。
- driver_smoke.py：在指定测试 VM 内固定执行 12×34，检查计算器 PID／窗口，读取 AX 显示并记录证据。
- tests/test_driver_smoke.py：7 项 mock 边界测试；--live 仅在测试 VM 执行固定流程与独立 smoke 断言。

在仓库根目录运行无桌面测试：

```bash
python3 -m unittest discover -s tools/mac_vm/tests -v
```

将本目录部署到测试 VM 后，在本目录内运行（需 Python 3.12.14 或经验证的兼容版本、Driver 0.28.2、普通 mvpagent 账户和已授权的图形会话）：

```bash
open -n -g -a CuaDriver --args serve
python3 tests/test_driver_smoke.py --live
```

live 入口检查 VirtualMac 与普通测试账户；不能通过删检查来改成控制宿主。调用最多 30 次，超时结果未知时不重放动作。每次在 VM 的 ~/AgentWorkspace/ 新建证据目录，保存 trace、final_state、截图和 smoke_assertion；当前不生成完整 MVP 的 result.txt。

开发侧 inventory（路径替换为实际已存在的 VM storage）：

```bash
python3 tools/mac_vm/preflight.py --storage /absolute/path/to/vm-storage --vm mac-agent-mvp-15-6-1-restored
```

退出 0 只表示读取成功；NOT_ASSESSED 不代表隔离或任务验收通过。

## VM 恢复

环境声明见 [vm-manifest.json](../../vm-manifest.json)，构建方式见 [Lume 补丁](../../patches/cua/README.md)。现有 configured 是停机配置基线，restored 是开发副本；后者曾保存凭证，不能作为共享镜像。

使用经验证的隔离 Lume 二进制，从停机基线 clone 到未占用的新名字，明确 source/dest storage。启动设置 LUME_MVP_HOST_ISOLATION=1、LUME_TELEMETRY_ENABLED=false，参数使用 --display none --network nat。先核对该固定版本的 --help，不覆盖现有 VM。

普通账户登录后启动 Driver daemon，再检查权限、有效截图、应用信息和无宿主共享。开发查看使用受控 VNC，不启用目录／剪贴板桥。恢复不等于已安装 Pi，也不自动验证模型凭证。

历史 M1：17 次实际调用，AX 显示 408，独立 smoke 断言通过。原始证据留在受控本地目录，GitHub 不公开发布。历史 UFO 调研不是执行依赖；详见旧 Git 提交。
