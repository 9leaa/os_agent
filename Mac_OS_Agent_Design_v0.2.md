# Mac OS Agent 整体设计方案 v0.2

> 历史参考（2026-09-21 更新）：当前主路线已改为 **Pi 通用 Agent → Computer Use → 后续 OS 原生能力**。请先读 [Pi 开发计划](Pi_Agent_Development_Plan.md) 和 [当前进度](PROGRESS.md)。下文保留原始设计／交接语境；旧 SDK 选型、阶段顺序和启动指令不再是当前开发指令。计算器与隔离验收要求继续作为回归参考。

日期：2026-09-21。状态：联合开发评审草案，描述目标架构，不表示功能已经实现。
阅读顺序：本设计 → [开发计划书](Mac_OS_Agent_Collaboration_Plan_v0.2.md) → [实际进度](PROGRESS.md)。

## 1. 产品目标

做一个在 macOS VM 内工作的、可扩展的单 Agent。用户提出任务，Agent 理解上下文、调用工具、操作应用、生成产物，并说明结果是否经过验证。后续业务功能通过增加工具、任务模板和校验器接入这个基础 Agent。

专业解释：复用现成 Agent runtime，组合桌面执行、受限工具、会话管理与独立验证，形成可二次开发的应用底座。
直白解释：先用别人做好的“大脑和工作循环”，接好这台测试 Mac 的“手脚”，以后给它增加新技能。

基础版的完整体验示例：用户让 Agent 从测试网页读取两项数字，在计算器中完成指定运算，把结果和来源保存到任务目录；随后追问结果，或中途停止并人工接管。这是第二阶段的目标场景，第一阶段先完成计算器任务闭环。

计算器继续作为可核验的入门和回归用例，产品能力逐步扩展到受控文件、浏览器与多步骤任务。

## 2. 先选现成 Agent 框架，再确定接入方式

专业上分三类：完整 Agent 应用、可嵌入的 Agent runtime/harness，以及底层流程编排框架。直白说，分别是“可直接改造的成品”“装进自己产品的发动机”和“需要自己接线的流程积木”。Cua Driver 属于桌面工具层，不能替代其中的推理与会话运行时。

### 当前候选比较

以下是 2026-09-21 官方资料核对与本项目适配判断；尚未在项目 VM 上逐个安装或性能对比。

