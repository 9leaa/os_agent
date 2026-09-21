# Pi Agent + Computer Use

基于 **Pi** 构建可直接使用、可二次开发的通用 Agent，再逐步增强 Computer Use（观察屏幕并操作电脑）。macOS 原生能力属于后续方向，不是当前产品目标。

仓库沿用 `mac_agent` 名称，不代表只面向 macOS。当前已有 macOS 测试 VM；其他系统的适配尚未实现。

## 当前状态

**Pi 已选定，但尚未安装、固定版本或完成模型与工具集成。仓库目前不是开箱即用的 Pi 产品。**

| 已有 / 待做 | 实际状态 |
|---|---|
| Pi 通用 Agent | A0 待开始；后续优先复用官方终端交互界面（TUI），不是独立桌面 App |
| Computer Use | C0–C3 待开始；尚无 Pi 驱动的桌面任务验收 |
| 现有 VM / Cua Driver | 历史 M0 已通过；作为测试基础设施复用 |
| 固定计算器流程 | 历史 M1 已通过，无模型；不是通用 Agent |
| 旧 Claude SDK 路线 | 暂停；M2 未通过，M3/M4 未完成，不再作为当前主路线 |
| macOS 原生扩展 | O0 后置，需另行定义范围 |

上述是历史记录和当前规划，不是本次重新运行的测试结果。最后记录的 VM 状态为停机；详见 [PROGRESS.md](PROGRESS.md)。

## 技术分工

| 组件 | 专业职责 | 直白解释 |
|---|---|---|
| Pi | Agent 循环、会话、上下文、TUI、扩展和 SDK | 复用能持续接任务、调用工具的 Agent |
| 项目扩展 | 受控工具、预算、停止、事件与验证 | 规定怎么接能力、哪些能做、结果是否可信 |
| Cua Driver | 桌面观察与交互 | 为 Agent 提供电脑操作工具 |
| VM | 隔离测试系统 | 在测试电脑里执行，不操作宿主个人环境 |

计划链路：

```text
用户 → Pi 终端界面 / 项目入口
             ↓
       Pi Agent 循环
             ↓
     受控工具与执行检查
       ├─ 文件 / 通用工具（A0–A1）
       └─ Computer Use → Cua Driver → 测试 VM（C0 起）
             ↓
       证据与独立结果验证
```

先通过 Pi 扩展和 SDK 接入能力，不默认 fork 或重写内核，不另套 LangGraph 或第二套 Agent 循环。Pi 接入层拟用 TypeScript，现有 Python/Cua 代码保留，通过受控适配复用。

Pi 并非自带完整沙箱；Skills 也不是权限边界。默认文件和 Bash 能力不能原样暴露给受测 Agent，执行边界见 [开发规则](AGENTS.md)。

## 开发路线

| 阶段 | 阶段目标 | 用户可见结果 |
|---|---|---|
| A0 | Pi 通用 Agent 可用 | 在终端完成对话、文件理解和产物生成 |
| A1 | 建立二开基线 | 可接新工具，能停止、审批、记录与恢复会话 |
| C0 | 最小 Computer Use | 根据真实观察完成简单桌面任务 |
| C1 | 更强 Computer Use | 处理较长任务、弹窗与跨应用流程 |
| C2 | 可靠性与评测 | 人工接管、故障恢复、独立验证和可重复测试 |
| C3 | 发布开发底座 | 其他开发者能部署、复现并增加能力 |
| O0 | 后续 OS 原生能力 | 按真实需求另立计划，不阻塞前述阶段 |

阶段交付、通过条件、分工和首批任务见 **[Pi 开发计划书](Pi_Agent_Development_Plan.md)**。Agent-S、Jev、多 Agent、长期记忆平台和独立 GUI 均不是当前必选依赖。

## 开始参与开发

```bash
git clone https://github.com/9leaa/mac_agent.git
cd mac_agent
python3 -m unittest discover -s cua/samples/mac_agent_mvp/tests -v
```

最后一条只运行现有计算器适配的 mock 单元测试，不启动 VM、不调用模型，也不证明 Pi 已可用。

阅读顺序：本 README → [阶段计划](Pi_Agent_Development_Plan.md) → [AGENTS.md](AGENTS.md) → [PROGRESS.md](PROGRESS.md) → [协作与 VM 调试](COLLABORATION.md)。

当前没有项目级 Pi 安装／启动脚本。A0 将核对并锁定 Pi、Node.js、模型和依赖后提供可复现命令，不把上游最新版安装命令当作本项目已验证入口。开发凭证仅在隔离测试环境配置，不复用个人登录，不提交 Git。

## 仓库结构

这是单个发布仓库，`cua/` 是固定源码快照，不是需要再次 clone 的空目录或 submodule。

```text
mac_agent/
├── README.md
├── Pi_Agent_Development_Plan.md  # 当前唯一主计划
├── AGENTS.md                    # 开发和安全约束
├── PROGRESS.md                  # 实际进度与历史记录
├── COLLABORATION.md             # GitHub / VM 协作
├── vm-manifest.json             # 历史测试环境声明
├── evidence/README.md           # 证据发布边界
└── cua/                        # 上游快照及已有计算器样例
```

后续 Pi 接入拟放在根目录 `agent/`，回归集拟放在 `tests/`；这两个目录尚未创建。现有 `cua/samples/mac_agent_mvp/` 保留为后端诊断和计算器回归，不承担整个新产品的目录结构。

VM 磁盘、系统镜像、密钥、登录密码、会话凭证和原始桌面截图不上传 GitHub。上游代码保留原许可证与来源。

## 历史资料与上游

- [原计算器计划 v0.1](Mac_OS_Agent_MVP_Plan_v0.1.md)：保留验收用例，不再规定当前运行时。
- [旧整体设计 v0.2](Mac_OS_Agent_Design_v0.2.md)、[旧联合开发计划 v0.2](Mac_OS_Agent_Collaboration_Plan_v0.2.md)、[原交接记录](CODEX_HANDOFF.md)：历史参考，已被 Pi 路线替代。
- [现有样例说明](cua/samples/mac_agent_mvp/README.md)：历史环境、固定测试和恢复步骤；其中旧 SDK 下一步不作为当前任务。
- [Pi 官方项目](https://github.com/earendil-works/pi)、[SDK 文档](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/sdk.md)、[Cua](https://github.com/trycua/cua)：实施时以锁定版本的源码和实测为准。
