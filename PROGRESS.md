# 开发进度

更新时间：2026-09-20

## 当前状态

最新状态：M0 实际验收通过；M1 实际验收通过；M2 准备中，DeepSeek 官方 API 凭证已由用户保存到 VM，文件权限实测正确，SDK 接入与鉴权待完成；M3–M4 未开始。恢复副本已安装 Python 3.12.14；凭证已保存不等于模型可用或 M2 通过。

| 阶段 | 当前状态 | 实际证据 | 下一步 |
|---|---|---|---|
| M0 | 已通过 | m0-configured-baseline.json、m0-restored-verified.png、m0-restored-preview.png | 保留停机基线 |
| M1 | 已通过 | m1-run-2/smoke_assertion.json、trace.jsonl、state-17.png | 保留固定流程与证据 |
| M2 | 准备中 | 已读 _setup_strategies 与官方 SDK 示例；VM 凭证文件及权限已验证 | 完成 SDK 鉴权和受限工具接入实测 |
| M3–M4 | 未开始 | 无 | 前序验收后推进 |

以下为历史记录；以本节和末尾本轮结果为准。

## 接手时需要实际检查的内容

工作区/仓库、分支和未提交改动；当前宿主或来宾环境；芯片、系统、资源；VM 是否存在；Driver 与 SDK 版本；可用模型配置。只记录凭据是否配置，不记录值。

## 后续每轮更新模板

### 日期 / 阶段

- 当前状态：未开始 / 进行中 / 阻塞 / 实际验收通过。
- 已读 UFO：源码路径、commit、类/函数，借鉴内容与未采用部分。
- 修改文件：实际路径及作用。
- 测试：真实命令、运行环境、退出状态、证据位置；明确未运行和跳过项。
- 测试性质：单元测试 / mock / 真实 macOS VM 集成验收，不能混写。
- 安全检查：操作是否全部在 VM 内、是否涉及越权或新增授权。
- 阻塞与人工步骤：准确描述，不用假数据代替。
- 下一步：下一项可执行任务。

仅文档或 mock 测试通过不能把 M0–M4 的真实 VM 验收状态改成通过。

## 2026-09-20 / M0 / 镜像准备

- 本轮范围：用户授权代为下载镜像；不创建或启动 VM。此前只读阶段没有修改工作区。
- 文件：工作区原先仅有无提交的 `.git`；从交接 ZIP 排他创建四份文档，未覆盖已有文件。新增 `.gitignore` 排除 `/downloads/`，新增 README 和下载元数据。
- 实测宿主：Apple M4、16 GiB RAM、macOS 15.6 (24G84)、下载前约 78 GiB 空闲；当前进程经 Rosetta，硬件支持 ARM64 和虚拟化。Git 2.50.1、Python 3.9.6。
- Lume：`~/.local/bin/lume`，版本 0.5.3；`lume ls` 返回无 VM。`--version`、`ls`、`create --help`、`run --help`、`ipsw` 均退出 0。
- 已读 UFO：commit `be75a7ded2ad98d97819e15ff1b39d4202ac3ac5`，`documents/docs/infrastructure/agents/overview.md` 的 Three-Layer Architecture、Layer Responsibilities 和 State/Strategy/Command 段落。借鉴职责分离；不引入完整类体系、多设备、记忆或服务架构，不将分层视为 VM 隔离。
- 镜像：`lume ipsw` 实际返回 Apple macOS 15.6.1 (24G90)，不是 Tahoe 示例。HEAD HTTP 200，Content-Length 为 16814137790 字节，约 15.66 GiB。
- 下载路径：`downloads/macos-15.6.1-24G90/`；排他创建新目录和 `.partial`，逐块计算 SHA-256，保留至少 15 GiB 空闲。仅在大小及 Apple HTTP 元数据提供的哈希一致时生成 `.ipsw`。来源、哈希及最终状态见该目录 `download.json`。
- 测试性质：真实宿主检查和网络下载，不是 VM 集成验收。没有计算器操作、VM 截图或应用信息；M0 未通过，M1–M4 未开始。
- 隔离待确认：Lume 0.5.3 帮助指出 native viewer 自动同步剪贴板；后续不能默认启动，需核对替代显示方式及客户端剪贴板设置。不共享宿主目录，不默认关闭 SIP。
- 待完成：镜像校验、Cua commit 及关联源码核对、VM 磁盘及基线空间预算、VM 内权限配置。Driver/SDK/模型尚未配置。
- 开发记录：一次用 Python 更新中文文档的命令发生编码 SyntaxError，未写入文件；改用补丁工具更新文档。
- 下载等待期间的只读源码核对：`git ls-remote` 确认 Cua HEAD 为 `9bbfa7dd3e27ca7f1861ede70aaca390174493f9`，按此固定 SHA 读取根 `AGENTS.md`、根 `README.md`、`libs/cua-driver/examples/agent-sdks/README.md`、`claude_agent.py`、`native_tools.py`。未 clone 或执行示例；此 SHA 是已读参考版本，不是已安装 Driver 版本。
- 示例核对结果：入口存在；Claude MCP 示例禁用内置工具，但允许整个 `mcp__cua_driver` 服务器，且 `max_turns=40`。这些不是本项目的计算器白名单或 30 次实际调用限制，后续不能原样用于受测 Agent。native 适配器使用桌面目标，发生异常后再观察，也不能直接视为计算器窗口权限保证。配套 README 使用 Python 3.12，VM 内依赖版本待后续确定。

