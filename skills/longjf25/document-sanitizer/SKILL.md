---
name: document-sanitizer
description: >
  Batch desensitize docx/xlsx files via keyword and regex rules, with one-click reversible restoration.
  批量对 docx/xlsx 文件执行关键字和正则脱敏替换，支持一键反向恢复。
description_en: "Batch sanitize docx/xlsx documents with keyword & regex rules; reversible one-click restore"
description_zh: "批量对 docx/xlsx 文件执行关键字/正则脱敏，支持一键反向恢复"
version: 1.2.0
---

# Document Sanitizer / 文档脱敏及恢复

> **Document Security Tool** — Batch replace sensitive text in docx/xlsx files, record mappings, and restore on demand.
>
> **文档安全处理工具** —— 对工作区中的 docx/xlsx 文件批量执行关键字替换（脱敏），完整记录映射关系，支持可逆恢复。

```
Define Rules → Batch Sanitize → Record Mappings → Restore on Demand
定义规则 → 批量脱敏 → 记录映射 → 按需恢复
```

---

## Prerequisites / 工具依赖

| Tool | Install / 安装命令 | Purpose / 用途 |
|------|-------------------|----------------|
| python-docx | `pip install python-docx` | Word document read/write / Word 文档读写 |
| openpyxl | `pip install openpyxl` | Excel document read/write / Excel 文档读写 |

> Ensure dependencies before first use / 首次使用前需确保：`pip install python-docx openpyxl`

---

## Trigger Scenarios / 触发场景

| Scenario / 场景 | Trigger Words / 触发词 |
|-----------------|----------------------|
| Sanitize / 脱敏 | 「脱敏文档」「文档脱敏」「sanitize documents」「关键字替换」「敏感信息处理」 |
| Restore / 恢复 | 「恢复文档」「恢复脱敏」「还原文档」「撤销脱敏」「restore documents」 |
| Config / 配置 | 「生成脱敏配置」「脱敏配置模板」「新建脱敏规则」「generate sanitize config」 |

---

## Configuration / 配置文件格式

Desensitization rules are defined in `_sanitize_config.json` at the workspace root.
脱敏规则通过工作区根目录下的 `_sanitize_config.json` 定义。

```json
{
  "exact_rules": [
    {"pattern": "张三", "replacement": ""},
    {"pattern": "某某公司", "replacement": "[Company A]"}
  ],
  "regex_rules": [
    {"pattern": "1[3-9]\\d{9}", "replacement": "", "label": "手机号/Phone"},
    {"pattern": "\\d{6}(?:19|20)\\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\\d|3[01])\\d{3}[\\dXx]", "replacement": "", "label": "身份证号/ID Card"},
    {"pattern": "[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}", "replacement": "", "label": "邮箱/Email"}
  ]
}
```

### Field Description / 字段说明

| Field / 字段 | Type / 类型 | Description / 说明 |
|-------------|------------|-------------------|
| `pattern` | string | Exact keyword / 精确匹配的关键字, or regex / 或正则表达式 |
| `replacement` | string | Replacement text / 替换内容。Leave empty for auto-generated placeholder / 留空则自动生成占位符（如 `[RED_0001]`） |
| `label` | string | Regex label only / 仅限正则规则。Used for readable placeholders / 用于生成易读的占位符 |

### Auto Placeholder Rules / 自动占位符规则

- **Exact match / 精确匹配**: Empty replacement → `[RED_0001]`, `[RED_0002]`... (global incremental / 全局递增序号)
- **Regex match / 正则匹配**: Empty replacement → `[RED_手机号_1]`, `[RED_邮箱_2]`... (with label / 带 label 标签)

---

## Three Modes / 三种工作模式

```
config    → Generate config template / 生成配置模板（首次使用 / first use）
sanitize  → Execute sanitization / 执行脱敏（read config → replace → output to _sanitized_output/）
restore   → Execute restoration / 执行恢复（read record → reverse replace → output to _restored_output/）
```

---

## Workflow 1: Generate Config / 工作流一：生成配置模板

When user says 「生成脱敏配置」/ "generate sanitize config", execute / 当用户说时执行：

```bash
python scripts/sanitize.py config <workspace>
```

Steps / 执行步骤：
1. Generate `_sanitize_config.json` at workspace root / 在工作区根目录生成配置模板
2. Prompt user to edit the config, add actual keywords and regex rules / 提醒用户编辑配置文件

---

## Workflow 2: Execute Sanitization / 工作流二：执行脱敏

When user says 「脱敏文档」/ "sanitize documents", execute / 当用户说时执行：

```bash
# Sanitize entire workspace / 脱敏整个工作区
python scripts/sanitize.py sanitize <workspace>

# Sanitize a specific subdirectory / 脱敏指定子目录
python scripts/sanitize.py sanitize <workspace> --target <subdir>

# Sanitize with filename replacement / 包含文件名脱敏
python scripts/sanitize.py sanitize <workspace> --target <subdir> --rename
```

Steps / 执行步骤：
1. Check if `_sanitize_config.json` exists / 检查配置文件是否存在
2. Read and parse config / 读取并解析配置
3. Scan docx/xlsx files in target directory (skip `_sanitized_output/`, `_restored_output/`, `_文档_md/`, etc.) / 扫描目标目录中的文档
4. Copy files to `_sanitized_output/` (preserve directory structure) / 复制到输出目录（保持目录结构）
5. Execute text replacement on copies / 对副本执行替换：
   - **docx**: Paragraphs, table cells, headers/footers, textboxes / 段落、表格、页眉页脚、文本框
   - **xlsx**: All worksheet cells / 所有工作表单元格
