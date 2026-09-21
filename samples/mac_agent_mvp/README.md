# Mac OS Agent MVP — M0 / M1 已通过

规则继承上游 AGENTS.md，另见交接工作区根 AGENTS.md、CODEX_HANDOFF.md、Mac_OS_Agent_MVP_Plan_v0.1.md、PROGRESS.md。上游规则与许可证未修改。

## 实际版本与状态

| 项目 | 版本/状态 |
|---|---|
| Cua | `9bbfa7dd3e27ca7f1861ede70aaca390174493f9`，本地 `codex/mac-agent-mvp` |
| 宿主 | Apple M4，16 GiB，macOS 15.6；仅项目开发与 VM 管理 |
| Lume | 安装版 0.5.3 保留；运行使用项目隔离 v2 构建 |
| VM | macOS 15.6.1 / 24G90，4 核、8 GiB、40 GiB、NAT、SIP enabled |
| 账户 | 普通 mvpagent，非 admin，无 sudo；初始化管理员凭据不交给受测 Agent |
| Driver | 官方 CuaDriver 0.28.2，VM 内 app daemon，辅助功能和录屏已授权并验证 |
| Python | VM 用户目录 Python 3.12.14，Astral standalone 20260901 ARM64，哈希已验证 |
| SDK / 模型 | 官方示例锁定 claude-agent-sdk 0.2.124，尚未安装/接入；DeepSeek 官方 API 凭证已在 VM 保存，未验证鉴权 |
| M0 | 截图、应用信息、隔离与配置基线恢复已实际通过 |
| M1 | 固定 12×34，17 次调用、19.311 秒，新 AX 显示 408，独立 smoke 断言通过 |
| M2–M4 | M2 源码准备中；M3/M4 未开始，尚无 result.txt 完整闭环 |

## M1 运行与证据

代码 `driver_smoke.py` 使用固定版本 Driver CLI 连接 VM 已有 daemon；无模型，不重新实现 MCP。运行入口拒绝宿主（要求 VirtualMac 和普通 mvpagent），只启动 Calculator，核对 PID 原生执行路径与窗口身份，按新快照选择限定 AXButton。无任意 shell、任意键盘输入或跨应用操作接口。

当前 VM 部署目录为 `~/MacAgentMVP-v2`。在测试 VM 内执行：

```bash
open -n -g -a CuaDriver --args serve
cd ~/MacAgentMVP-v2
~/MVPRuntime/python/bin/python3 tests/test_driver_smoke.py --live
```

每次新建 `~/AgentWorkspace/m1-<uuid>/`，保存 trace.jsonl、状态截图、final_state.json、execution.json、smoke_assertion.json。每次调用先记 DISPATCHED，再记 RETURNED/FAILED/UNKNOWN，含 run_id、step_id、call_id、tool、args、result、error、duration_ms、evidence_path。30 次总上限包括观察；动作超时只在余量内观察一次并停止，不重放动作。

显示值来自窗口内 AXStaticText。当前 Driver 的结构化 elements 只含可操作节点，源码中 elements_complete 固定 false；不要求这个字段为 true，而要求真实窗口、有效快照、明确存在的目标按钮和唯一整数显示。缺失或歧义则 UNVERIFIED。测试期望 408 仅在独立 smoke 断言使用，执行模块不拿它写答案。

成功运行：`m1-99b51ebe1ad24932b63887c36f008854`。原始证据位于 VM；宿主只读导出在交接工作区 `evidence/m1-run-2/`，最终截图 `state-17.png`、断言 `smoke_assertion.json`。首次运行因误解 elements_complete 在第 3 次调用停止，未点击按钮，失败证据保留 `m1-run-1.tar.gz`。

M1 执行模块本身不宣告任务 SUCCEEDED，阶段通过由独立 smoke_assertion 给出。此验收不等于 M3 文件验证或整个 MVP 完成。

单元测试（可在宿主执行 mocks，不控制桌面）：

```bash
python3 -m unittest discover -s tests -v
```