### 本轮最终结果

- 下载成功，进程退出 0，耗时 1275.5 秒（约 21 分钟）；结束时间 2026-09-20 07:07:49 UTC。
- 实际大小 16814137790 字节；SHA-256：`3d87686b691ac765eb6a6b3082b2334e2af9710096a00432dd519af89ff2ea78`，与 Apple HTTP 元数据一致。
- ZIP 内 `BuildManifest.plist` 可读，ProductVersion=15.6.1、ProductBuildVersion=24G90，支持列表含 VirtualMac2,1；这是包内检查，不是实际启动验证。
- 下载后磁盘空闲约 61.71 GiB；创建 VM 和干净基线前仍需预算，不能把稀疏磁盘的标称容量当作实际可用空间。
- 证据：`evidence/m0-download.json` 保留小型记录进入项目；大镜像和下载侧记录位于被 Git 忽略的 `downloads/macos-15.6.1-24G90/`。
- 检查通过：三个未更新的交接文档与 ZIP 字节一致；下载目录被 Git 忽略；`git diff --check` 无报错（当前文件均未跟踪，未把该命令当作代码测试）。没有创建提交或推送。
- 阻塞/未完成：尚无 VM，隔离、SIP、Driver 权限、截图、应用信息及恢复基线均未验收。M0 未通过，不进入 M1。

## 2026-09-20 / M0 / VM 创建与隔离适配

- Cua 已独立 clone 到 `cua/`，本地分支 `codex/mac-agent-mvp`，基点 `9bbfa7dd3e27ca7f1861ede70aaca390174493f9`。上游 AGENTS.md、许可证、既有文件未覆盖；无远程 Fork、提交或推送。
- UFO 继续使用已读固定 commit 的 Three-Layer Architecture，借鉴状态/流程/执行职责分离，不引入其他阶段代码。
- 已安装 Lume 0.5.3；对应源码 tag `lume-v0.5.3` 指向 `754eec754991e1760100621e9bfe7ec1395cc7db`。核对 Create/Run/Clone、DarwinVM、VM、VMVirtualizationService、Home 与安装脚本。
- 发现真实隔离问题：0.5.3 的 run 自动共享只读 `lume-config`；Darwin 配置默认共享宿主 `/var/empty` 占位目录；native viewer 默认启动 SSH 剪贴板桥。CLI `sharedDirectories=null` 不能证明没有隐式共享。原版安装流程也含该只读空目录占位，未暴露宿主工作区或个人目录；不把原版安装过程写成零共享。
- VM 创建：`mac-agent-mvp-15-6-1`，4 核、8 GiB、40 GiB、NAT，Apple 15.6.1 (24G90) 本地 IPSW，无 unattended。创建退出 0，初始实际磁盘约 18.46 GiB，位置 `.vm/`。证据 `m0-create-command.json`、`m0-create-result.json`、`m0-create.log`、`m0-post-install.json`。
- 已做关机克隆 `mac-agent-mvp-15-6-1-installed`，仅为安装后基线。克隆会改变 MAC 与 machineIdentifier，NVRAM 一致、逻辑磁盘大小一致；尚未做恢复启动验收。首次假定整个 config 字节相同的检查失败，已按实际差异记录在 `m0-baseline.json`，没有伪报一致。
- 因原版无法满足零共享，最小底层例外：新增 `MVPHostIsolation.swift`，修改 Run、VM、VMVirtualizationService，仅在开发启动进程设置 `LUME_MVP_HOST_ISOLATION=1` 时生效。拒绝查看器/剪贴板/外加宿主挂载，去掉隐式共享设备，禁止运行时共享和 native attach；关闭 VNC 配置向来宾的自动 SSH 写入。受测 Agent 不获得这个管理入口。
- 新增 `samples/mac_agent_mvp/preflight.py` 与 README：只读宿主/VM 状态，不启动 VM，不输出密码和机器身份字段。运行退出 0，仅为环境检查，明确 M0 未通过。
- ARM64 构建：Swift 6.2，项目内 `swift test --jobs 2 --filter mvpIsolation`，隔离环境开关开启；两项测试通过，最终日志 `m0-isolation-final-test.log`。真实 CLI 拒绝 native、clipboard、shared-dir 三种请求，见 `m0-isolation-checks.json`。上游 swift-testing 有弃用警告，未做无关修改。
- 单独签名项目测试二进制（仅 virtualization entitlement），放在 `.vm-tools/lume-mvp-isolated`，未替换已安装 Lume。当前实际运行记录见 `m0-isolated-boot.log`，配置校验 `directorySharingDevices=0`；截图来自目标 VM 的 loopback VNC，不是宿主截图。
- 开发侧 `.vm-tools` 安装 vncdotool 1.4.2；初次 Python 3.9 依赖解析尝试从源码构建 cryptography 并因 SOCKS 构建依赖失败，改成仅二进制 wheel、cryptography<46 后成功。没有改宿主代理配置或全局 Python。
- 初次设置使用独立 `mvpadmin` 账户，密码仅存 `.vm/development-credentials.json`（0600，父目录 0700，被 Git 忽略），未使用个人账户。账户创建及标准 Agent 用户最终状态待后续验证，不能将初始化管理员直接用于受测 Agent。
- VNC 设置过程中已观察到快速键入/快捷键映射不可靠；操作后重新截图，未提交错误字段。根据上游 VNCService 的实际映射调整按键。所有这些是开发侧 VM 设置操作，不是 M1 计算器或 M2 Agent 验收。

