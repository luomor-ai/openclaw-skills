---
name: free-web-search
description: Fast web search for external knowledge. Automatically fetches the most relevant page and returns a concise answer.
version: 8.0.0
tags: [search, web, duckduckgo, bing, no-api, realtime, fast]
author: ucsdzehualiu
dependencies:
  - playwright>=1.42.0
  - beautifulsoup4>=4.12.3
  - readability-lxml>=0.8.1
runtime: python3.10
setup: |
  pip install playwright beautifulsoup4 readability-lxml
  playwright install chromium
---

# Web Search (v8.1.0)
高性能网页搜索工具，用于获取实时信息和外部知识，具备多引擎降级、智能内容提取、完善的错误处理能力。

## 环境要求
- Python 3.10 及以上版本
- 支持 Windows/macOS/Linux 系统
- 网络可访问 DuckDuckGo/Bing 搜索引擎

## 使用流程
1. **解析用户问题** - 深度分析用户意图，提取核心关键词
2. **生成精准搜索词** - 基于关键词生成高召回率的搜索Query
3. **多引擎搜索** - 优先使用DuckDuckGo，结果不足时自动降级到Bing
4. **智能排序** - 按标题相关性、权威来源权重排序结果
5. **内容提取** - 过滤广告/冗余内容，提取核心文本
6. **结构化输出** - 按易读格式返回标题、核心内容、来源链接

## 调用方式
```bash
# 基础用法
python scripts/web_search.py "搜索词"

# 输出JSON格式（便于程序调用）
python scripts/web_search.py "搜索词" --json

# 指定抓取页面数（默认5，范围1-10）
python scripts/web_search.py "搜索词" --pages 3