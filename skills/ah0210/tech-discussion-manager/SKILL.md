---
name: tech-discussion-manager
description: 技术讨论管理技能，自动创建结构化的讨论记录、代码输出目录，沉淀技术决策和创意，支持多智能体协同使用。
metadata:
  {
    "openclaw":
      {
        "requires": { "bins": [] },
        "install":
          [
            {
              "id": "setup-directories",
              "kind": "shell",
              "script": "mkdir -p $OPENCLAW_WORKSPACE/memory/tech-discussions/archive $OPENCLAW_WORKSPACE/code-output $OPENCLAW_WORKSPACE/docs/decisions $OPENCLAW_WORKSPACE/docs/architecture",
              "label": "创建标准目录结构",
            },
            {
              "id": "install-templates",
              "kind": "shell",
              "script": "cp -n ./templates/*.md $OPENCLAW_WORKSPACE/memory/tech-discussions/",
              "label": "安装模板文件",
            },
            {
              "id": "update-agents-config",
              "kind": "shell",
              "script": "grep -q '技术讨论沉淀规则' \"$OPENCLAW_WORKSPACE/AGENTS.md\" || printf '\\n### 💬 技术讨论沉淀规则\\n1. 所有技术讨论必须使用 tech-discussion-manager 技能管理\\n2. 讨论记录使用标准模板保存到 memory/tech-discussions/ 目录\\n3. 代码产出必须保存到 code-output/ 对应主题目录\\n4. 重要决策必须同步到 MEMORY.md 和 docs/decisions/ 目录\\n5. 讨论结束后必须更新 memory/tech-discussions/index.md 索引\\n' >> \"$OPENCLAW_WORKSPACE/AGENTS.md\"",
              "label": "更新智能体规则系统",
            },
          ],
      },
  }
---

# tech-discussion-manager 技能

## 功能概述
自动管理技术讨论和创意沉淀的标准化技能，帮助智能体自动创建规范的目录结构、讨论记录模板，确保技术知识完整留存。

## 核心功能
- 📝 标准化技术讨论记录模板
- 📂 自动创建关联代码输出目录
- 🔄 自动维护讨论索引
- 📦 讨论归档机制
- 🤝 多智能体协同支持

## 智能体使用规范
当用户发起技术讨论时，智能体必须按照以下流程执行：

### 1. 讨论启动流程
当用户提到以下关键词时，自动触发技能：
- "我们讨论一下..."
- "技术方案评审"
- "需求评审"
- "架构设计讨论"
- "创意 brainstorm"
- "记录一下这个讨论"

自动执行以下操作：
```markdown
我已经帮你创建了技术讨论记录：
📝 讨论文件：`memory/tech-discussions/YYYY-MM-DD-主题.md`
📂 代码目录：`code-output/[主题]/`

我们可以开始讨论了，我会实时记录要点和决策。
```

### 2. 讨论记录格式
必须按照以下结构记录：
```markdown
## 讨论背景
[自动填充讨论背景]

## 讨论要点
- [ ] 要点1：xxx
- [ ] 要点2：xxx

## 决策结论
- 结论1：xxx，原因：xxx
- 结论2：xxx，原因：xxx

## 待办事项
- [ ] 任务1：xxx，负责人：xxx，截止时间：xxx
```

### 3. 讨论结束流程
当用户表示讨论结束时，自动执行：
1. 整理讨论内容，提炼核心结论
2. 更新讨论状态为"已完成"
3. 将重要结论同步到 `MEMORY.md`
4. 如需归档，移动到 `archive/` 目录
5. 更新 `index.md` 索引

### 4. 目录结构规范
```
$OPENCLAW_WORKSPACE/
├── memory/
│   └── tech-discussions/
│       ├── archive/                # 归档历史讨论
│       ├── TEMPLATE.md             # 讨论模板
│       └── index.md                # 讨论索引
├── code-output/                    # 代码输出目录
│   └── [讨论主题]/                  # 每个讨论对应独立代码目录
└── docs/
    ├── decisions/                  # 正式决策文档
    └── architecture/               # 架构设计文档
```

## 记忆系统集成
技能安装后会自动将规则写入 `AGENTS.md`，成为智能体的永久行为准则：
- 所有技术讨论必须使用本技能管理
- 禁止私自在其他位置记录技术讨论
- 所有讨论必须结构化留存，便于后续检索

## ClawHub 发布说明
本技能符合ClawHub标准规范，可以直接发布到clawhub.com：
```bash
# 登录ClawHub
clawhub login

# 发布技能
clawhub publish tech-discussion-manager --version 1.0.0
```

## 用户使用示例
```
用户：我们讨论一下GEO工具的架构设计
智能体：✅ 已创建技术讨论记录：
📝 讨论文件：memory/tech-discussions/2026-03-29-geo工具架构设计.md
📂 代码目录：code-output/geo工具架构设计/
请开始讨论，我会实时记录要点。
```