### 本轮来宾初始化与当前阻塞

- VM 已完成 Setup Assistant，未登录 Apple Account；关闭定位、分析共享和 Siri，跳过 Screen Time。时区暂保留系统默认 Pacific，后续应在证据中使用 UTC。系统更新选择仅自动下载，未主动升级系统。
- 来宾实际 `sw_vers` 为 macOS 15.6.1 / 24G90，`csrutil status` 为 enabled，`mount -t virtiofs` 无挂载输出。证据 `evidence/m0-guest-system-confirmed.png`。第一次 VNC 输入把下划线映射成减号，`sw-vers` 失败；修正 Shift 字符处理后重新核对成功，未伪报首次成功。
- Driver 固定官方 release `cua-driver-rs-v0.28.2`，release 元数据见 `evidence/m0-driver-release.json`。来宾直接从 GitHub 下载 70078129 字节包；SHA-256 `e273181b26709c88b1d809474deb3c592b4efae3530b11d76318f1887fc3fbb1` 校验 OK。先检查目标不存在，再将官方 CuaDriver.app 安装到来宾 `/Applications/`；`--version` 实际输出 `cua-driver 0.28.2`。证据 `m0-driver-installed.png`。没有在宿主安装或运行 Driver。
- 普通账号 `mvpagent` 通过来宾 `sudo sysadminctl -addUser ... -password -` 创建；独立随机密码仅保存在忽略的 `.vm/agent-login.json`（0600），通过隐藏提示输入。命令目前停在 Terminal 系统管理权限弹窗，只观察到 UID/GID 分配，尚未确认完成或可登录。没有免密 sudo、没有全盘访问、没有修改 TCC 数据库。已请求用户授权这项仅限 VM 的权限；不换接口绕过。
- 最终隔离二进制 `.vm-tools/lume-mvp-isolated` SHA-256 为 `e922b8203c54fa79fe59429358cd518fd5d45a983d8b553d29ca52ec8c65a5e8`；其三项真实 CLI 拒绝测试再次全部通过，证据 `m0-isolation-final-cli.json`。
- 版本边界：当前 VM 启动于稍早的同一隔离补丁构建，运行时确认零共享设备；当时计划额外去掉对未共享临时目录的 VNC 配置写入。后续重启发现该判断尚未加在实际写入分支；已实际补齐并重新构建为 v2，下节记录其独立证据，不能用此旧构建冒充最终结果。
- M0 尚缺：完成普通账号、Driver 必要权限及应用信息、最终构建重启证据、配置完成后的停机基线与恢复启动测试。当前克隆只是系统安装后基线。权限弹窗待确认期间保留 VM 运行；不进入 M1，不执行计算器运算。
- 人工下一步：确认是否允许这台 VM 的 Terminal 系统管理权限。随后继续建立标准用户并打开 Driver 的权限页，录屏/辅助功能按计划在 VM 内人工配置。管理员密码保留在开发侧，不交给受测 Agent。

### 用户授权后的继续结果

