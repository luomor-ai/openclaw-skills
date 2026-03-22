---
name: biaoshu-writer
description: 标书撰写器 v5.0 - 投标技术标文档自动生成工具。当用户需要根据招标要求、评分标准生成技术标Word文档时使用。支持解析txt、pdf、docx、xlsx格式的招标文件，自动分章节编写内容，最终转换为Word格式。适用场景：发送招标文件要求生成技术标、投标文档编写、分章节标书制作、交通工程（高速/航道）技术标。
metadata:
  openclaw:
    requires:
      bins: []
      python: ["python-docx", "pdfplumber", "openpyxl", "PyPDF2"]
    install:
      - id: pip
        kind: pip
        packages:
          - python-docx
          - pdfplumber
          - openpyxl
          - PyPDF2
        label: 安装 Python 依赖库
---

# 标书撰写器 · 投标技术标文档生成工具 v5.0

> 发送招标文件 → 自动生成符合评分标准的技术标Word文档

---

## ⚠️ 使用前必读 - 依赖安装

本skill需要以下环境，请**先安装再使用**：

| 依赖 | 为什么需要 | 安装难度 |
|------|-----------|---------|
| **OpenClaw** | AI助手运行环境 | ⭐⭐ 需安装 |
| **Python 3.8+** | 运行脚本 | ⭐ 系统自带 |
| **python-docx** | Word文档生成 | ⭐ 一键安装 |
| **SimSun.ttf字体** | Word显示宋体 | ⭐⭐ 手动复制 |

---

## 第一步：安装OpenClaw（如果没有）

官网：https://openclaw.ai

安装后确保运行正常：
```bash
openclaw --version
```

---

## 第二步：安装Python库

打开终端，运行：

```bash
pip install python-docx pdfplumber openpyxl PyPDF2
```

**如果提示没有pip**：
```bash
# macOS
python3 -m pip install python-docx pdfplumber openpyxl PyPDF2

# Windows
py -m pip install python-docx pdfplumber openpyxl PyPDF2
```

---

## 第三步：安装SimSun字体（关键！）

### 为什么必须安装
- 没有这个字体，生成的Word文档会显示"MS明朝"等错误字体
- WPS和Office都需要这个字体才能正确显示

### 安装方法

**方法1：从Windows电脑复制（推荐）**
1. 找一台Windows电脑
2. 找到 `C:\Windows\Fonts\SimSun.ttf`
3. 复制到Mac的 `~/Library/Fonts/` 文件夹
4. 验证：`ls -lh ~/Library/Fonts/SimSun.ttf`

**方法2：网上下载**
1. 搜索"SimSun.ttf下载"
2. 下载后放入 `~/Library/Fonts/` 文件夹

### 验证字体安装成功
```bash
ls -lh ~/Library/Fonts/SimSun.ttf
```
看到文件路径即可。

---

## 第四步：安装本技能到OpenClaw

```bash
openclaw skills install <skill路径>
```

---

## 第五步：开始使用

安装完成后，你可以：
1. 发送招标文件（txt/pdf/docx/xlsx）给AI
2. AI会自动解析并生成技术标大纲
3. 确认大纲后，AI会生成完整内容
4. 最终输出符合投标规范的Word文档

---

## 常见问题

### Q: 提示"python-docx未安装"
```bash
pip install python-docx
```

### Q: 生成的Word字体不对（显示MS明朝）
- 原因：SimSun.ttf未正确安装
- 解决：重新复制字体到 `~/Library/Fonts/` 并重启Word

### Q: PDF无法解析
- 如果是扫描版PDF（没有文字层），需要先OCR识别
- 推荐工具：Adobe Acrobat / ilovepdf.com/ocr

### Q: pip不是内部命令
```bash
# Windows 用这个
py -m pip install python-docx

# macOS 用这个
python3 -m pip install python-docx
```

---

## 功能特点

| 能力 | 说明 |
|------|------|
| 📄 多格式解析 | 支持 txt、pdf、docx、xlsx 招标文件 |
| 📊 智能大纲 | 根据评分标准自动生成分章大纲 |
| ✍️ 内容扩充 | 5倍法则充实，每章配套表格 |
| 🤖 AI去痕 | 去除AI写作特征 |
| 📝 规范格式 | SimSun宋体，WPS/Office兼容 |