6. Generate timestamped record file `_sanitize_record_YYYYMMDD_HHMMSS.json` / 生成脱敏记录文件
7. Output log to `_sanitize_log.txt` / 输出操作日志
8. Report results / 汇报结果

### Directory Structure / 目录结构示例

```
workspace/                          工作文件夹/
├── _sanitize_config.json           ← User-maintained rules / 用户维护的脱敏规则
├── _sanitized_output/              ← Sanitized files / 脱敏后的文件
│   ├── subfolder/
│   │   └── document.docx
│   └── ...
├── _sanitize_record_20260329_121500.json ← Mapping record / 映射记录（用于恢复）
└── _sanitize_log.txt               ← Operation log / 操作日志
```

---

## Workflow 3: Execute Restoration / 工作流三：执行恢复

When user says 「恢复文档」/ "restore documents", execute / 当用户说时执行：

```bash
# Restore using latest record / 使用最新记录恢复
python scripts/sanitize.py restore <workspace>

# Restore using specific record / 使用指定记录恢复
python scripts/sanitize.py restore <workspace> --record _sanitize_record_20260329_121500.json
```

Steps / 执行步骤：
1. Check record file / 检查脱敏记录文件
2. Build reverse mapping (placeholder → original) / 构建反向映射表
3. Scan `_sanitized_output/` / 扫描脱敏输出目录
4. Copy to default restore directory `_restored_output/` / 复制到默认恢复目录 `_restored_output/`
5. Execute reverse replacement / 反向替换
6. Restore filenames using `filename_mapping` in record / 使用记录中的文件名映射还原文件名
7. Verify: check for residual `[RED_` placeholders / 安全校验：检测残留占位符
8. Report results / 汇报结果

> - If `--record` is not specified, the latest record file is used automatically. / 若不指定 `--record`，自动使用最新记录。
> - Restored files are always output to `_restored_output/` (default directory). / 恢复文件默认输出到 `_restored_output/` 目录，原文件不会被修改。
> - The `_restored_output/` directory preserves the same subdirectory structure as `_sanitized_output/`. / `_restored_output/` 保持与 `_sanitized_output/` 相同的子目录结构。

---

## Record File Format / 脱敏记录文件格式

```json
{
  "timestamp": "2026-03-29 12:15:00",
  "config_file": "_sanitize_config.json",
  "rules_applied": { "exact": 5, "regex": 3 },
  "rename_files": true,
  "files_processed": ["subfolder/document.docx"],
  "filename_mapping": {
    "sanitized_name.docx": "original_name.docx"
  },
  "mapping": {
    "[RED_0001]": "张三",
    "[RED_Phone_1]": "13800138000",
    "[RED_Email_1]": "zhangsan@example.com"
  }
}
```

---

## Security Mechanisms / 安全机制

| Mechanism / 机制 | Description / 说明 |
|-----------------|-------------------|
| **Original files untouched / 原文件安全** | Sanitize & restore work on copies only; originals are never modified / 脱敏和恢复均在副本上操作，原文件不变 |
| **Restore verification / 恢复校验** | Post-restore scan for residual placeholders to prevent info leakage / 恢复后检测残留占位符，防止部分恢复导致信息泄露 |
| **Immutable records / 记录不可篡改** | Record filenames include timestamps; each run generates an independent record / 记录文件名含时间戳，每次操作生成独立记录 |
| **Multi-version support / 多版本记录** | Multiple sanitization runs create independent records; restore to any version / 支持多次脱敏，每次独立记录，可按需恢复 |
| **No external connections / 无外部连接** | Script runs entirely locally with no network access / 脚本完全本地运行，无任何网络访问 |
| **No credential handling / 无凭证处理** | No passwords, tokens, or credentials are processed / 不处理任何密码、令牌或凭证信息 |

---

## Supported Formats / 支持格式

| Format / 格式 | Supported / 是否支持 | Notes / 备注 |
|--------------|---------------------|-------------|
| `.docx` | ✅ Yes | Paragraphs, tables, headers/footers, textboxes / 段落、表格、页眉页脚、文本框 |
| `.xlsx` | ✅ Yes | All worksheet cells / 所有工作表单元格 |
| `.doc` | ❌ No | Legacy binary format / 旧版二进制格式 |
| `.pdf` | ❌ No | Not supported / 不支持 |

---

## FAQ / 常见问题

### Where to put the config file? / 配置文件放在哪里？
Workspace root: `_sanitize_config.json`. Use `config` command to generate template. / 工作区根目录下。使用 `config` 命令自动生成模板。

### What if replacement is empty? / 替换内容留空会怎样？
Auto-generates a unique placeholder (e.g., `[RED_0001]`), recorded in the mapping for restoration. / 自动生成唯一占位符，记录在脱敏记录中，确保可恢复。

### Will document formatting change? / 脱敏后文档格式会变吗？
No. Only text content is replaced; formatting, styles, and layout remain unchanged. / 不会。仅替换文本内容，格式、样式、排版完全保持不变。

### How to select which version to restore? / 如何选择恢复到哪个版本？
Record filenames contain timestamps. Use `--record` to specify. Defaults to latest. / 记录文件名含时间戳，使用 `--record` 指定。不指定时自动选择最新。

---

## File Structure / 文件结构

```
document-sanitizer/                 文档脱敏/
├── SKILL.md                        ← Skill definition / 技能定义文件
└── scripts/
    └── sanitize.py                 ← Core script / 核心脚本 (config/sanitize/restore)
```