- 用户明确允许“仅限这台测试虚拟机”的 Terminal 管理权限；已在该 VM 确认，普通 `mvpagent` 账户创建完成。`id`、`dseditgroup -o checkmember ... admin`、`sudo -l -U mvpagent` 实测非 admin 且不允许 sudo。管理员 sudo 缓存已清除。证据 `m0-standard-user-check.png`。
- 普通账户首次图形登录成功并完成设置，未登录个人 Apple Account，未开启 Siri/Screen Time。证据 `m0-standard-terminal.png`（终端用户名为 mvpagent）。
- v2 实际修正 `VM.swift` 的 VNC URL/config 写入分支。重新编译两项测试通过，ad-hoc 签名项目二进制 `.vm-tools/lume-mvp-isolated-v2`，SHA-256 `ca2f396af0c47d9569c8ccfa2595a81654f41dbcbccff49d41026c04bcb3a90f`。三项拒绝测试退出 1，均匹配项目隔离错误。
- 通过来宾菜单正常关机，再以 v2 启动成功，实际 `directorySharingDevices=0`、clipboard bridge disabled，启动日志不再出现 VNC config 写入。证据 `m0-isolation-final-v2.json`、`m0-final-isolated-boot-v2.log`、`m0-isolation-final-test-v2.log`。启动时仅有本项目 VM；没有启用宿主查看器或共享。
- 已读取 Driver 的 permissions status/grant 实现：status 只信任 Driver daemon 自身 TCC 归属，无 daemon 时应报告 unknown；grant 通过 CuaDriver app 身份请求系统授权，不能把 Terminal 权限当作 Driver 权限。正在普通账户中启动官方权限流程，尚未授予录屏/辅助功能。
- 文件：更新根 README、PROGRESS；新增/修改 sample README、preflight；三个既有 Lume 文件局部修改，新增隔离 helper 与测试，新增 evidence；上游规则/许可证和原交接方案未改。`git -C cua diff --check` 与 preflight 语法检查通过。无提交、推送或远程 Fork。

### 当前停点

- 普通账户中的 `cua-driver permissions grant` 已真实启动，并打开来宾“Screen & System Audio Recording”设置页；截图 `evidence/m0-driver-permissions-current.png` 当前显示 No Items，不能当作权限已获得。已另行请求用户允许仅 VM 内 CuaDriver 的辅助功能与录屏权限，尚未收到这两项授权。不会把 Terminal 管理权限视作 Driver 授权，也不修改 TCC 数据库。
- 当前 VM 保持运行在此设置页；最终隔离构建为 v2。权限流程有超时，后续先观察现状，不能盲目重发带副作用动作。授权后按系统设置配置，再实际检查 Driver 自身权限、截图与应用信息，建立并恢复验证新基线；M0 完成前不进入 M1。
- 收尾核验：上游 `AGENTS.md`、`LICENSE.md` 与基点逐字节一致；根 AGENTS、HANDOFF、计划与 ZIP 一致。第一次误用 `LICENSE` 路径检查失败，定位实际 `LICENSE.md` 后通过。23 份文本记录未发现本轮生成的两份账户密码，凭据及 VM/工具目录均被忽略；截图只包含 VM。证据 `m0-final-file-checks.json`。
- 剩余磁盘约 26.27 GiB（时点检查）；后续基线/构建前重新预算，不默认下载更多系统镜像。代码清单与哈希 `m0-source-manifest.json`，只读最终环境输出 `m0-preflight-final.json`。

### 2026-09-20 / M0 / Driver 权限与真实观察

- 用户授权继续 VM 内 Driver 权限配置。通过目标 VM 系统设置完成辅助功能、录屏及直接捕获确认；没有修改宿主权限、TCC 数据库或授予普通用户 sudo。
- `permissions grant` 成功；`permissions status` 来源为 driver-daemon，直接捕获标注历史观察，没有将它当作新的截图。证据 `m0-permissions-checked.png`。
- VM 内 `list_apps` 返回真实应用数据，保存 `/Users/mvpagent/M0Evidence/apps.json`。`get_desktop_state` 保存同目录 `desktop.png` 与 `capture.json`；sips 实测 1920×1440，在 VM Preview 打开确认有效桌面图像。证据 `m0-driver-apps.png`、`m0-driver-capture-result.png`、`m0-driver-capture-preview.png`。这是开发环境验证，不是 M1 或 Agent 运算验收。
- 一次窗口焦点错误导致导航到 Energy，确认 Terminal 焦点后修正；一次管理员输入未成功，修正 Shift 字符映射后正常解锁，没有绕过权限。文档更新首次因 stdin 编码失败，未写入；加编码声明后重试。
- VM 使用 `--display none` 后台运行，因此没有实时桌面窗口；对话展示的是 VNC 截图。未启用共享剪贴板的原生查看器。
- 本轮更新 PROGRESS、根 README、sample README，新增截图与忽略目录内开发辅助命令。UFO 仍沿用 M0 已读固定版本三层职责参考，未进入 M1，无提交或推送。
- M0 未通过：最终配置基线与恢复启动尚未验收；Python/SDK/模型尚未配置。下一步建立并恢复验证基线，再读取 M1 Dispatcher 源码、实现固定计算器操作。

