# Mac OS Agent MVP

## 仓库结构

这是一个单 Git 仓库、两层目录的协作仓库：根目录保存项目规则、计划和真实进度，`cua/` 保存完整 Cua 上游历史及本项目实现。协作者只需 clone 本仓库，不需要再嵌套 clone。

```text
mac_agent/
├── AGENTS.md、PROGRESS.md、计划与协作文档
├── evidence/README.md       # 证据发布边界；原始运行证据不进 Git
└── cua/                     # Cua 源码和 samples/mac_agent_mvp
```

虚拟机磁盘、IPSW、API Key、登录密码、VNC 会话、构建缓存和原始截图不上传 GitHub。实际 VM 协作方法见 [COLLABORATION.md](COLLABORATION.md)，固定环境见 [vm-manifest.json](vm-manifest.json)。

当前 M0 已实际验收通过；M1 固定计算器流程也已通过。已创建 macOS VM、完成首次设置、安装固定版本 Driver，并建立普通测试账户。规则见 [AGENTS.md](AGENTS.md)，阶段计划见 [计划书](Mac_OS_Agent_MVP_Plan_v0.1.md)，完整事实及失败记录见 [PROGRESS.md](PROGRESS.md)。

## 版本与位置

| 项目 | 实际状态 |
|---|---|
| 宿主 | Apple M4 / 16 GiB / macOS 15.6 (24G84) |
| Cua | 独立 `cua/` 仓库，分支 `codex/mac-agent-mvp`，基点 `9bbfa7dd3e27ca7f1861ede70aaca390174493f9` |
| 安装版 Lume | 0.5.3，tag commit `754eec754991e1760100621e9bfe7ec1395cc7db`，未替换 |
| 开发隔离构建 | Cua 基点上的最小 opt-in Lume 补丁，见 sample README |
| VM | `.vm/mac-agent-mvp-15-6-1`，4 核 / 8 GiB / 40 GiB / NAT |
| 来宾实测 | macOS 15.6.1 (24G90)，SIP enabled，无 VirtioFS 挂载 |
| Driver | 0.28.2，官方包在 VM 内 SHA-256 校验后安装到 `/Applications/CuaDriver.app`，版本命令成功 |
| 账户 | `mvpadmin` 仅初始化；`mvpagent` 为普通账户，非 admin、无 sudo 权限 |
| Python / SDK / 模型 | 恢复副本内 Python 3.12.14；DeepSeek 凭证已在 VM 保存并核验权限，SDK 接入与鉴权未完成 |

## 隔离与证据

原版 Lume 会隐式共享配置目录和 `/var/empty`，native viewer 会启用剪贴板桥，因此不能只凭没有传 `--shared-dir` 判定隔离。项目内新增 `LUME_MVP_HOST_ISOLATION=1` 启动模式，拒绝宿主挂载和查看器桥接，实际构造零目录共享设备。只用 VM loopback VNC 做开发初始化，不操作宿主应用或个人文件。此开关是开发侧 VM 管理约束，不是受测 Agent 工具策略；M1/M2 仍需另外实现执行端限制。

IPSW 证据见 [镜像记录](evidence/m0-download.json)，来宾版本/SIP 见 [实测截图](evidence/m0-guest-system-confirmed.png)，Driver 校验与版本见 [安装截图](evidence/m0-driver-installed.png)，普通账户限制见 [账户检查](evidence/m0-standard-user-check.png)。这些是 M0 开发证据，不是计算器任务验收。

配置基线 `mac-agent-mvp-15-6-1-configured` 已停机保存；从基线 clone 到 `mac-agent-mvp-15-6-1-restored` 并启动，普通账户、Driver 权限、应用列表和新截图均已验证。当前开发使用 restored，原 VM 与 configured 保持停机。较早的 installed 仅为系统安装后基线。镜像、VM、凭据和开发二进制均被 Git 忽略。

恢复方式：用项目隔离二进制 `clone` 将 configured 克隆到未使用的新名字（source/dest storage 均指向项目 `.vm`），再以 `LUME_MVP_HOST_ISOLATION=1`、`--display none --network nat` 启动。普通账户登录后，在 VM 内执行 `open -n -g -a CuaDriver --args serve`，然后验证权限与截图。基线不含后续安装的 Python，恢复后按所需阶段补齐。

## UFO 与阶段门禁

M0 已读 UFO `be75a7ded2ad98d97819e15ff1b39d4202ac3ac5` 的 `documents/docs/infrastructure/agents/overview.md`：Three-Layer Architecture。只借鉴状态、处理流程、执行三种职责，不搬类体系、多 Agent、多设备或长期记忆；分层不等于隔离。

M0 已通过，证据见 `evidence/m0-configured-baseline.json`、`m0-restored-verified.png`、`m0-restored-preview.png`。M1 已读 UFO 固定版本 `ufo/module/dispatcher.py`，新增固定流程与调用记录，17 次调用实际完成 12×34，读取 408 并通过独立 smoke 断言；M2 已确认 DeepSeek 官方 API，待 VM 内凭证配置及 SDK/受限工具接入实测，M3–M4 未开始。

当前 `--display none` 后台运行，对话中的图片是 VM 静态截图。宿主不运行受测 Driver 或计算器。完整运行方法见 `cua/samples/mac_agent_mvp/README.md`。

M1 最终截图：`evidence/m1-run-2/state-17.png`；日志与独立断言保存在同目录。7 项单元测试在宿主与 VM 内均通过。当前还没有模型执行和 result.txt 完整校验，不代表整个 MVP 已完成。
