# 运行证据发布边界

原始 VM 截图、完整 trace、VNC 会话、凭证元数据和本地环境日志默认不进入公开仓库。`PROGRESS.md` 中的证据文件名记录本地验收事实，但文件只有在完成脱敏检查后才可作为 PR Artifact 或明确选择的公开样例发布。

公开证据必须移除 API Key、Authorization、密码、VNC URL、宿主绝对路径、个人账号和无关桌面内容，并保留 run_id、代码 commit、环境版本与验证结论。