### M0 / 配置基线恢复验证（进行中）

- 原 VM 通过来宾菜单正常关机，preflight 实测 stopped。空闲约 27 GiB，采用同卷 APFS 克隆，创建 `mac-agent-mvp-15-6-1-configured`，再从此基线创建 `mac-agent-mvp-15-6-1-restored`，两次 clone 均退出 0，未覆盖原 VM。基线未启动。
- 恢复副本用隔离 v2 二进制启动，日志确认零共享、剪贴板桥关闭，普通用户登录验证中。一次会话中断后 VM 进程消失、VNC 拒绝连接，不能视为通过；核实已停机后重新启动，保留两份日志。
- preflight 在旧进程退出时遇到 Lume 输出混合日志而 JSON 解析失败；未将失败输出作为环境结果。证据 `m0-configured-baseline.json`、`m0-configured-clone.log`、`m0-restored-clone.log`、`m0-restored-boot-retry.log`。M0 仍未通过，后续需确认恢复后的账户和 Driver。

### M0 最终恢复验收

- 恢复副本普通账户登录成功，非 admin；macOS 15.6.1/24G90，SIP enabled，无 VirtioFS 挂载。Driver 不自启，首次观察明确失败；通过 `open -n -g -a CuaDriver --args serve` 启动 app daemon 后，权限保留，`list_apps` 与 `get_desktop_state` 均退出 0。新截图在 VM Preview 打开确认有效，路径 `/Users/mvpagent/M0Evidence/restored-2.png`。
- M0 验收通过；恢复步骤为停机配置基线 clone 到未使用的新名字，再用隔离 v2 二进制启动，普通账户登录后启动 Driver daemon。当前工作 VM 为 `mac-agent-mvp-15-6-1-restored`；原 VM 和 `-configured` 基线均保留停机。此基线含系统/账户/Driver，不含后续 Python/SDK/模型。
- 修正只读 preflight 对 Lume 清理旧 session 时前置日志的 JSON 解析，仍不输出原始凭据。修复后真实 inventory 退出 0，见 `m0-restored-preflight.json`；其中 NOT_PASSED 是脚本不负责验收的旧固定字段，后续改为 NOT_ASSESSED 防止误读。

### M1 / 固定流程实现及准备

- 完整读取 UFO 固定 commit `be75a7ded2ad98d97819e15ff1b39d4202ac3ac5` 的 `ufo/module/dispatcher.py`，重点 BasicCommandDispatcher.execute_commands/generate_error_results、LocalCommandDispatcher.execute_commands。借鉴调用标识、统一结果和异常封装；不复制类、不引入路由/WebSocket，不采用错误提示中的自动重试建议。源码哈希及对照见 `m1-ufo-reference.json`。
- VM 普通账户用户目录安装 Python 3.12.14（Astral standalone 20260901 ARM64），24981445 bytes，SHA-256 实际 OK；不使用 sudo、不更改宿主 Python。证据 `m1-python-package.json`、`m1-python-install-current.png`。M0 配置基线仍保持此前状态，Python 仅新增到恢复副本。
- 新增 `driver_smoke.py` 和 `tests/test_driver_smoke.py`：无模型固定 12×34，启动计算器、核验 PID 原生执行路径与窗口，按新快照选择限定 AXButton；拒绝其他工具/应用，最多 30 次 Driver 调用，先记录 DISPATCHED，再记录响应/失败/UNKNOWN；动作超时只观察、不重放。显示值来自窗口内 AXStaticText，不来自模型计算。测试期望值只在独立 smoke assertion 中使用，尚不实现 M3 文件验证。
- 六项宿主单元测试通过；真实 VM 集成运行中，不能将单元测试视为阶段通过。开发探针确认 Driver 的结构化 elements 不含显示值，tree_markdown 中有 AXStaticText；因此按实测格式严格提取唯一整数，缺失或歧义则 UNVERIFIED。
- 为传递代码，只在宿主 VM 网桥地址临时提供一个明确的打包文件，限制请求来源为恢复 VM IP；不提供目录浏览、挂载或剪贴板。VM 下载后校验 SHA-256 再解包。开发证据读取服务仅限 VM 的新建 M1Probe 目录，收尾停用。

### M1 最终真实验收结果