7 项在宿主与 VM 内均通过：越权应用/工具、预算、动作超时不重放、PID 身份失败、菜单目标拒绝、结果缺失/歧义以及 elements_complete 语义。M4 仍需完整异常验收。

## M0 隔离与恢复

原版 Lume 0.5.3 会隐式共享 lume-config 和 `/var/empty`，native viewer 会启动剪贴板桥。因此新增 opt-in `LUME_MVP_HOST_ISOLATION=1`，拒绝查看器/剪贴板/额外挂载，实际构造零目录共享设备，阻止动态共享和 VNC 配置分发。原系统安装流程含只读空目录占位，不把安装历史宣称为零共享。

最小底层例外：新增 `libs/lume/src/VM/MVPHostIsolation.swift`，局部修改 Run.swift、VM.swift、VMVirtualizationService.swift，新增 MVPHostIsolationTests.swift。仅环境开关开启时生效。不是受测 Agent 的工具策略；后续 MCP 白名单仍需单独实现。

从 `cua/libs/lume` 构建验证：

```bash
LUME_MVP_HOST_ISOLATION=1 LUME_TELEMETRY_ENABLED=false /usr/bin/arch -arm64 /usr/bin/xcrun swift test --jobs 2 --filter mvpIsolation
```

两项测试、三项实际 CLI 拒绝及启动配置均有证据：交接目录 `evidence/m0-isolation-final-test-v2.log`、`m0-isolation-final-v2.json`。二进制保存在忽略的 `.vm-tools/lume-mvp-isolated-v2`，SHA-256 `ca2f396af0c47d9569c8ccfa2595a81654f41dbcbccff49d41026c04bcb3a90f`，仅 virtualization entitlement ad-hoc 签名，未替换安装版 Lume。

VM storage 为交接工作区 `.vm`。以下名称已存在，不要覆盖：

- `mac-agent-mvp-15-6-1`：原 VM，停机。
- `mac-agent-mvp-15-6-1-installed`：安装后基线，无账户/Driver，未作为最终恢复验收。
- `mac-agent-mvp-15-6-1-configured`：系统/账户/Driver 配置基线，停机保存，不含后续 Python。
- `mac-agent-mvp-15-6-1-restored`：从 configured 克隆并恢复验证，当前开发 VM。

恢复：停机基线 clone 到未使用的新名字，`--source-storage` 和 `--dest-storage` 均为项目 `.vm`；以隔离 v2 运行 `run <新名字> --storage <项目.vm> --display none --network nat`，环境加 `LUME_MVP_HOST_ISOLATION=1 LUME_TELEMETRY_ENABLED=false`。普通账户登录后启动 Driver app daemon，再检查权限、截图、应用信息。基线恢复实测见 `m0-configured-baseline.json`、`m0-restored-verified.png`、`m0-restored-preview.png`。

`--display none` 不开实时查看器；开发 VNC 客户端只连接目标 VM，不共享宿主目录/剪贴板。CLI VNC URL 含密码，必须脱敏，不交给 Agent。账户密码各自保存于忽略的 `.vm`，权限 0600。

只读 inventory（在交接工作区根运行）：

```bash
python3 cua/samples/mac_agent_mvp/preflight.py --storage "$PWD/.vm" --vm mac-agent-mvp-15-6-1-restored
```

脚本退出 0 只表示读取成功，NOT_ASSESSED 表示不负责阶段验收。处理 Lume 前置清理日志，输出只含允许字段，不打印原始凭据。

## UFO 对照与下一步

固定 commit：`be75a7ded2ad98d97819e15ff1b39d4202ac3ac5`。

| 阶段 | 已读源码 | 借鉴及差异 |
|---|---|---|
| M0 | overview.md Three-Layer Architecture | 区分状态、流程、执行；不迁移框架，不将职责分离视作隔离 |
| M1 | dispatcher.py：BasicCommandDispatcher.execute_commands/generate_error_results、LocalCommandDispatcher.execute_commands | 调用标识、结果与异常；不引入路由/WebSocket，不采用自动重试建议 |
| M2 准备 | app_agent_processor.py：AppAgentProcessor._setup_strategies | 观察→模型→动作→记录；继续使用 SDK 循环，不增加长期记忆 |