---

## 适用行业

- 高速公路：收费系统、门架、监控、通信
- 航道信息化：航道监控、船舶管理、航标遥测
- 各类招投标技术标

---

## 执行流程

```
1. 发送招标文件 → AI解析
2. 确认格式 → 用户选择字体/字号/行距
3. 生成大纲 → 用户确认
4. 并发生成章节内容
5. AI去痕处理
6. 转换Word文档
```

---

## 📐 格式确认（必须步骤）

**收到需求后，生成前必须询问用户格式偏好：**

```
📋 格式确认：
请选择文档格式（直接回复数字或描述）：

【格式A：政府标书标准】
  字体：SimSun | 字号：三号32pt | 行距：26磅 | 边距：2cm

【格式B：企业投标书】
  字体：SimHei | 字号：三号28pt | 行距：28磅 | 边距：2cm

【格式C：自定义】
  请告诉我你的具体要求

【直接回车】使用格式A
```

### 可用格式参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| font | SimSun | 正文字体（英文名） |
| body-size | 32pt | 正文字号（三号=32pt） |
| title-level | 36pt | 一级标题字号 |
| sub-level | 32pt | 二级标题字号 |
| line-spacing | 26pt | 行距 |
| margins | 2cm | 页边距 |
| first-line-indent | 0.74cm | 首行缩进 |

### 常用格式模板

```
【政府标书】
font: SimSun / body: 32pt / line: 26pt / margins: 2cm

【高速公路标书】
font: SimSun / body: 32pt / line: 28pt / margins: 2.5cm

【航道工程标书】
font: SimSun / body: 28pt / line: 26pt / margins: 2cm
```

---

## 投标类型

| 类型 | 处理 |
|------|------|
| 陪标 | 纯自主编写 |
| 主标 | 引用数据，禁止复制粘贴 |

---

## 内容规则

- 每小节 ≥ 3个独立段落
- 每章节配表格
- 禁用"我方/我们"，用"将/项目组"
- 禁止金额描述
- 严格按评分标准编写

---

## 字数计算

```
目标 = 评分分值 × (总页数/总分) × 780字
合格范围 = 目标 × 0.75 ~ 1.25
```

---

## 快速参考卡

```
┌─────────────────────────────────────────────────────────┐
│ 常用命令                                                 │
├─────────────────────────────────────────────────────────┤
│ 检查字体: bash scripts/check-font.sh                    │
│ 安装依赖: bash scripts/install-deps.sh                  │
│ 解析文件: python3 scripts/parse_bid_files.py <文件>     │
│ 转换Word: python3 scripts/convert_to_word.py <md> <docx>│
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 格式自定义（Markdown顶部加注释块）                       │
├─────────────────────────────────────────────────────────┤
│ <!-- doc-format                                         │
│ font: SimSun                                            │
│ body-size: 32pt                                         │
│ line-spacing: 26pt                                      │
│ -->                                                      │
└─────────────────────────────────────────────────────────┘
```

---

## 常见问题排查

| 问题 | 原因 | 解决 |
|------|------|------|
| 字体显示MS明朝 | SimSun.ttf未安装 | 重新复制到 ~/Library/Fonts/ |
| PDF无法解析 | 扫描版PDF | 使用Adobe Acrobat OCR |
| pip未找到 | 命令错误 | 改用 `python3 -m pip` |
| import失败 | 库未安装 | `pip install python-docx` |

---

## 脚本说明

| 脚本 | 功能 |
|------|------|
| parse_bid_files.py | 解析招标文件 |
| convert_to_word.py | Markdown转Word |
| install-deps.sh | 安装Python依赖（虚拟环境） |
| check-font.sh | 检查SimSun字体是否安装 |

---

## 目录结构

```
biaoshu-writer/
├── SKILL.md              # 主说明文件（OpenClaw读取）
├── INSTALL.html          # HTML安装教程（浏览器打开查看）
├── scripts/
│   ├── parse_bid_files.py
│   ├── convert_to_word.py
│   ├── install-deps.sh
│   └── check-font.sh     # 检查字体是否安装
└── references/
    └── humanizer-zh.md
```