- 首次运行 `m1-01f9a2a1906640ea9e42387c65996f7d` 在第 3 次调用停止，UNVERIFIED，无按钮动作；我错误地要求 `elements_complete=true`。核对固定 Cua 源码 get_window_state.rs 发现该字段有意固定 false，仅表示无法证明列出全部元素。改为核对正向窗口身份、snapshot_id、截图有效性，以及具体目标按钮/显示证据；并新增回归测试，不将缺失元素当作“不存在”的证明。失败证据完整保留 `m1-run-1.tar.gz`。
- v2 源码包校验通过，在恢复 VM 内执行 `~/MVPRuntime/python/bin/python3 tests/test_driver_smoke.py --live`。run_id=`m1-99b51ebe1ad24932b63887c36f008854`，17 次实际 Driver 工具调用、17 个唯一 call_id，耗时 19311 ms。动作序列 All Clear、1、2、Multiply、3、4、Equals，新 AX 显示 12×34 与 408，最终 PNG 同样显示 408。
- 独立 smoke assertion passed=true；M1 实际通过。执行模块自身仍标 UNVERIFIED，表示它不替独立程序宣告任务成功；独立 M1 验收结论见 smoke_assertion.json。尚无 result.txt、M2 模型执行或 M3/M4 完整校验，不能宣称 MVP 全部完成。
- 原始证据保存在 VM `~/AgentWorkspace/<run_id>/`；只读导出副本 `evidence/m1-run-2/`、完整包 `m1-run-2.tar.gz`。最终截图已人工检查；宿主 7 项单元测试与 VM 内同样 7 项均通过。见 m1-unit-tests-v2.log、m1-unit-vm.log。语法与 git diff --check 通过，上游 AGENTS/许可证未变。
- 两个宿主单文件分发服务和 VM 临时证据 HTTP 服务均已停止；VM 与 Driver daemon 保留运行。普通账户无 sudo，未控制宿主应用或个人文件。

### M2 接入准备 / 当前阻塞

- 用户选择已有兼容代理，已请求 Base URL、模型名和 Anthropic Messages API 支持情况；尚未收到具体信息，不猜测代理、不读取个人凭据。密钥须在 VM 内配置，不发聊天。
- 已读取 UFO 固定 commit 的 AppAgentProcessor._setup_strategies：DATA_COLLECTION（截图+控件）、LLM_INTERACTION、ACTION_EXECUTION、MEMORY_UPDATE。只借鉴一次处理的顺序，后续用 SDK 循环和本地记录；不搬 ProcessorTemplate、Strategy 类或长期记忆。M2 尚未编码/实测。
- 重新读取固定 Cua 的 claude_agent.py 和 requirements.txt：上游锁定 claude-agent-sdk==0.2.124。PyPI 最新另为 0.2.157，仅核对存在，不据此擅自升级；后续优先沿用示例锁定版本。整个 MCP server 允许项和 max_turns=40 仍不能满足本项目限权/预算，后续必须收窄。
- 下一步：确认代理协议和 VM 内限额凭证，完成 SDK 与受限 MCP 接入并真实测试；M2 未通过前不进入 M3。

### 2026-09-20 / M2 / 官方 DeepSeek 接入确认

- 用户确认使用 DeepSeek 官方 API，取代此前待定的兼容代理。按已核对的官方 Anthropic 兼容文档准备 `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`，拟用支持图片输入的 `deepseek-flash`；沿用 Cua 与固定 Claude Agent SDK，不变更底座。
- 本轮重读 M2 UFO `_setup_strategies`，沿用观察、决策、执行、记录的顺序，不引入记忆框架。
- 修改：PROGRESS.md、根 README.md、sample README.md，仅同步接入选择及未完成事项；同时修正进度首页仍称 Python 未安装的旧状态。
- 验证：只读核对本地示例使用 `CLAUDE_MODEL` 指定模型；未配置密钥、安装 SDK、发送付费请求或运行新的 VM 测试。官方接口兼容不等于项目固定 SDK 已通过集成验收。
- 阻塞与下一步：开发专用凭证只在 VM 内输入，随后验证 SDK 鉴权、图片与工具调用，再完成受限计算器 Agent；M2 仍未通过，M3/M4 未开始。

### 2026-09-20 / M2 / 用户密钥输入入口