M2 已确认使用 DeepSeek 官方 API。准备采用以下非秘密参数（尚未应用到 VM）：

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export CLAUDE_MODEL=deepseek-flash
```

本地官方示例读取 `CLAUDE_MODEL`。开发专用 API Key 只在 VM 内配置，不写入源码、聊天、命令历史或证据。具体 SDK 鉴权配置须在固定版本接入时核对。

依据：[DeepSeek Anthropic 兼容接口](https://api-docs.deepseek.com/zh-cn/guides/anthropic_api/)、[图像理解](https://api-docs.deepseek.com/zh-cn/guides/vision/)。文档支持工具调用及 Flash 图片输入，但项目固定 SDK 尚未实测；仍需验证鉴权、图片、工具调用和权限拒绝。

官方 Cua 示例整个 MCP server 允许项及 max_turns=40 不满足本项目要求，必须收窄工具并保留真实调用计数。未完成 M2 真实验收前不进入 M3。

2026-09-20：已在恢复 VM 部署临时密钥输入页（开发辅助，不是 Agent 工具或产品前端）。宿主浏览器显示该 VM 表单，密钥经本机虚拟网络 HTTP 提交到 VM，文件仅保存在 `~/.MacAgentMVPSecrets/deepseek.json`，权限 0600、排他创建，不写入聊天或宿主文件。入口限宿主网桥来源、随机路径与同源提交，保存后或 30 分钟到期后关闭；不共享剪贴板。用户必须输入新建开发凭证。页面访问和三项拒绝检查已通过，真实保存与模型鉴权尚未测试；详见根 PROGRESS 和 `evidence/m2-credential-entry-checks.json`。

后续修复：原 no-referrer 策略会与普通表单 Origin 校验冲突，已保留旧文件并部署 v2（same-origin，VM 8772）。当前用户入口改为宿主 127.0.0.1:8773 的临时固定目标转发，Host/Origin 验证仍保留；密钥仅经过转发进程内存，不记录或落盘，最终保存位置仍是 VM。内置浏览器实际无效输入提交已进入格式校验，未再出现 Forbidden；凭证真实保存及 API 鉴权仍待用户输入。新证据 m2-credential-entry-v2-checks.json，详情见根 PROGRESS。

最新：用户已完成保存。VM 元数据实测文件 0600、目录 0700、owner UID 502，状态日志 CREDENTIAL_SAVED；未读取密钥内容。VM 新入口与宿主转发已自动关闭。SDK 鉴权尚未测试，M2 仍未通过；证据 `m2-credential-saved-metadata.png`。

SDK 准备补充：已核对官方 0.2.124 源码归档及哈希，确认 tools=[]、setting_sources=[]、strict_mcp_config 的实际含义，以及 allowed_tools 会跳过 can_use_tool 的限制。安装命令误发到已自动锁屏的 VM 密码框，未实际执行；远程解锁未成功，已停止重试。当前需先在测试 VM 正常解锁，SDK 尚未安装，M2 未通过，详见 PROGRESS 最新记录。

后续状态：恢复 VM 已按原隔离配置重新启动，并通过 macOS 原生屏幕共享窗口供人工 GUI 操作；没有启用 Lume native display、目录共享或剪贴板桥。用户要求的普通测试账户密码更新及登录钥匙串同步已完成，并经锁屏后重新登录验证。本地忽略凭证记录保持 0600；密码不进入版本化文档。SDK 仍未安装，M2 仍未通过。

2026-09-21 暂停点：SDK 安装只进行到依赖元数据下载，未验证成功，随后按用户要求停止并正常关闭恢复 VM。现有 `m2-venv` 视为半成品；下次恢复时先重建，不在其上继续安装。未发出模型请求，M2 仍未通过。
