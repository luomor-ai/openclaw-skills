---
name: wos-crawler
description: |
  Web of Science (WOS) 文献自动爬取工具。基于 Selenium + Edge 浏览器，通过 GUI 界面输入自然语言检索词，自动构造 WOS 高级检索式，批量抓取文献标题、作者、期刊、DOI、被引频次、摘要等信息，支持分页爬取和 Excel 导出。
  支持特定期刊过滤（预设期刊列表+自定义）、作者/标题/DOI 精确检索、文献类型筛选、年份范围限定。
  This skill should be used when the user wants to search, crawl, or scrape literature from Web of Science (webofscience.com), or when the user mentions "WOS", "Web of Science", "文献爬虫", "文献检索", "论文爬取".
---

# WOS 文献爬虫 Pro

基于 Selenium 的 Web of Science 文献批量爬取工具，提供增强型 tkinter GUI 界面。

## 功能

**检索能力：**
- 自然语言检索词自动转换为 WOS 高级检索式 (TS=...)
- 作者精确检索 (AU=)，支持多作者分号分隔
- 标题精确检索 (TI=)
- DOI 精确检索 (DO=)
- 期刊过滤 (SO=)，支持精确匹配和模糊匹配
- 年份范围筛选 (PY=)，支持起始年/结束年独立设置
- 文献类型筛选 (DT=)，如 Article、Review 等
- 所有检索字段通过 AND 连接，多期刊/多作者通过 OR 连接

**期刊过滤特性：**
- 内置 40+ 常用高质量期刊预设（Nature、Science、JACS、Advanced Materials 等）
- 支持自定义期刊输入，回车即可添加
- 已选期刊列表管理（添加、移除、清空）
- 精确匹配模式 (SO="Nature") 和模糊匹配模式 (SO=*Nature*)

**数据提取字段：**
- 标题、作者、期刊名称
- DOI（从链接或页面元素中自动提取）
- 被引频次
- 文献类型（Article、Review 等）
- 出版日期
- 摘要
- 文章链接
- 采集页码

**其他功能：**
- 自动分页爬取，滚动懒加载
- 结果去重
- Excel 导出（含列排序优化）
- Cookie 持久化（GUI 内一键保存登录状态）
- 检索式实时预览
- 错误自动截图保存

## 依赖

```bash
pip install selenium pandas openpyxl
```

不需要安装 `webdriver_manager`，驱动管理由 Selenium 4.6+ 内置的 Selenium Manager 自动处理。

## 使用方式

```bash
python scripts/wos_crawler.py
```

启动后在 GUI 中填写检索条件：
1. 检索词区输入主题关键词
2. 可选填写作者、标题、DOI
3. 在期刊区选择或输入目标期刊
4. 设置年份范围和文献类型
5. 点击"预览检索式"查看生成的 WOS 检索式
6. 点击"开始抓取"执行爬取

## 检索式生成规则

检索词区输入规则：逗号 `,` 表示 AND 连接，斜杠 `/` 表示 OR 连接，空格仅作词组内部间隔原样保留。

所有检索字段之间用 AND 连接：

| UI 输入 | 生成示例 |
|---|---|
| 检索词: `3D printing, array` | `TS=((3D printing AND array))` |
| 检索词: `biosensor / immunosensor` | `TS=((biosensor OR immunosensor))` |
| 检索词: `hydrogel, antibacterial / antifungal` | `TS=((hydrogel AND (antibacterial OR antifungal)))` |
| 作者: `Zhang, San; Li, Si` | `AU=("Zhang, San" OR "Li, Si")` |
| 标题: `wound, healing` | `TI=(wound AND healing)` |
| DOI: `10.1038/xxx` | `DOI="10.1038/xxx"` |
| 期刊: Nature + Science (精确) | `SO=("Nature" OR "Science")` |
| 期刊: Nature (模糊) | `SO=*Nature*` |
| 年份: 2020 到 2025 | `PY=(2020-2025)` |
| 文献类型: Review | `DT=Review` |

## 关键实现细节

### 浏览器驱动加载

1. `local_driver_path` 指定的本地路径
2. Selenium Manager 自动匹配（推荐）

### CSS 选择器回退

所有页面元素查找使用多选择器回退（`safe_find` 方法），适应 WOS 版本迭代。高级检索输入框有 ID 备选选择器容错。

### 已知限制

- 需要机构订阅或已登录 WOS 账号
- 部分提取字段（被引频次、DOI）依赖 WOS 页面元素，不同版本可能有差异
- 摘要在列表页默认折叠，通过"Show more"按钮尝试展开