- 用户授权准备输入入口；未使用此前发到聊天中的密钥。恢复 VM 从锁屏唤醒并以既有测试账户登录；没有控制宿主应用。
- 新增忽略目录 `.vm-tools/credential-entry/guest_entry.py` 及部署/检查辅助文件，部署到 VM `~/M2CredentialEntry/`。这是临时开发配置工具，不是 MVP Web 前端或受测 Agent 工具。UFO 仍沿用已读固定版本 `_setup_strategies`，本轮不新增架构借鉴。
- 输入页在 VM `192.168.64.3:8771` 服务，仅接受宿主虚拟网桥来源 `192.168.64.1`、随机入口和同源表单提交；无外部资源、请求内容日志或剪贴板桥。用户在宿主浏览器显示的 VM 表单中隐藏输入，通过本机虚拟网络 HTTP 直达来宾，不经过聊天或宿主落盘脚本；不是加密 HTTPS，也不是实时桌面查看器。
- 保存目标仅 VM `~/.MacAgentMVPSecrets/deepseek.json`，目录 0700，文件排他创建 0600，拒绝覆盖；不提供读取密钥接口。保存成功或 30 分钟到期后退出。此文件后续仅由 VM 内运行程序加载，不暴露为模型文件工具。
- 部署首次 shasum 输入行因 shell 合并空格而失败，服务未启动；改为引用完整校验行后，VM 实际 SHA-256 校验 OK。证据 `m2-entry-setup.png`、`m2-entry-start.png`。单文件分发服务 8770 已停止。
- 实际检查：开发脚本语法通过；VM 页面 200、错误路径 403、跨站提交 403、空密钥 400，见 `evidence/m2-credential-entry-checks.json`。没有提交有效密钥，未测试真实保存或 API 鉴权，不将入口可用当作 M2 验收。
- 修改 PROGRESS.md、sample README；下一步由用户在入口填写重新创建的 Key，再核验仅文件存在/权限和 SDK 接入，不读取密钥到聊天。M2 仍准备中。

### 2026-09-20 / M2 / 输入页 Forbidden 修复

- 用户提交后出现 Forbidden；VM 只读文件存在检查显示 KEY_ABSENT，status.log 仅 ENTRY_READY，未读取密钥内容。此前四项 HTTP 检查遗漏真实浏览器表单流程，不能说明用户可成功提交。
- 发现原输入页 `Referrer-Policy: no-referrer` 与严格 Origin 校验冲突；普通表单在该策略下可发送 Origin:null，依据 https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Referrer-Policy 。原请求未记录来源头，因此不声称已捕获用户那次请求头。新建 guest_entry_v2.py 将策略改为 same-origin，保留严格 Origin、Host、来源 IP、路径及排他写入校验；旧脚本未覆盖，新 VM 端口 8772。
- browser skill 的本地 classic-level 原生依赖加载失败，按失败路径使用已提供的 CUA 浏览器工具；工具导航 VM 地址另报 ERR_ADDRESS_UNREACHABLE，而宿主 HTTP 检查可达。新增 `.vm-tools/credential-entry/loopback_entry.py`，只监听 127.0.0.1:8773，只转发固定入口到 VM 8772，先验证本地 Host/Origin，再转换成 VM 同源头；不允许任意目标或路径，不记录或落盘请求体。密钥经过宿主转发进程内存，不进入聊天或宿主文件；最终文件仍只在 VM。保存后或 25 分钟后退出，VM 服务仍为 30 分钟上限。
- 实际验证：新 VM 页面 200，错误路径/跨站提交 403，空密钥 400，响应 same-origin，证据 m2-credential-entry-v2-checks.json。内置浏览器实际打开回环入口并提交明确无效的测试字符串，页面返回 Invalid key format，不再 Forbidden；未提交有效密钥、未创建凭证。回到空白表单并留给用户。
- 修改：上述两个开发脚本、检查脚本、PROGRESS.md、sample README；证据 m2-entry-save-state.png、m2-entry-v2-start.png。本轮没有 API 请求或 M2 Agent 验收；下一步等待用户在新入口重新填写，后续仅核验文件权限/状态并推进 SDK 接入。

### 2026-09-20 / M2 / 凭证保存核验

- 用户报告页面保存成功。VM 内仅 lstat 文件元数据和读取不含凭证的状态日志：文件为普通文件，权限 0600，owner UID 502，目录 0700；日志 CREDENTIAL_SAVED。未读取、显示或复制 API Key 内容。证据 `m2-credential-saved-metadata.png`。
- VM 新入口 8772 与宿主回环转发 8773 已自动关闭。核对旧进程完整命令与预期一致后停止旧入口 8771；最终三个端口均关闭，证据 `m2-entry-old-stopped.png`、`m2-credential-entry-closed.json`。
- 本轮修改 PROGRESS、两份 README 与开发侧核验辅助命令；未修改 Agent 执行代码。UFO 仍沿用已读 M2 固定版本 `_setup_strategies`，不新增框架。
- 凭证保存阻塞已解除，但尚未验证 Key 是否有效、账户余额或固定 SDK 兼容性；没有模型请求、计费测试或新的计算器任务。下一步安装并接入固定 SDK，先验证鉴权，再验证受限工具调用；M2 尚未通过。

