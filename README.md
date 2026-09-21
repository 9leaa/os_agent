# OS Agent

基于 [Pi](https://github.com/earendil-works/pi) 构建可直接使用的通用 Agent，再开发更强的 Computer Use。当前先在本地完成 Agent 基座；需要操作真实桌面时再进入隔离测试环境。

## 开发进度

- [x] 确定 Pi 为 Agent 基座
- [x] 精简仓库，只保留当前实现和开发文档
- [x] 保留计算器固定流程、7 项边界测试和 Lume 隔离补丁
- [ ] **A0：本地 Pi 可用**
  - [ ] 固定 Pi、Node.js 和模型版本
  - [ ] 提供项目启动命令
  - [ ] 跑通终端多轮对话
  - [ ] 限制 Agent 只能访问项目测试目录
  - [ ] 跑通文件读取、产物生成和读回验证
  - [ ] 验证图片输入和工具图片输出
- [ ] **A1：可二次开发**
  - [ ] 接入自定义工具和 Skill 示例
  - [ ] 加入日志、停止、审批和调用预算
  - [ ] 验证会话续接与上下文压缩
- [ ] **C0：最小 Computer Use**
  - [ ] 接入受控桌面观察与操作
  - [ ] 完成计算器和基础界面任务
  - [ ] 保存执行证据并独立验证
- [ ] **C1：增强 Computer Use**
  - [ ] 支持较长流程、界面变化和跨应用任务
- [ ] **C2：可靠性与评测**
  - [ ] 支持人工接管、故障恢复和固定任务集评测
- [ ] **C3：发布开发底座**
  - [ ] 第二位开发者可以独立部署并增加能力
- [ ] **O0：OS 原生能力**
  - [ ] 根据真实业务需求另行设计

详细验收条件见 [开发计划](Pi_Agent_Development_Plan.md)，实际完成情况以本清单和 [PROGRESS.md](PROGRESS.md) 为准。未真实验收的项目不得提前勾选。

## 当前代码

```text
agent/                    # Pi 接入，待 A0 创建
tools/mac_vm/             # 已有计算器流程、环境检查和测试
patches/cua/              # 已有 Lume 隔离补丁
Pi_Agent_Development_Plan.md
PROGRESS.md
```

运行现有 mock 测试：

```bash
python3 -m unittest discover -s tools/mac_vm/tests -v
```

该命令不启动 Pi、不调用模型，也不操作桌面。模型凭证、VM、系统镜像和原始桌面证据不得提交到仓库。
