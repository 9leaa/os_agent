# 多人开发与 VM 调试

## 基本原则

- GitHub 保存代码、规则、版本清单和脱敏验证结果，不保存 VM、凭证或原始桌面证据。
- 不允许两名开发者同时写同一 VM 磁盘。每名开发者或每个 PR 从同一停机基线创建独立克隆。
- 没有 Apple Silicon Mac 的开发者运行单元测试和 mock；真实 macOS GUI 验收由专用 Apple Silicon 测试机串行执行。
- 远程人工调试只连接专用测试 Mac，再进入独立 VM；不要把 VNC 端口直接暴露到公网。

## PR 流程

1. 从 `main` 建立短分支，修改 `cua/samples/mac_agent_mvp/` 或明确的底层文件。
2. 本地运行最小单元测试并更新 `PROGRESS.md`；mock、真实 VM 和未运行必须明确区分。
3. 提交 PR。专用测试机从停机基线创建新的临时 VM 克隆，注入该 PR 代码和一次性开发凭证。
4. 在临时 VM 内执行真实 GUI 测试，导出脱敏 `trace.jsonl`、验证报告和必要截图作为受限 CI Artifact。
5. 测试结束后关闭并删除临时 VM；基线保持停机且不含 API Key。

## 版本与证据

- `vm-manifest.json` 是环境声明，不替代真实运行证据。
- 每次真实运行记录 Cua commit、VM 基线版本、Driver/Python/SDK 版本、run_id 和验证状态。
- GitHub 只放经检查的轻量证据；包含用户路径、凭证、VNC URL、个人账号或无关桌面的文件不得上传。

## 当前基线边界

现有本地 configured 基线包含 macOS、普通测试账户和 Driver 权限，不含 Python/SDK/模型凭证。它目前只是本机基线，尚未形成可分发镜像。创建共享基线前必须验证导出/导入、许可证、哈希、恢复步骤和凭证清理。