### 2026-09-20 / M2 / SDK 源码核对与锁屏阻塞

- 重读固定 Cua claude_agent.py/requirements.txt、UFO `_setup_strategies`，以及 Driver YAML policy 与 MCP 启动权限测试。核对 PyPI 0.2.124 官方源码包，SHA-256 `ea2207d55f81b6773d5be8928e1c5e1206f49ee402cafd5eb1cc09d389dd4bae` 校验通过，源码仅解包到忽略目录 `.vm-tools/sdk-0.2.124-source/`。
- 已读 SDK ClaudeAgentOptions、权限回调说明和 subprocess transport：tools=[] 禁用内置工具；setting_sources=[] 禁止加载文件系统设置；strict_mcp_config 限制 MCP 来源；allowed_tools 自动批准会跳过 can_use_tool，因此执行端不能只依赖该回调。暂未实现 M2 Agent 入口。
- 一次宿主下载大 wheel 的读取长期未结束，已中止并改用官方小型源码归档核对。未安装宿主 SDK。
- 实际失误：未先检查恢复 VM 当前画面，就发送了 venv/pip 安装命令。截图确认 VM 已自动锁屏，命令进入密码框，没有执行安装。后续清理输入时一次使用不支持的 backspace 名称报错，改为已核对的 bsp；远程键盘解锁仍失败，最终停止重试，不修改账户密码或绕过登录。
- 证据：m2-sdk-install-start.png、m2-unlock-final.png。当前仍在测试账户锁屏；不能声称 SDK 已安装、API 已连接或 M2 通过。此前已保存的 API 凭证未读取或改动。
- 本轮修改：PROGRESS.md、sample README，以及忽略目录内下载/源码核对/安装准备文件。阻塞：需用户在测试 VM 内手动正常解锁；解锁后先观察桌面，再安装独立 venv 中的固定 SDK并执行最小鉴权探针。

### 2026-09-20 / M2 / 原生 GUI 接管与测试账户密码更新

- 确认恢复 VM 当时已停机并清理陈旧会话后，以隔离 v2、`--display none --network nat` 重新启动；运行日志再次确认零目录共享、剪贴板桥关闭。使用 `lume attach --display vnc` 打开 macOS 原生屏幕共享窗口，未启用 Lume native display 或 SSH 剪贴板同步。
- 按用户明确要求，仅将普通测试账户 `mvpagent` 的登录密码改为用户指定值；管理员密码、自动登录、sudo 和宿主设置均未修改。同步更新该账户登录钥匙串密码，避免下次登录出现旧钥匙串密码提示。
- 已锁屏并使用新密码重新登录成功；本地忽略文件 `.vm/agent-login.json` 同步更新且权限保持 0600。密码本身不写入版本化文档或证据文本。
- 证据：`password-change-result.png`、`keychain-password-result.png`、`password-change-verified-login.png`。此操作只解除人工 GUI 登录阻塞，不代表 SDK 已安装、鉴权通过或 M2 验收完成。

### 2026-09-21 / M2 / 暂停安装并停机

- 用户要求暂停当前开发并转入多人协作设计。固定 SDK 安装曾在 VM 内启动，但长时间停留在依赖元数据下载阶段，没有出现成功退出或版本验证；未发送 DeepSeek 请求。
- 已停止继续操作并通过来宾系统菜单正常关机；只读 preflight 最终报告恢复 VM 状态为 `stopped`。临时防锁屏进程随关机终止。
- `~/MVPRuntime/m2-venv` 可能是部分创建状态，后续不得当作已安装环境；恢复 M2 时应删除并重建该专用 venv，再做版本和导入验证。API 凭证文件未读取、未复制到宿主或 Git。

### 2026-09-21 / 多人协作仓库发布

- 采用一个 Git 仓库、内外两层目录：根目录保存协作规则、计划和进度，`cua/` 保存固定源码快照及 `samples/mac_agent_mvp/` 实现。公开仓库为 `https://github.com/9leaa/mac_agent`。
- 发布内容不含 `.vm/`、`.vm-tools/`、`downloads/`、API Key、登录密码和原始运行证据；`evidence/` 仅发布边界说明。VM 继续在各开发者或专用测试机上按 `vm-manifest.json` 独立重建/克隆，不共享正在写入的 VM 磁盘。
- 发布前重新通过 7 项 Python 单元测试与 2 项 Lume 隔离测试；真实 VM 当前保持停机。M2 SDK 安装与模型鉴权仍未完成，不将源码发布视为 MVP 验收。
