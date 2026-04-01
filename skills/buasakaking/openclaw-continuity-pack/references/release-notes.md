# Release Notes

## OpenClaw Continuity Pack v0.3.1

这是一次只针对 continuity 运行时稳定性的热修复，不新增能力。

### 本次修复

1. 修复 `totalTokens` 缺失时的 rollover 误判  
   现在 `thread-rollover` 在评估上下文压力时，会优先使用 `totalTokens`，但当它缺失时，会回退读取：
   - `inputTokens`
   - `outputTokens`
   - `inputTokens + outputTokens`

2. 修复的直接症状  
   某些长线程已经真实进入 successor session，但当前 active successor 的 `totalTokens = null`，旧逻辑会误判为“不需要继续 rollover”，最终把超重会话拖到 provider timeout。

3. live 复验结果  
   已在 disposable live thread 上复验通过：
   - 前台仍是同一个 thread
   - backend 真创建 successor 并切换 active session
   - successor transcript 中存在 hidden handoff
   - 用户可见历史中没有 hidden handoff
   - 即使人为制造 `totalTokens = null`、只保留超大的 `inputTokens/outputTokens`，rollover 仍能继续触发

### 对使用者的影响

- 这次 hotfix 与模型供应商无关，属于 continuity / rollover 运行时逻辑修复
- 如果你的 OpenClaw 也会出现“旧 thread 越聊越重，最后超时，但 successor 不继续切”的情况，这个版本就是针对该问题的


## OpenClaw Continuity Pack v0.3.0

这是一轮把 **live 已验收通过的 silent continuity / rollover 行为** 回灌进分发包的同步发布。重点不是新增一整套新产品线，而是让 ClawHub 上的 skill 与当前真正跑通的 live 行为重新对齐。

### 这次收口重点

1. **普通聊天页不再显示 continuity/context 两类提示**  
   前台 UX 改成静默准备，避免在用户界面里暴露“上下文紧张”“即将 compact”之类的提示条。

2. **运行时阈值更新为 80 / 85 / 88 / 90 策略**  
   - 80%：静默 durability refresh  
   - 85%：`compact_prepare` / successor preparation  
   - 88%：若预测下一轮会冲到 90%+，提前准备切换  
   - 90%：`rollover_required`

3. **workspace continuity 规则不再靠 visible compression tactics 控制上下文**  
   `AGENTS.md` 与 `SESSION_CONTINUITY.md` 已同步为“静默准备、不中断回答质量”的版本，移除了 `shorten prose` / `compact user update` / `convergence mode` 这类旧表述。

4. **source-side 对齐测试一起纳入 pack**  
   `thread-rollover.test.ts` 已与最新运行时语义对齐，方便后续在匹配源码树里复验。

### live 验收对齐结果

已对齐到以下 live 结果：
- visible thread 保持不变
- successor rollover 真实发生
- successor transcript 内存在 hidden handoff
- 用户可见历史里看不到 hidden handoff
- `noticeSeen = false`
- `compactPrepareHintSeen = false`
- `contextUsedHintSeen = false`
- rollover 附近的复杂回复仍保持完整质量，不再走“先降智后切”的策略

## OpenClaw Continuity Pack v0.2.1

这是一轮基于真实安装复验的安装体验硬化。重点不是增加新能力，而是让现有能力更容易装对、装稳、装到正确 workspace。

### 这次收口重点

1. 统一安装入口  
   现在优先使用 `scripts/install_continuity_pack.py`，而不是让安装者自己拼多条 bootstrap / patch 命令。

2. 自动识别 workspace  
   `bootstrap_workspace.py` 现在支持 `--workspace auto`，会优先从当前 workspace 语境或常见路径解析目标 workspace。

3. 首次安装心理预期更清楚  
   文档已明确说明 ClawHub 可能出现的静态安全提示，以及为什么这个 skill 会触发该提示。

## OpenClaw Continuity Pack v0.2.0

这是一份面向分发的 continuity / rollover 复用包，目标是把以下能力从单机验证成果整理成别人可部署、可复查、可回滚的发布形态：

- 热层 continuity 闭环
- thread continuity
- successor rollover
- hidden handoff
- continuity notice
- token 缺失 / successor 创建失败 / handoff 注入失败时的诚实降级

## 这次发布重点

1. 规则/模板层收成真正的 skill 入口  
   普通用户可以直接用脚本 scaffold workspace，或只安装 continuity 规则层。

2. 源码补丁层补齐正式安装脚本  
   愿意自己编译部署的人，可以直接做 patch check / apply / rebuild，而不是只靠手工命令。

3. 去现场化、去个人化  
   包里不包含：
   - 真实 memory / plans / status / handoff 实例
   - 真实 token / key / channel / logs
   - 真实路径、用户名、会话名
   - 验收脚本、临时故障注入代码、`.bak_*`

## 已知限制

- 这不是“无限上下文”
- 这是“前台同一对话、后台自动续接”的 continuity 方案
- 最终效果仍受 OpenClaw 版本、安装方式、provider 封装和 UI/runtime 结构影响