| 候选 | 已有机制 | 对本项目的适配成本 | 本轮判断 |
|---|---|---|---|
| [OpenCode](https://opencode.ai/docs/) | 完整 Agent、TUI/Web 界面、会话、工具、Skills、MCP、Server/SDK；有 DeepSeek provider | 面向编码的默认工具与模式需收窄；验证截图传递、取消、权限和 GUI 任务表现 | 优先验证，最贴近“先复用现成 Agent 和常用功能” |
| [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) | 现成循环、会话、工具、hooks；支持 Python/TS 嵌入 | 与已有 Python/Cua 示例最接近；产品交互要自己接，DeepSeek 固定组合待实测 | 原路线保留为主要对照/备选 |
| [Pi](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/README.md) | 精简可嵌入运行时、会话、TUI、扩展、SDK/RPC | 核心没有原生 MCP 和审批弹窗，需自己接扩展及边界 | 适合深改内核，当前会增加接入工作 |
| [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) | 较完整的可编程 harness、模型适配、上下文和工具机制 | 要裁剪默认文件/子 Agent 等能力，接自己的交互和桌面验证；planning 默认值随版本变化 | 强调 Python 可编程控制时的候选 |
| [LangGraph](https://docs.langchain.com/oss/python/langgraph/overview) | 状态图、持久执行、流式输出、人工介入 | 仍需组装 Agent 与产品体验 | 暂不作为第一版独立起点；出现复杂持久工作流再评估 |
| [OpenClaw](https://docs.openclaw.ai/) | 完整助手、Gateway、Web Control UI、会话及插件 | 需要处理平台配置和插件边界；大量渠道能力当前不用 | 目标转为常驻、多渠道个人助手时更适合 |

Cua 自带的 [ComputerAgent](cua/libs/python/agent/cua_agent/agent.py) 也有现成循环；本项目尚未验证其桌面后端、会话和交互是否比上述路线省工作。UFO 继续作为执行与评估设计参考。第一轮仅对 OpenCode 与现有 Claude Agent SDK 路线做同一组探针，避免同时建设多套系统。

### 推荐路线

建议优先验证 OpenCode + 受限 MCP 工具服务 + Cua Driver + Lume VM。这是联合开发阶段的新选型建议，尚未替换旧计划的 Python/Claude SDK 运行时。

理由来自现成功能：OpenCode 已有 [Web 会话界面](https://opencode.ai/docs/web/)、[Server/SDK 接口](https://opencode.ai/docs/sdk/)、[DeepSeek provider](https://opencode.ai/docs/providers/#deepseek) 和 [MCP 接入](https://opencode.ai/docs/mcp-servers/)；Cua 官方的 [客户端接入说明](https://cua.ai/docs/how-to-guides/driver/connect-your-agent) 也列出了 OpenCode，并要求通过 MCP 保留截图的 image blocks。对“先有能用的成品，再做 OS 能力扩展”的目标，预计能减少会话与界面的自建工作。这是适配判断，不是已测结论。

先把 OpenCode 当版本锁定的上游依赖，用配置、MCP、工具和 Server API 扩展。第一版不 fork 并重写它的核心；现有 Python 执行策略、测试和校验器可经 MCP 接入，不要求全部改成 TypeScript。

| 组成 | 专业职责 | 直白解释 | 实现归属 |
|---|---|---|---|
| 模型 | 理解任务、选择下一步 | 决定做什么 | 优先验证已选 DeepSeek |
| Agent 运行时 | 循环、上下文、会话、交互 | 连续干活并记住对话 | 优先 OpenCode，Claude Agent SDK 作对照 |
| 项目受限 MCP 服务 | 工具契约、目标校验、调用计数 | 决定每一步能不能做 | 复用 Python，新增薄接入层 |
| Cua Driver | 截图、辅助功能信息、桌面交互 | 看屏幕、点按钮 | 复用现有 Driver |
| Lume VM | 独立测试系统 | Agent 的测试 Mac | 延续已验证的项目隔离构建 |
| 业务包与验证器 | 任务定义、产物和结果校验 | 增加新任务并判断是否做完 | 团队重点开发 |

OpenCode 的 [权限默认值](https://opencode.ai/docs/permissions/) 较宽；我们必须显式拒绝无关内置工具、Shell、子 Agent、额外 MCP 和范围外文件/网络访问。默认编码 Agent、模式切换、插件、配置覆盖都纳入验收。模型只看见项目批准的能力，参数和资源边界仍由执行端检查，不能把设置了 permission 就当作隔离完成。

### 选型验收关卡

两条候选在同一 VM 基线、同一模型下验证：文本与图片 → 工具调用及工具图片返回 → 多轮续问/恢复 → 取消与停止派发 → 执行前拒绝越权 → 接入一个项目工具。必须能保留原始图片内容，不能将图片只转换成文件路径文本。

文档支持 DeepSeek 或 MCP 只是进入测试的条件。DeepSeek 官方已说明 deepseek-flash 支持 [图片和 Anthropic 兼容格式](https://api-docs.deepseek.com/guides/vision/)，但特定 Agent 的模型能力声明、消息转换和取消行为仍需实测。

通过全部关键关卡后，再按需要新增的代码量、现成界面可复用程度和团队维护成本选定一条。OpenCode 若不能可靠限制执行或图片链路不通，就回到 Claude Agent SDK 对照路线；两者都失败时记录阻塞和最小复现，不宣告底座已可用。

旧 Cua 示例锁定 claude-agent-sdk==0.2.124，现有 Driver 安装记录为 0.28.2；OpenCode 尚未选择项目固定版本。选型报告必须补充实际版本、运行组件、模型和策略，而不能混用滚动文档与旧二进制。

## 3. 整体结构

下图中执行组件全部位于 VM。优先复用选定框架的 TUI/Web 界面，项目只补充必要的任务状态和验证结果展示。

~~~mermaid
flowchart TD
    U[任务入口：现成 TUI / Web UI] --> S[会话与任务管理]
    S --> A[现成 Agent 运行时]
    A --> P[受限工具与执行检查]
    P --> D[Cua Driver]
    P --> F[任务目录文件工具]
    P --> B[受控网页工具]
    D --> O[macOS 应用]
    O --> A
    F --> A
    B --> A
    P --> E[调用日志和新状态证据]
    A -->|申请结束| V[独立校验器]
    E --> V
    V --> R[结果 / 产物 / 验证状态]
    R --> U
    U --> H[停止 / 人工接管]
    H --> S
~~~

Agent 运行时负责决定和继续；执行端在动作前检查权限；验证器判断是否满足任务。运行日志和产物引用通过统一事件格式显示给用户。若采用 OpenCode，其服务与项目 Python MCP 服务是两个本地进程；不再叠加 LangGraph 或另一套 Agent 循环。复用上游自己的会话存储，项目不额外建设通用数据库平台。

## 4. 基础版要具备的功能

| 功能 | 用户能做什么 | 实现边界 |
|---|---|---|
| 自然语言任务 | 用中文提出目标 | 复用框架推理与工具循环 |
| 多轮对话 | 追问、补充条件、继续上一次讨论 | 复用会话能力；区分会话与单次任务 |
| 多步骤执行 | 观察 → 操作 → 检查 → 继续 | 依据最新状态决策，展示简短进度而非内部思维链 |
| 桌面操作 | 操作允许的应用及窗口 | 从计算器扩到逐个验收的测试应用 |
| 文件产物 | 读取输入、保存文本/JSON、列出输出 | 仅本次 VM 任务目录；路径和覆盖规则在执行端校验 |
| 浏览器 | 读页面、提取信息、操作测试表单 | 先用 VM 内测试页面，再逐项开放允许的公开只读页面 |
| 工具 / MCP 扩展 | 加入一个新的业务能力 | 由项目显式注册和限权；不动态安装任意服务 |
| 任务模板 / Skills | 重复执行固定业务流程 | 版本化的任务说明、工具需求和校验规则；模板不授予权限 |
| 状态和反馈 | 看进度、错误、产物和已验证结果 | 使用框架事件及项目执行日志 |
| 停止与人工接管 | 停止自动操作，自己操作 VM | 先停派发、处理在途动作，再交出桌面控制权 |
| 继续与恢复 | 恢复对话，继续未完成任务 | 恢复后重新观察；会话恢复不等于桌面或文件回滚 |
| 运行约束 | 防止无限循环或越权执行 | 保留每任务 30 次工具上限，另记录耗时和可获得的用量 |

第一版优先直接使用框架现成的任务/对话入口，以及已有原生 VM 查看方式。第二版接好任务输入、消息与进度、停止/继续、产物列表，优先补齐现成界面的项目字段。若选 Claude Agent SDK 才按需做轻量界面。Agent 聊天界面与 VM 远程桌面是两个入口，共用同一任务控制状态。

明确后置：长期记忆、RAG/知识库、定时自主任务、多 Agent、个人账号、邮件和购买、插件市场、任意 Shell、通用 API/GUI 智能路由。短期会话上下文属于基础版。

## 5. 一次任务怎样执行和验证

1. 建立 run_id，确定任务输入、允许工具、目标应用、文件目录与验收条件；同时关联 session_id。
2. Agent 运行时接收任务与已允许的工具说明，根据观察选择动作。
3. 每次执行前检查工具名、参数、窗口身份、路径/URL和预算；通过后记录调用，再交给对应工具。
4. 保存结果与新的界面状态，反馈给 Agent 运行时。可能已经生效的动作若超时，标记结果未知，先观察后判断。
5. Agent 运行时申请结束后，独立验证器检查实际产物与证据，生成最终结果；模型的“完成了”只代表结束申请。
6. 返回简短结果、产物位置、验证结论和未完成原因。

计算器任务沿用旧计划：操作轨迹、新界面显示、文件读回和独立期望值同时一致才通过。网页任务检查测试服务状态或提取字段，文件任务检查内容与路径；每类任务有自己的校验器。没有可靠校验器的开放任务只能报告已完成的观察与动作，并标记结果未验证。

任务控制状态拟使用 RUNNING、WAITING_INPUT、PAUSED、FINISHED、CANCELLED；验证结论单独使用 PASSED、FAILED、BLOCKED、UNVERIFIED。旧计算器接口继续按原约定输出 SUCCEEDED 等状态，通过适配映射保持回归兼容；不因界面显示“结束”就变成成功。新增状态是设计，尚未实施。

每次运行至少记录输入摘要、版本、策略、工具调用、最后观察、产物与验证报告。session_id 管对话，run_id 管一次实际执行；恢复同一任务不能重置预算。同一 VM 的桌面只允许一个执行者持有控制权。

停止请求先阻止新工具派发。在途动作可能已经发生，不能承诺撤回；未确认结果的动作留下 UNKNOWN。人工接管后再次交给 Agent 时，重新确认窗口和当前状态，不能继续使用旧坐标。

30 次计数包含观察、失败调用、重试，以及包装工具实际产生的底层工具请求；不以 SDK turn 数代替。验证所需的新 Driver 观察也占用额度，需提前预留；耗尽后仅对已有证据离线检查。

## 6. 二次开发放在哪里

继续在 cua/samples/mac_agent_mvp/ 内迭代；先收口当前入口，形成稳定底座后再按真实重复需求拆模块。保留已验证的 driver_smoke.py 作为诊断入口，不直接把固定按钮流程当作通用 Agent。

预期逻辑模块为 runtime、tools、policy、workspace、verification、tasks、ui 和 tests。它们首先是职责划分，不要求第一天建齐全部目录。

未来一个业务模块需要提供以下内容：

| 扩展项 | 内容 |
|---|---|
| 任务说明 | 输入、输出、业务目标、完成条件 |
| 能力声明 | 允许的应用、工具、路径、URL及预算 |
| 可选工具适配 | 接应用 API、现成 MCP 或受限 GUI 操作 |
| 校验器 | 如何从真实状态和产物判断完成 |
| 任务用例 | 至少一个正常用例和一个失败/越权用例 |

模型和 Agent 运行时通过很薄的项目入口适配，只有出现第二个真实实现时再抽象共用接口。业务扩展优先新增任务配置和适配工具，避免修改 框架主循环。

第一批工具都是内置、受审查的项目代码。MCP 只是通信协议，Skills 是工作说明；二者都不自动提供安全隔离。通过 GUI、文件工具、网页工具访问同一资源时，必须受到一致的执行权限约束。

## 7. 部署与多人调试

GitHub 保存代码、设计、锁定版本、测试输入与脱敏报告。每位开发者使用自己的代码副本；有合适 Mac 的开发者使用自己的 VM。只有一台测试 Mac 时，远程开发者连接该测试机并预约使用独立 VM 克隆。

本机历史环境为 16 GiB 内存、VM 8 GiB；先按单 VM 串行调试安排，是否并行需重新测资源。普通开发测试不依赖 GUI，真实 GUI 验收在 Apple Silicon 测试机完成。

Agent、Driver 和任务文件在 VM 内；宿主负责 VM 生命周期和人工查看。基线保持停机且不含模型凭证；每人配置自己的开发凭证。当前恢复副本已存有凭证，不能直接当成共享镜像。

公共仓库的 CI 运行无凭证检查。真实 VM 测试先采用维护者检查 PR 代码后手动触发的方式；外部 PR 不自动接触测试机或凭证。原始截图和日志留在受控存储，公开 GitHub Artifact 不能默认当作私密证据存储。

详细协作约定见 [COLLABORATION.md](COLLABORATION.md)。本设计不启动 VM、不安装组件，也不启用新工具权限。

## 8. 已有事实与后续范围

截至本次文档核对：PROGRESS 记录 M0 环境和 M1 固定计算器流程通过；仓库确有 preflight.py、driver_smoke.py 和对应测试。尚未提供本项目模型 Agent 入口、完整文件验证或常用功能界面。最后的运行记录为 VM 停机；本轮没有重跑 VM 验收。

旧 [v0.1 计划](Mac_OS_Agent_MVP_Plan_v0.1.md) 保留为计算器验收子计划。v0.2 是整体路线草案；进入新的应用、网页或界面阶段时，相应实施 PR 必须同步更新 AGENTS.md 的功能范围和执行策略，避免旧规则和新功能冲突。宿主隔离、凭证边界和真实验证要求继续保留。

## 9. 依据与版本边界

- 项目检查基点：GitHub main d9278a22c13c34dffcf6958ad293f50610364821；Cua 上游快照基点 9bbfa7dd3e27ca7f1861ede70aaca390174493f9。
- [OpenCode 官方说明](https://opencode.ai/docs/)、[MCP](https://opencode.ai/docs/mcp-servers/)、[SDK](https://opencode.ai/docs/sdk/)、[权限](https://opencode.ai/docs/permissions/)：优先候选的现成能力与待收紧默认值。
- [Cua 官方 SDK 接入](https://cua.ai/docs/how-to-guides/driver/use-claude-agent-sdk)：现成示例及 native/MCP 两种接法；本项目优先沿用 MCP 路线。
- [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview)、[会话说明](https://code.claude.com/docs/en/agent-sdk/sessions)：循环与会话能力；功能仍按最终锁定版本验证。
- [DeepSeek 图片输入](https://api-docs.deepseek.com/guides/vision/)、[Claude Code 接入](https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code/)：支持能力不等于本项目固定组合已通过。
- [Cua ComputerAgent 源码](cua/libs/python/agent/cua_agent/agent.py)、[OpenClaw 的 Lume 部署指引](https://cua.ai/docs/how-to-guides/lume/run-openclaw)：替代候选，未在本项目验收。
- [UFO 固定参考](https://github.com/microsoft/UFO/tree/be75a7ded2ad98d97819e15ff1b39d4202ac3ac5)：执行、状态和评估职责的参考，不作为运行依赖。

上述官方资料核对于 2026-09-21。方案与工期属于项目建议，不是上游功能承诺。
