# Pi Agent + Computer Use

先基于 **Pi** 交付可用的通用 Agent，再开发更强的 Computer Use（观察并操作电脑）。OS 原生能力后置；仓库沿用 mac_agent 名称，目前只具备 macOS 测试资产。

## 当前实现

**Pi 已选定，尚未安装或集成。当前没有可启动的 Pi 产品。**

| 内容 | 实际状态 |
|---|---|
| 计算器固定流程与 7 项边界测试 | 已实现；历史 VM 验收通过，无模型参与 |
| VM 只读环境检查 | 已实现，不启动或操作桌面 |
| Lume 宿主隔离补丁 | 已实现；保留 5 个文件的改动与测试 |
| Pi 通用 Agent / Computer Use | A0–C3 待实施 |
| macOS 原生能力库 | 后置，不在当前范围 |

最后记录的 VM 状态为停机，本轮未重新运行 VM。源码整理不代表新能力已实现，详见 [进度](PROGRESS.md)。

## 开始开发

```bash
git clone https://github.com/9leaa/mac_agent.git
cd mac_agent
python3 -m unittest discover -s tools/mac_vm/tests -v
```

上述测试使用 mock，不访问桌面或模型。Pi 的安装、版本锁定、隔离配置与项目启动入口由 A0 交付；现在不提供未验证的启动命令。

| 阶段 | 目标 |
|---|---|
| A0 | 可在终端使用的 Pi 通用 Agent |
| A1 | 工具扩展、日志、审批、停止与会话基线 |
| C0 | 最小 Computer Use 闭环 |
| C1 | 较长流程、跨应用与界面变化处理 |
| C2 | 故障恢复、人工接管与独立评测 |
| C3 | 可部署、可扩展的开发底座 |
| O0 | 后续 OS 原生能力，另行立项 |

详细目标与验收见 **[Pi 开发计划](Pi_Agent_Development_Plan.md)**。协作者先读 [开发规则](AGENTS.md) 和 [协作说明](COLLABORATION.md)。

## 技术分工

Pi 负责会话、上下文和 Agent 循环；项目扩展负责受控工具、停止、预算和验证；Cua Driver 负责电脑观察与操作；VM 提供隔离测试环境。Pi 接入拟用 TypeScript，当前 Python 代码保留。

首版复用 Pi 终端交互界面（TUI），不是独立桌面 App。不叠加第二套主循环，不把 Agent-S、Jev 或 LangGraph 列为必选依赖。Agent 申请结束后，仍须独立检查实际结果。

## 精简后的目录

```text
mac_agent/
├── README.md
├── Pi_Agent_Development_Plan.md
├── AGENTS.md
├── COLLABORATION.md
├── PROGRESS.md
├── vm-manifest.json
├── tools/mac_vm/               # 现有代码、测试与运行说明
└── patches/cua/                # Lume 隔离补丁、来源与上游许可证
```

Pi 新实现拟放在 agent/，尚未创建。整套 Cua 上游副本和旧方案已从当前树移除；需要构建 Lume 时，按 [补丁说明](patches/cua/README.md) 获取固定上游版本，不在此仓库重新复制上游。

受测 Agent 不操作宿主个人应用／文件，不共享宿主目录或剪贴板，不开放任意 Shell。凭证、VM 磁盘、系统镜像及原始桌面证据不进 Git。没有可靠验证时明确报告未验证。

上游：[Pi](https://github.com/earendil-works/pi)、[Cua](https://github.com/trycua/cua)。旧内容可从 Git 历史恢复，本次未重写历史。
